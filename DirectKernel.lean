import Lean
import Repro.ViaLemma

/-! `viaLemma`'s statement with value `rfl`, handed straight to Lean's kernel: the instantiated
equality con-leche ends up checking in `ViaHave`. Not built by `lake build`; run
`lake env lean DirectKernel.lean` (fails with "(kernel) deep recursion detected" after ~100 s). -/

open Lean Elab Command in
run_cmd liftTermElabM do
  let ty := (← getConstInfo ``viaLemma).type
  let some (_, lhs, _) := ty.eq? | throwError "not an equation"
  addDecl (.thmDecl { name := `direct, levelParams := [], type := ty, value := ← Meta.mkEqRefl lhs })
