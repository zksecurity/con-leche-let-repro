import Repro.Basic

/-- `Ch_def` at `deep N`, through a local `have` proved by `rfl`. -/
theorem viaHave :
    Ch (deep 10000000) 1 2 = (deep 10000000 &&& 1) ^^^ ((deep 10000000 ^^^ 4294967295) &&& 2) := by
  have h : ∀ a b c : Nat, Ch a b c = (a &&& b) ^^^ ((a ^^^ 4294967295) &&& c) := fun _ _ _ => rfl
  exact h _ _ _
