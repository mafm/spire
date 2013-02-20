open import Spire.Prelude
open import Spire.Reflection using ( _≟_ )
open import Spire.Type
open import Spire.Term
module Spire.PreTerm where

----------------------------------------------------------------------

data PreTerm : Set where
  `Bool `Type : PreTerm
  `Σ : PreTerm → PreTerm → PreTerm
  `true `false : PreTerm
  _`,_ : PreTerm → PreTerm → PreTerm

{-# IMPORT Spire.SurfaceTerm #-}
{-# COMPILED_DATA PreTerm Spire.SurfaceTerm.PreTerm
  Spire.SurfaceTerm.Bool Spire.SurfaceTerm.Type Spire.SurfaceTerm.Sg
  Spire.SurfaceTerm.True Spire.SurfaceTerm.False Spire.SurfaceTerm.Pair #-}

erase : ∀{Γ ℓ Τ} → Term Γ ℓ Τ → PreTerm
erase `Bool = `Bool
erase (`Σ A B) = `Σ (erase A) (erase B)
erase `Type = `Type
erase `true = `true
erase `false = `false
erase (a `, b) = erase a `, erase b

----------------------------------------------------------------------

compare : ∀ Γ ℓ (A B : ScopedType Γ ℓ) → Maybe (A ≡ B)
compare Γ ℓ A B with A ≟ B
compare Γ ℓ A B | yes p = just p
compare Γ ℓ A B | no _ = nothing

data Check (Γ : Context) (ℓ : ℕ) (A : ScopedType Γ ℓ) : PreTerm → Set where
  well :  (e : Term Γ ℓ A) → Check Γ ℓ A (erase e)
  ill : (v : PreTerm) (msg : String) → Check Γ ℓ A v

check : (Γ : Context) (ℓ : ℕ) (A : ScopedType Γ ℓ) (v : PreTerm)
  → Check Γ ℓ A v
check Γ ℓ A v with compare Γ ℓ A (const `Type)
check Γ (suc ℓ) A `Bool | just p rewrite p = well `Bool
check Γ ℓ A `Type | just p = {!!}
check Γ ℓ A (`Σ v v₁) | just p = {!!}
check Γ zero A v | just p = {!!}
check Γ ℓ A v | just p = ill v "is not a Type."
check Γ ℓ A v | nothing = {!!}

-- check Γ zero X `Bool = ill "Bool is not a value in universe level 0."
-- check Γ (suc ℓ) X `Bool with compare X `Type
-- check Γ (suc ℓ) ._ `Bool | just refl = well `Bool
-- check Γ (suc ℓ) X `Bool | nothing = ill "fail"
-- check Γ (suc ℓ) X `Type with compare X `Type
-- check Γ (suc ℓ) ._ `Type | just refl = well `Type
-- check Γ (suc ℓ) X `Type | nothing = ill "fail"
-- check Γ zero X `Type = ill "Type is not a value in universe level 0."
-- check Γ (suc ℓ) X (`Σ A B) with check Γ (suc ℓ) `Type A
-- check Γ (suc ℓ) X (`Σ ._ B) | well A
--   with check (extend Γ (suc ℓ) (λ vs → `⟦ eval A vs ⟧)) (suc ℓ) `Type B
-- check Γ (suc ℓ) X (`Σ ._ ._) | well A | well B with compare X `Type
-- check Γ (suc ℓ) .`Type (`Σ ._ ._) | well A | well B | just refl
--   = well (`Σ A B)
-- check Γ (suc ℓ) X (`Σ ._ ._) | well A | well B | nothing =
--   ill "Σ is not a value in universe level 0."
-- check Γ (suc ℓ) X (`Σ ._ B) | well A | ill msg = ill msg
-- check Γ (suc ℓ) X (`Σ A B) | ill msg = ill msg
-- check Γ zero X (`Σ A B) = ill "fail"
-- check Γ ℓ X `true with compare X `Bool
-- check Γ ℓ ._ `true | just refl = well `true
-- check Γ ℓ X `true | nothing = ill "fail"
-- check Γ ℓ X `false with compare X `Bool
-- check Γ ℓ ._ `false | just refl = well `false
-- check Γ ℓ X `false | nothing = ill "fail"
-- check Γ ℓ X (a `, b) with isΣ X
-- check Γ ℓ .(`Σ A B) (a `, b) | just (A , B , refl) with check Γ ℓ A a
-- check Γ ℓ .(`Σ A B) (._ `, b) | just (A , B , refl) | well a
--   with check (extend Γ (suc ℓ) (λ vs → `⟦ eval A vs ⟧)) ℓ B b
-- check Γ ℓ .(`Σ A B) (.(erase a) `, .(erase b)) | just (A , B , refl) | well a | well b
--   = ill "TODO"
-- check Γ ℓ .(`Σ A B) (.(erase a) `, b) | just (A , B , refl) | well a | ill msg = ill msg
-- check Γ ℓ .(`Σ A B) (a `, b) | just (A , B , refl) | ill msg = ill msg
-- check Γ ℓ X (a `, b) | nothing = ill "Checking a pair against a non-Σ."

-- ----------------------------------------------------------------------

-- checkClosed = check ∅

-- isTyped′ : (ℓ : ℕ) (A a : PreTerm) → Maybe String
-- isTyped′ ℓ A a with checkClosed (suc ℓ) `Type A
-- isTyped′ ℓ ._ a | well A with checkClosed ℓ A a
-- isTyped′ ℓ .(erase A) .(erase a) | well A | well a = nothing
-- isTyped′ ℓ .(erase A) a | well A | ill msg = just msg
-- isTyped′ ℓ A a | ill msg = just msg

-- TypeChecker = (ℓ : Int) (A a : PreTerm) → Maybe String
-- isTyped : TypeChecker
-- isTyped i = isTyped′ (abs i)

