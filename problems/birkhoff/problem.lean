import Mathlib
set_option maxHeartbeats 4000000

/-!
# Rigidity of Smooth Billiards with a Continuous Caustic Collar (Definition 1.1 & Theorem 1.2)

Formal problem statement for **Definition 1.1** and **Theorem 1.2** from:
OpenAI, *Rigidity of Smooth Billiards with a Continuous Caustic Collar*,
September 24, 2026.
https://github.com/openai/math/blob/main/preprints/Rigidity-of-Smooth-Billiards-with-a-Continuous-Caustic-Collar-September-24-2026/paper.pdf

## Mathematical Statement (Section 1, p. 4)

**Definition 1.1 (A continuous caustic collar).**
Let $\Omega \subset \mathbb{R}^2$ be a bounded strictly convex domain whose boundary is a
$C^\infty$ simple closed regular curve with positive curvature. A *smooth closed convex caustic*
is a $C^\infty$ simple closed regular curve in $\Omega$, bounding a strictly convex set, such that
a billiard segment tangent to the curve remains tangent after reflection at either endpoint. Here
reflection of an incoming unit velocity $v$ at a boundary point with outward unit normal $n$ is
$$v \longmapsto v - 2(v \cdot n)n.$$
A *continuous caustic collar* consists of a relatively open set $A \subset \overline{\Omega}$
containing $\partial\Omega$ and a homeomorphism
$$H_0 : \mathbb{S}^1 \times [0, 1) \longrightarrow A$$
such that $H_0(\mathbb{S}^1 \times \{0\}) = \partial\Omega$, and
$H_0(\mathbb{S}^1 \times \{b\})$ is a smooth closed convex caustic for every $0 < b < 1$.

**Theorem 1.2.**
*If $\Omega$ has a continuous caustic collar, then $\Omega$ is an ellipse. Equivalently, there are
$c \in \mathbb{R}^2$ and a real symmetric positive-definite matrix $Q$ such that*
$$\Omega = \{x \in \mathbb{R}^2 : (x - c)^T Q (x - c) < 1\}.$$
*Circles are included.*
-/

open ContDiff Set Topology Metric Matrix

/-- The Euclidean plane `ℝ²`. -/
abbrev Plane : Type := EuclideanSpace ℝ (Fin 2)

/-- The unit circle `𝕊¹ ⊂ ℝ²`. -/
abbrev UnitCircle : Type := Metric.sphere (0 : Plane) 1

/-- The two-dimensional determinant (cross product) `det(u, v) = u₀ v₁ - u₁ v₀` of two planar
vectors `u, v ∈ ℝ²`. -/
def det2 (u v : Plane) : ℝ :=
  u 0 * v 1 - u 1 * v 0

/-- The signed curvature `κ_γ(t) = det(γ'(t), γ''(t)) / ‖γ'(t)‖³` of a plane curve `γ : ℝ → ℝ²`
at parameter `t ∈ ℝ`. -/
noncomputable def signedCurvature (γ : ℝ → Plane) (t : ℝ) : ℝ :=
  det2 (deriv γ t) (deriv (deriv γ) t) / ‖deriv γ t‖ ^ 3

/-- A map `γ : ℝ → ℝ²` is a `C^∞` simple closed regular parametrization of a curve `C ⊆ ℝ²`
with period `L > 0` if:
1. `0 < L`,
2. `γ` is `C^∞` smooth (`ContDiff ℝ ∞ γ`),
3. `γ` is `L`-periodic (`Function.Periodic γ L`),
4. `γ` is simple (injective on `ℝ / Lℤ`, i.e., `γ(t₁) = γ(t₂) → t₁ - t₂ ∈ Lℤ`),
5. `γ` is regular (`γ'(t) ≠ 0` for all `t ∈ ℝ`), and
6. the image of `γ` is `C` (`range γ = C`). -/
structure IsSmoothSimpleClosedRegularParam (γ : ℝ → Plane) (L : ℝ) (C : Set Plane) : Prop where
  /-- The period `L` is strictly positive. -/
  period_pos : 0 < L
  /-- `γ` is `C^∞` smooth on `ℝ`. -/
  smooth : ContDiff ℝ ∞ γ
  /-- `γ` has period `L`. -/
  periodic : Function.Periodic γ L
  /-- `γ` is injective modulo `L`. -/
  simple : ∀ t₁ t₂ : ℝ, γ t₁ = γ t₂ → ∃ k : ℤ, t₁ - t₂ = k * L
  /-- `γ` is regular everywhere (`γ'(t) ≠ 0`). -/
  regular : ∀ t : ℝ, deriv γ t ≠ 0
  /-- The image of `γ` is `C`. -/
  range_eq : Set.range γ = C

