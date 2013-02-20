open import Spire.Prelude
open import Spire.Type
module Spire.Term where

----------------------------------------------------------------------

data Context : Set
Environment : Context → Set

ScopedType : Context → ℕ → Set
ScopedType Γ ℓ = Environment Γ → Type ℓ

data Context where
  ∅ : Context
  extend : (Γ : Context) (ℓ : ℕ) (Τ : ScopedType Γ ℓ) → Context

Environment ∅ = ⊤
Environment (extend Γ ℓ Τ) = Σ (Environment Γ) λ vs → ⟦ ℓ ∣ Τ vs ⟧

data InContext :  (Γ : Context) (ℓ : ℕ) (Τ : ScopedType Γ ℓ) → Set where
 here : ∀{Γ ℓ Τ} → InContext (extend Γ ℓ Τ) ℓ λ vs → Τ (proj₁ vs)
 there : ∀{Γ ℓ Τ ℓ′} {Τ′ : ScopedType Γ ℓ′}
   → InContext Γ ℓ Τ → InContext (extend Γ ℓ′ Τ′) ℓ λ vs → Τ (proj₁ vs)

lookup : ∀{Γ ℓ Τ} → InContext Γ ℓ Τ → (vs : Environment Γ) → ⟦ ℓ ∣ Τ vs ⟧
lookup here (vs , v) = v
lookup (there p) (vs , v) = lookup p vs

ScopedType₂ : (Γ : Context) (ℓ : ℕ) → ScopedType Γ ℓ → Set
ScopedType₂ Γ ℓ Τ = (vs : Environment Γ) → ⟦ ℓ ∣ Τ vs ⟧ → Type ℓ

----------------------------------------------------------------------

data Term (Γ : Context) : (ℓ : ℕ)
  → ScopedType Γ ℓ → Set
eval : ∀{Γ ℓ Τ} → Term Γ ℓ Τ
  → (vs : Environment Γ) → ⟦ ℓ ∣ Τ vs ⟧

data Term Γ where
  {- Type Formation -}
  `Bool : ∀{ℓ}
    → Term Γ (suc ℓ) (const `Type)
  `Σ : ∀{ℓ}
    (A : Term Γ (suc ℓ) (const `Type))
    (B : Term (extend Γ (suc ℓ)  λ vs →
      `⟦ eval A vs ⟧) (suc ℓ) (const `Type))
    → Term Γ (suc ℓ) (const `Type)
  `Type : ∀{ℓ} → Term Γ (suc ℓ) (const `Type)
  -- `⟦_⟧ : ∀{ℓ}
  --   → Term Γ ℓ (const `Type)
  --   → Term Γ (suc ℓ) (const `Type)

  {- Value Introduction -}
  -- `lift : ∀{ℓ Τ} (e : Term Γ ℓ Τ)
  --  → Term Γ (suc ℓ) λ vs → `⟦ Τ vs ⟧
  `true `false : ∀{ℓ} → Term Γ ℓ (const `Bool)
  _`,_ : ∀{ℓ Τ} {Τ′ : ScopedType₂ Γ ℓ Τ}
   (e : Term Γ ℓ Τ)
   (e′ : Term Γ ℓ λ vs → Τ′ vs (eval e vs))
   → Term Γ ℓ λ vs → `Σ (Τ vs) λ v → Τ′ vs v

  {- Value Elimination -}
  -- `lower : ∀{ℓ Τ}
  --   (e : Term Γ (suc ℓ) λ vs → `⟦ Τ vs ⟧)
  --   → Term Γ ℓ Τ
  -- `caseBool : ∀{ℓ}
  --   (P : Term (extend Γ ℓ (const `Bool))
  --     (suc ℓ) (const `Type))
  --   (e₁ : Term Γ ℓ λ vs → eval P (vs , true))
  --   (e₂ : Term Γ ℓ λ vs → eval P (vs , false))
  --   (e : Term Γ ℓ (const `Bool))
  --   → Term Γ ℓ λ vs → eval P (vs , eval e vs)
  -- `proj₁ : ∀{ℓ Τ} {Τ′ : ScopedType₂ Γ ℓ Τ}
  --   (e : Term Γ ℓ (λ vs → `Σ (Τ vs) (Τ′ vs)))
  --   → Term Γ ℓ Τ
  -- `proj₂ : ∀{ℓ}
  --   {Τ : ScopedType Γ ℓ} {Τ′ : ScopedType₂ Γ ℓ Τ}
  --   (e : Term Γ ℓ (λ vs → `Σ (Τ vs) (Τ′ vs)))
  --   → Term Γ ℓ λ vs → Τ′ vs (proj₁ (eval e vs))

{- Type Formation -}
eval `Bool vs = `Bool
eval (`Σ A B) vs = `Σ (eval A vs) λ v → eval B (vs , v)
eval `Type vs = `Type
-- eval `⟦ A ⟧ vs = `⟦ eval A vs ⟧

{- Value Introduction -}
eval `true vs = true
eval `false vs = false
eval (e `, e′) vs = eval e vs , eval e′ vs

{- Value Elimination -}
-- eval (`lower e) vs = eval e vs
-- eval (`caseBool {ℓ} P e₁ e₂ e) vs =
--   caseBool (λ b → ⟦ ℓ ∣ eval P (vs , b) ⟧)
--   (eval e₁ vs) (eval e₂ vs) (eval e vs)
-- eval (`proj₁ e) vs = proj₁ (eval e vs)
-- eval (`proj₂ e) vs = proj₂ (eval e vs)

----------------------------------------------------------------------

