import Mathlib
set_option maxHeartbeats 4000000

/-!
# Bochner–Riesz Multipliers in Three Dimensions (Theorem 1.1)

Formal problem statement for **Theorem 1.1** from:
OpenAI, *Bochner–Riesz multipliers in three dimensions*,
September 24, 2026.
https://github.com/openai/math/blob/main/preprints/Bochner-Riesz-Multipliers-in-Three-Dimensions-September-24-2026/Bochner-Riesz-Multipliers-in-Three-Dimensions-September-24-2026.pdf
-/

/-- The Bochner–Riesz multiplier symbol `m_δ(ξ) = (1 - |ξ|²)_+^δ` on `ℝ³`. -/
noncomputable def bochnerRieszSymbol (δ : ℝ) (ξ : EuclideanSpace ℝ (Fin 3)) : ℝ :=
  (max (1 - ‖ξ‖ ^ 2) 0) ^ δ

/-- The Bochner–Riesz multiplier operator `T_δ` on `ℝ³` of order `δ > 0`, acting on a Schwartz
function `f ∈ 𝓢(ℝ³)` by
`T_δ f(x) = ∫_{ℝ³} (1 - |ξ|²)_+^δ f̂(ξ) e^{2πi x · ξ} dξ`,
where `f̂(ξ) = ∫_{ℝ³} f(x) e^{-2πi x · ξ} dx` is the Fourier transform `FourierTransform.fourier f`. -/
noncomputable def bochnerRiesz (δ : ℝ)
    (f : SchwartzMap (EuclideanSpace ℝ (Fin 3)) ℂ) (x : EuclideanSpace ℝ (Fin 3)) : ℂ :=
  ∫ ξ : EuclideanSpace ℝ (Fin 3),
    (bochnerRieszSymbol δ ξ : ℂ) * FourierTransform.fourier f ξ *
      Complex.exp (2 * Real.pi * Complex.I * (inner ℝ x ξ : ℝ))

/- **Theorem 1.1** (Three-dimensional Bochner–Riesz multiplier bound on `L³(ℝ³)`):
For every `δ > 0`, there is a finite constant `C_δ` such that
`‖T_δ f‖_{L³(ℝ³)} ≤ C_δ ‖f‖_{L³(ℝ³)}` for all `f ∈ 𝓢(ℝ³)`. -/
theorem bochner_riesz (δ : ℝ) (hδ : 0 < δ) :
    ∃ C_δ : ℝ,
      0 ≤ C_δ ∧
      ∀ f : SchwartzMap (EuclideanSpace ℝ (Fin 3)) ℂ,
        MeasureTheory.eLpNorm (bochnerRiesz δ f) 3 MeasureTheory.volume ≤
          ENNReal.ofReal C_δ * MeasureTheory.eLpNorm f 3 MeasureTheory.volume := by
  sorry