/-- A subset `C ⊆ ℝ²` is a `C^∞` simple closed regular curve with positive curvature if it admits
a (counterclockwise) `C^∞` simple closed regular parametrization `γ : ℝ → ℝ²` of some positive
period `L > 0` whose signed curvature `κ_γ(t) > 0` is strictly positive for all `t ∈ ℝ`. -/
def IsSmoothPositiveCurvatureCurve (C : Set Plane) : Prop :=
  ∃ (γ : ℝ → Plane) (L : ℝ),
    IsSmoothSimpleClosedRegularParam γ L C ∧ ∀ t : ℝ, 0 < signedCurvature γ t

/-- A subset `Ω ⊆ ℝ²` is a bounded strictly convex domain if it is open, nonempty, bounded,
convex, and for any two distinct points `x, y ∈ Ω̄`, the open line segment `(x, y)` lies in `Ω`. -/
structure IsBoundedStrictlyConvexDomain (Ω : Set Plane) : Prop where
  /-- `Ω` is an open subset of `ℝ²`. -/
  isOpen : IsOpen Ω
  /-- `Ω` is nonempty. -/
  nonempty : Ω.Nonempty
  /-- `Ω` is bounded. -/
  isBounded : Bornology.IsBounded Ω
  /-- `Ω` is convex. -/
  convex : Convex ℝ Ω
  /-- Strict convexity: for any distinct `x, y ∈ Ω̄`, the open segment `(x, y)` lies in `Ω`. -/
  openSegment_subset : ∀ x ∈ closure Ω, ∀ y ∈ closure Ω, x ≠ y → openSegment ℝ x y ⊆ Ω

/-- The standing geometric hypothesis on the billiard table `Ω ⊂ ℝ²` in **Definition 1.1**:
`Ω` is a bounded strictly convex domain whose boundary `∂Ω` (`frontier Ω`) is a `C^∞` simple
closed regular curve with positive curvature. -/
structure IsSmoothPositivelyCurvedBilliardDomain (Ω : Set Plane) : Prop where
  /-- `Ω` is a bounded strictly convex planar domain. -/
  domain : IsBoundedStrictlyConvexDomain Ω
  /-- `∂Ω` is a `C^∞` simple closed regular curve with positive curvature. -/
  boundary_smooth_pos_curvature : IsSmoothPositiveCurvatureCurve (frontier Ω)

/-- A vector `n ∈ ℝ²` is the outward unit normal to `Ω` at a boundary point `p ∈ ∂Ω` if:
1. `‖n‖ = 1` (`n` is a unit vector),
2. `⟨n, γ'(t)⟩ = 0` (`n` is normal/orthogonal to the boundary tangent `γ'(t)` at `p = γ(t)`), and
3. `⟨x - p, n⟩ ≤ 0` for all `x ∈ Ω` (`n` points outward from `Ω`). -/
def IsOutwardUnitNormal (Ω : Set Plane) (p n : Plane) : Prop :=
  ‖n‖ = 1 ∧
  (∃ (γ : ℝ → Plane) (L : ℝ) (t : ℝ),
    IsSmoothSimpleClosedRegularParam γ L (frontier Ω) ∧
    γ t = p ∧
    inner ℝ n (deriv γ t) = 0) ∧
  ∀ x ∈ Ω, inner ℝ (x - p) n ≤ 0

/-- Billiard reflection of an incoming unit velocity `v ∈ ℝ²` at a boundary point with outward
unit normal `n ∈ ℝ²` (**Definition 1.1**):
$$v \longmapsto v - 2(v \cdot n)n.$$ -/
noncomputable def billiardReflect (n v : Plane) : Plane :=
  v - (2 * inner ℝ v n) • n

/-- A billiard segment `[p, q]` (with endpoints `p, q ∈ ∂Ω`, `p ≠ q`) is tangent to a curve
parametrized by `α : ℝ → ℝ²` if `[p, q]` meets the curve at some point `α(t)` where the tangent
vector `α'(t)` is parallel to the segment direction `q - p`. -/
def IsBilliardSegmentTangentTo (α : ℝ → Plane) (p q : Plane) : Prop :=
  ∃ t : ℝ, α t ∈ segment ℝ p q ∧ ∃ c : ℝ, deriv α t = c • (q - p)

