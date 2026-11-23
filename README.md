# con-leche: a local `have` makes a cheap check expensive

Lean accepts both files below in 0.2 s. con-leche accepts one and crashes on the other.

| | Lean v4.36.0 | con-leche bc667610 (master, 2026-11-21) |
|---|---|---|
| `Repro/ViaLemma.lean` | 0.2 s | accepted, 3.6 s |
| `Repro/ViaHave.lean` | 0.2 s | stack overflow (exit 134) after 43 s, 13 GB |

The two files prove the same thing. The only difference is where the helper fact lives.

**Step 1: the definitions** (`Repro/Basic.lean`). `Ch` is SHA-256's choice function. `deep n` is just `n`, but computing it takes `n` nested steps, so `deep 10000000` is very expensive to evaluate.

**Step 2: the helper fact.** For all `a b c`:

```lean
Ch a b c = (a &&& b) ^^^ ((a ^^^ 4294967295) &&& c)
```

It is proved by `rfl`. Checking it is cheap, because `a b c` are variables: unfold `Ch` and both sides become the same.

**Step 3: using it.** Both files apply the fact at `a := deep 10000000, b := 1, c := 2`. `ViaLemma` uses it as a top-level lemma. `ViaHave` states it as a local `have h : … := fun _ _ _ => rfl` and then uses `h`.

**Step 4: what Lean does with the `have`.** Lean checks `h` once, with `a b c` as variables (step 2, cheap). From then on, `h` has the type it was declared with. Using `h` at `deep 10000000` only substitutes the arguments into that type. Nothing is computed.

**Step 5: what con-leche does differently.** con-leche also checks `h` once. But then it replaces `h` by its proof, `fun _ _ _ => rfl`, everywhere `h` is used (`ConLeche/Kernel/Core.lean:1323`). That proof on its own only says `Ch x y z = Ch x y z`. So at the use site, con-leche has to prove step 2 again, this time with `a := deep 10000000` instead of a variable.

**Step 6: why that is expensive.** With a concrete argument, the check tries to evaluate `deep 10000000`. That is ten million nested steps, which overflows the stack. Lean's own kernel can't do it either. `DirectKernel.lean` gives it exactly this check, and it fails with "deep recursion detected" after 100 s. Lean never runs into this because of step 4.

**Impact.** This is not a soundness problem: con-leche never accepts anything wrong because of it. But it refuses proofs that Lean accepts, and it fails by crashing instead of reporting "declined". We hit it on a SHA-256 circuit proof. There, a local `have Ch_def … := fun _ _ _ => rfl` is used with `rw` on 32-bit sums.

**Suggested fix.** Do what Lean's kernel does (`infer_let` in `src/kernel/type_checker.cpp`): check the body of a `have` with the declared type of its variable, instead of substituting the proof.

**Running it.**

- `CON_LECHE=/path/to/con-leche ./check.sh` reproduces the table.
- `lake env lean DirectKernel.lean` shows Lean's kernel failing on the step-5 check.
