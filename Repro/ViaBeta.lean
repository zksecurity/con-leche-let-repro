import Repro.Basic

theorem viaBeta :
    Ch (deep 10000000) 1 2 = (deep 10000000 &&& 1) ^^^ ((deep 10000000 ^^^ 4294967295) &&& 2) :=
  (fun (h : ∀ a b c : Nat, Ch a b c = (a &&& b) ^^^ ((a ^^^ 4294967295) &&& c)) => h _ _ _)
    (fun _ _ _ => rfl)