/-- **Definition 1.1** (Smooth closed convex caustic):
A *smooth closed convex caustic* in `Ω` is a `C^∞` simple closed regular curve `C ⊂ Ω`, bounding a
strictly convex set `U`, such that a billiard segment `[p, q]` (with `p, q ∈ ∂Ω`, `p ≠ q`) tangent
to `C` remains tangent to `C` after billiard reflection `v ↦ v - 2(v · n)n` at either endpoint
`q` or `p`. -/
def IsSmoothClosedConvexCaustic (Ω C : Set Plane) : Prop :=
  C ⊆ Ω ∧
  (∃ U : Set Plane, IsBoundedStrictlyConvexDomain U ∧ frontier U = C) ∧
  ∃ (α : ℝ → Plane) (L : ℝ),
    IsSmoothSimpleClosedRegularParam α L C ∧
    ∀ p ∈ frontier Ω, ∀ q ∈ frontier Ω, p ≠ q →
      IsBilliardSegmentTangentTo α p q →
      (∀ n_q : Plane, IsOutwardUnitNormal Ω q n_q →
        ∃ r ∈ frontier Ω, r ≠ q ∧
          (∃ s : ℝ, 0 < s ∧ r = q + s • billiardReflect n_q (‖q - p‖⁻¹ • (q - p))) ∧
          IsBilliardSegmentTangentTo α q r) ∧
      (∀ n_p : Plane, IsOutwardUnitNormal Ω p n_p →
        ∃ r ∈ frontier Ω, r ≠ p ∧
          (∃ s : ℝ, 0 < s ∧ r = p + s • billiardReflect n_p (‖p - q‖⁻¹ • (p - q))) ∧
          IsBilliardSegmentTangentTo α p r)

/-- The slice `H₀(𝕊¹ × {b}) ⊆ ℝ²` of a collar map `H₀ : 𝕊¹ × [0, 1) → A` at parameter
`b ∈ [0, 1)`. -/
def collarSlice {A : Set Plane} (H₀ : (UnitCircle × Set.Ico (0 : ℝ) 1) ≃ₜ A)
    (b : ℝ) (hb : b ∈ Set.Ico (0 : ℝ) 1) : Set Plane :=
  Set.range (fun θ : UnitCircle => (H₀ (θ, ⟨b, hb⟩) : Plane))

/-- **Definition 1.1** (A continuous caustic collar):
A *continuous caustic collar* of `Ω` consists of a relatively open set `A ⊂ Ω̄` containing `∂Ω`
and a homeomorphism `H₀ : 𝕊¹ × [0, 1) → A` such that `H₀(𝕊¹ × {0}) = ∂Ω`, and
`H₀(𝕊¹ × {b})` is a smooth closed convex caustic in `Ω` for every `0 < b < 1`. -/
def HasContinuousCausticCollar (Ω : Set Plane) : Prop :=
  ∃ A : Set Plane,
    A ⊆ closure Ω ∧
    frontier Ω ⊆ A ∧
    (∃ V : Set Plane, IsOpen V ∧ A = V ∩ closure Ω) ∧
    ∃ H₀ : (UnitCircle × Set.Ico (0 : ℝ) 1) ≃ₜ A,
      collarSlice H₀ 0 (by simp) = frontier Ω ∧
      ∀ b : ℝ, ∀ hb0 : 0 < b, ∀ hb1 : b < 1,
        IsSmoothClosedConvexCaustic Ω (collarSlice H₀ b ⟨le_of_lt hb0, hb1⟩)

/-- A planar domain `Ω ⊂ ℝ²` is an ellipse (with circles included) if there exist `c ∈ ℝ²` and a
real symmetric positive-definite `2 × 2` matrix `Q` such that
`Ω = {x ∈ ℝ² : (x - c)^T Q (x - c) < 1}` (**Theorem 1.2**). -/
def IsEllipse (Ω : Set Plane) : Prop :=
  ∃ c : Plane, ∃ Q : Matrix (Fin 2) (Fin 2) ℝ,
    Q.IsSymm ∧ Q.PosDef ∧
    Ω = { x : Plane | (x - c).ofLp ⬝ᵥ Q.mulVec (x - c).ofLp < 1 }

/-- **Theorem 1.2** (Near-boundary Birkhoff conjecture / physical-collar rigidity):
Let `Ω ⊂ ℝ²` be a bounded strictly convex domain whose boundary is a `C^∞` simple closed regular
curve with positive curvature. If `Ω` has a continuous caustic collar, then `Ω` is an ellipse:
there are `c ∈ ℝ²` and a real symmetric positive-definite matrix `Q` such that
`Ω = {x ∈ ℝ² : (x - c)^T Q (x - c) < 1}` (circles are included). -/
theorem birkhoff_theorem_1_2 (Ω : Set Plane)
    (hΩ : IsSmoothPositivelyCurvedBilliardDomain Ω)
    (hCollar : HasContinuousCausticCollar Ω) :
    IsEllipse Ω := by
  sorry

