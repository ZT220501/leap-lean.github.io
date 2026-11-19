import Mathlib
set_option maxHeartbeats 4000000

/-!
# Uniform Interior $C^{1,\alpha}$ Estimates for Infinity-Harmonic Functions (Theorem 1.1)

Formal problem statement for **Theorem 1.1** (Uniform interior estimate) from:
OpenAI, *Uniform Interior $C^{1,\alpha}$ Estimates for Infinity-Harmonic Functions*,
October 4, 2026.
https://github.com/openai/math/blob/main/preprints/Uniform-Interior-C1alpha-Estimates-for-Infinity-Harmonic-Functions-October-4-2026/interior-c1-infinity-harmonic.pdf
-/

/-- The unnormalized infinity Laplacian
`Δ_∞ ϕ(z) = ⟨D²ϕ(z) ∇ϕ(z), ∇ϕ(z)⟩ = ∑_{i,j=1}^d ϕ_i(z) ϕ_j(z) ϕ_{ij}(z)`
of a real-valued function `ϕ` on `ℝ^d` at `z`. -/
noncomputable def infinityLaplacian {d : ℕ}
    (ϕ : EuclideanSpace ℝ (Fin d) → ℝ) (z : EuclideanSpace ℝ (Fin d)) : ℝ :=
  fderiv ℝ (fderiv ℝ ϕ) z (gradient ϕ z) (gradient ϕ z)

/-- A continuous function `u` on an open set `Ω ⊆ ℝ^d` is *infinity-harmonic* (in the viscosity
sense) if every local upper `C²` test `ϕ` touching `u` from above at `z ∈ Ω` satisfies
`Δ_∞ ϕ(z) ≥ 0`, and every local lower `C²` test `ϕ` touching `u` from below at `z ∈ Ω` satisfies
`Δ_∞ ϕ(z) ≤ 0` (including when `∇ϕ(z) = 0`). -/
def IsInfinityHarmonicOn {d : ℕ}
    (u : EuclideanSpace ℝ (Fin d) → ℝ) (Ω : Set (EuclideanSpace ℝ (Fin d))) : Prop :=
  ContinuousOn u Ω ∧
  (∀ z ∈ Ω, ∀ ϕ : EuclideanSpace ℝ (Fin d) → ℝ,
    ∀ V : Set (EuclideanSpace ℝ (Fin d)),
      IsOpen V → z ∈ V → V ⊆ Ω → ContDiffOn ℝ 2 ϕ V →
      ϕ z = u z → (∀ y ∈ V, u y ≤ ϕ y) → 0 ≤ infinityLaplacian ϕ z) ∧
  (∀ z ∈ Ω, ∀ ϕ : EuclideanSpace ℝ (Fin d) → ℝ,
    ∀ V : Set (EuclideanSpace ℝ (Fin d)),
      IsOpen V → z ∈ V → V ⊆ Ω → ContDiffOn ℝ 2 ϕ V →
      ϕ z = u z → (∀ y ∈ V, ϕ y ≤ u y) → infinityLaplacian ϕ z ≤ 0)

/-- The oscillation `osc_E u = sup_E u - inf_E u` of a real-valued function `u` on `E`. -/
noncomputable def oscOn {X : Type*} (u : X → ℝ) (E : Set X) : ℝ :=
  sSup (u '' E) - sInf (u '' E)

/-- The supremum norm `‖g‖_{L^∞(E)} = sup_{x ∈ E} ‖g(x)‖` on `E`. -/
noncomputable def supNormOn {X Y : Type*} [Norm Y] (g : X → Y) (E : Set X) : ℝ :=
  sSup ((fun x => ‖g x‖) '' E)

/-- The `α`-Hölder seminorm
`[g]_{C^{0,α}(E)} = sup_{x, y ∈ E, x ≠ y} (‖g(x) - g(y)‖ / ‖x - y‖^α)`. -/
noncomputable def holderSeminormOn {X Y : Type*} [NormedAddCommGroup X] [NormedAddCommGroup Y]
    (α : ℝ) (g : X → Y) (E : Set X) : ℝ :=
  sSup { q : ℝ | ∃ x ∈ E, ∃ y ∈ E, x ≠ y ∧ q = ‖g x - g y‖ / ‖x - y‖ ^ α }

/-- Membership `u ∈ C^{1,α}(E)` on an open subset `E ⊆ ℝ^d`: `u` is `C¹` on `E`, `u` is bounded on
`E`, and both `‖∇u‖` and the `α`-Hölder difference quotients of `∇u` are bounded above on `E`. -/
def MemC1HolderOn {d : ℕ} (α : ℝ) (u : EuclideanSpace ℝ (Fin d) → ℝ)
    (E : Set (EuclideanSpace ℝ (Fin d))) : Prop :=
  ContDiffOn ℝ 1 u E ∧
  Bornology.IsBounded (u '' E) ∧
  BddAbove ((fun x => ‖gradient u x‖) '' E) ∧
  BddAbove { q : ℝ | ∃ x ∈ E, ∃ y ∈ E, x ≠ y ∧
    q = ‖gradient u x - gradient u y‖ / ‖x - y‖ ^ α }

/- **Theorem 1.1** (Uniform interior estimate):
For every integer `d ≥ 3` there are constants `α_d ∈ (0, 1/3]` and `C_d < ∞` such that every
bounded infinity-harmonic function `u ∈ C(B_1)`, where `B_1 ⊂ ℝ^d`, belongs to
`C^{1,α_d}(B_{1/2})` and satisfies
`‖∇u‖_{L^∞(B_{1/2})} + [∇u]_{C^{0,α_d}(B_{1/2})} ≤ C_d osc_{B_1} u`. -/
theorem OAI_377 (d : ℕ) (hd : 3 ≤ d) :
    ∃ (α_d C_d : ℝ),
      0 < α_d ∧ α_d ≤ 1 / 3 ∧ 0 ≤ C_d ∧
      ∀ u : EuclideanSpace ℝ (Fin d) → ℝ,
        Bornology.IsBounded (u '' Metric.ball 0 1) →
        IsInfinityHarmonicOn u (Metric.ball 0 1) →
        MemC1HolderOn α_d u (Metric.ball 0 (1 / 2)) ∧
        supNormOn (gradient u) (Metric.ball 0 (1 / 2)) +
          holderSeminormOn α_d (gradient u) (Metric.ball 0 (1 / 2)) ≤
            C_d * oscOn u (Metric.ball 0 1) := by
  sorry
