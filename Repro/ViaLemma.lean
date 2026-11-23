import Repro.Basic

/-- The same, through the top-level lemma. -/
theorem viaLemma :
    Ch (deep 10000000) 1 2 = (deep 10000000 &&& 1) ^^^ ((deep 10000000 ^^^ 4294967295) &&& 2) :=
  Ch_def _ _ _
