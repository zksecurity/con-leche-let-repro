def not32 (a : Nat) : Nat := a ^^^ 0xffffffff
def Ch (e f g : Nat) : Nat := (e &&& f) ^^^ (not32 e &&& g)

/-- Reduces to a literal only through `N` nested unfoldings. -/
def deep : Nat → Nat
  | 0 => 0
  | n + 1 => deep n + 1

theorem Ch_def : ∀ a b c : Nat, Ch a b c = (a &&& b) ^^^ ((a ^^^ 4294967295) &&& c) :=
  fun _ _ _ => rfl
