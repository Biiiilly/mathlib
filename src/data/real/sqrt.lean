/-
Copyright (c) 2020 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro, Floris van Doorn, Yury Kudryashov
-/
import topology.algebra.order.monotone_continuity
import topology.instances.nnreal
import tactic.positivity

/-!
# Square root of a real number

In this file we define

* `nnreal.sqrt` to be the square root of a nonnegative real number.
* `real.sqrt` to be the square root of a real number, defined to be zero on negative numbers.

Then we prove some basic properties of these functions.

## Implementation notes

We define `nnreal.sqrt` as the noncomputable inverse to the function `x ↦ x * x`. We use general
theory of inverses of strictly monotone functions to prove that `nnreal.sqrt x` exists. As a side
effect, `nnreal.sqrt` is a bundled `order_iso`, so for `nnreal` numbers we get continuity as well as
theorems like `sqrt x ≤ y ↔ x ≤ y * y` for free.

Then we define `real.sqrt x` to be `nnreal.sqrt (real.to_nnreal x)`. We also define a Cauchy
sequence `real.sqrt_aux (f : cau_seq ℚ abs)` which converges to `sqrt (mk f)` but do not prove (yet)
that this sequence actually converges to `sqrt (mk f)`.

## Tags

square root
-/

open set filter
open_locale filter nnreal topological_space

namespace nnreal

variables {x y : ℝ≥0}

/-- Square root of a nonnegative real number. -/
@[pp_nodot] noncomputable def sqrt : ℝ≥0 ≃o ℝ≥0 :=
order_iso.symm $ pow_order_iso 2 two_ne_zero

lemma sqrt_le_sqrt_iff : sqrt x ≤ sqrt y ↔ x ≤ y :=
sqrt.le_iff_le

lemma sqrt_lt_sqrt_iff : sqrt x < sqrt y ↔ x < y :=
sqrt.lt_iff_lt

lemma sqrt_eq_iff_sq_eq : sqrt x = y ↔ y ^ 2 = x :=
sqrt.to_equiv.apply_eq_iff_eq_symm_apply.trans eq_comm

lemma sqrt_le_iff : sqrt x ≤ y ↔ x ≤ y ^ 2 :=
sqrt.to_galois_connection _ _

lemma le_sqrt_iff : x ≤ sqrt y ↔ x ^ 2 ≤ y :=
(sqrt.symm.to_galois_connection _ _).symm

@[simp] lemma sqrt_eq_zero : sqrt x = 0 ↔ x = 0 :=
sqrt_eq_iff_sq_eq.trans $ by rw [eq_comm, sq, zero_mul]

@[simp] lemma sqrt_zero : sqrt 0 = 0 := sqrt_eq_zero.2 rfl
@[simp] lemma sqrt_one : sqrt 1 = 1 := sqrt_eq_iff_sq_eq.2 $ one_pow _
@[simp] lemma sq_sqrt (x : ℝ≥0) : (sqrt x)^2 = x := sqrt.symm_apply_apply x
@[simp] lemma mul_self_sqrt (x : ℝ≥0) : sqrt x * sqrt x = x := by rw [← sq, sq_sqrt]
@[simp] lemma sqrt_sq (x : ℝ≥0) : sqrt (x^2) = x := sqrt.apply_symm_apply x
@[simp] lemma sqrt_mul_self (x : ℝ≥0) : sqrt (x * x) = x := by rw [← sq, sqrt_sq x]

lemma sqrt_mul (x y : ℝ≥0) : sqrt (x * y) = sqrt x * sqrt y :=
by rw [sqrt_eq_iff_sq_eq, mul_pow, sq_sqrt, sq_sqrt]

/-- `nnreal.sqrt` as a `monoid_with_zero_hom`. -/
noncomputable def sqrt_hom : ℝ≥0 →*₀ ℝ≥0 := ⟨sqrt, sqrt_zero, sqrt_one, sqrt_mul⟩

lemma sqrt_inv (x : ℝ≥0) : sqrt (x⁻¹) = (sqrt x)⁻¹ := map_inv₀ sqrt_hom x

lemma sqrt_div (x y : ℝ≥0) : sqrt (x / y) = sqrt x / sqrt y := map_div₀ sqrt_hom x y

lemma continuous_sqrt : continuous sqrt := sqrt.continuous

end nnreal

namespace real

/-- An auxiliary sequence of rational numbers that converges to `real.sqrt (mk f)`.
Currently this sequence is not used in `mathlib`.  -/
def sqrt_aux (f : cau_seq ℚ abs) : ℕ → ℚ
| 0       := rat.mk_nat (f 0).num.to_nat.sqrt (f 0).denom.sqrt
| (n + 1) := let s := sqrt_aux n in max 0 $ (s + f (n+1) / s) / 2

theorem sqrt_aux_nonneg (f : cau_seq ℚ abs) : ∀ i : ℕ, 0 ≤ sqrt_aux f i
| 0       := by rw [sqrt_aux, rat.mk_nat_eq, rat.mk_eq_div];
  apply div_nonneg; exact int.cast_nonneg.2 (int.of_nat_nonneg _)
| (n + 1) := le_max_left _ _

/- TODO(Mario): finish the proof
theorem sqrt_aux_converges (f : cau_seq ℚ abs) : ∃ h x, 0 ≤ x ∧ x * x = max 0 (mk f) ∧
  mk ⟨sqrt_aux f, h⟩ = x :=
begin
  rcases sqrt_exists (le_max_left 0 (mk f)) with ⟨x, x0, hx⟩,
  suffices : ∃ h, mk ⟨sqrt_aux f, h⟩ = x,
  { exact this.imp (λ h e, ⟨x, x0, hx, e⟩) },
  apply of_near,

  rsuffices ⟨δ, δ0, hδ⟩ : ∃ δ > 0, ∀ i, abs (↑(sqrt_aux f i) - x) < δ / 2 ^ i,
  { intros }
end -/

/-- The square root of a real number. This returns 0 for negative inputs. -/
@[pp_nodot] noncomputable def sqrt (x : ℝ) : ℝ :=
nnreal.sqrt (real.to_nnreal x)
/-quotient.lift_on x
  (λ f, mk ⟨sqrt_aux f, (sqrt_aux_converges f).fst⟩)
  (λ f g e, begin
    rcases sqrt_aux_converges f with ⟨hf, x, x0, xf, xs⟩,
    rcases sqrt_aux_converges g with ⟨hg, y, y0, yg, ys⟩,
    refine xs.trans (eq.trans _ ys.symm),
    rw [← @mul_self_inj_of_nonneg ℝ _ x y x0 y0, xf, yg],
    congr' 1, exact quotient.sound e
  end)-/

variables {x y : ℝ}

@[simp, norm_cast] lemma coe_sqrt {x : ℝ≥0} : (nnreal.sqrt x : ℝ) = real.sqrt x :=
by rw [real.sqrt, real.to_nnreal_coe]

@[continuity]
lemma continuous_sqrt : continuous sqrt :=
nnreal.continuous_coe.comp $ nnreal.sqrt.continuous.comp continuous_real_to_nnreal

theorem sqrt_eq_zero_of_nonpos (h : x ≤ 0) : sqrt x = 0 :=
by simp [sqrt, real.to_nnreal_eq_zero.2 h]

theorem sqrt_nonneg (x : ℝ) : 0 ≤ sqrt x := nnreal.coe_nonneg _

@[simp] theorem mul_self_sqrt (h : 0 ≤ x) : sqrt x * sqrt x = x :=
by rw [sqrt, ← nnreal.coe_mul, nnreal.mul_self_sqrt, real.coe_to_nnreal _ h]

@[simp] theorem sqrt_mul_self (h : 0 ≤ x) : sqrt (x * x) = x :=
(mul_self_inj_of_nonneg (sqrt_nonneg _) h).1 (mul_self_sqrt (mul_self_nonneg _))

theorem sqrt_eq_cases : sqrt x = y ↔ y * y = x ∧ 0 ≤ y ∨ x < 0 ∧ y = 0 :=
begin
  split,
  { rintro rfl,
    cases le_or_lt 0 x with hle hlt,
    { exact or.inl ⟨mul_self_sqrt hle, sqrt_nonneg x⟩ },
    { exact or.inr ⟨hlt, sqrt_eq_zero_of_nonpos hlt.le⟩ } },
  { rintro (⟨rfl, hy⟩|⟨hx, rfl⟩),
    exacts [sqrt_mul_self hy, sqrt_eq_zero_of_nonpos hx.le] }
end

theorem sqrt_eq_iff_mul_self_eq (hx : 0 ≤ x) (hy : 0 ≤ y) :
  sqrt x = y ↔ y * y = x :=
⟨λ h, by rw [← h, mul_self_sqrt hx], λ h, by rw [← h, sqrt_mul_self hy]⟩

theorem sqrt_eq_iff_mul_self_eq_of_pos (h : 0 < y) :
  sqrt x = y ↔ y * y = x :=
by simp [sqrt_eq_cases, h.ne', h.le]

@[simp] lemma sqrt_eq_one : sqrt x = 1 ↔ x = 1 :=
calc sqrt x = 1 ↔ 1 * 1 = x :
  sqrt_eq_iff_mul_self_eq_of_pos zero_lt_one
... ↔ x = 1 : by rw [eq_comm, mul_one]

@[simp] theorem sq_sqrt (h : 0 ≤ x) : (sqrt x)^2 = x :=
by rw [sq, mul_self_sqrt h]

@[simp] theorem sqrt_sq (h : 0 ≤ x) : sqrt (x ^ 2) = x :=
by rw [sq, sqrt_mul_self h]

theorem sqrt_eq_iff_sq_eq (hx : 0 ≤ x) (hy : 0 ≤ y) :
  sqrt x = y ↔ y ^ 2 = x :=
by rw [sq, sqrt_eq_iff_mul_self_eq hx hy]

theorem sqrt_mul_self_eq_abs (x : ℝ) : sqrt (x * x) = |x| :=
by rw [← abs_mul_abs_self x, sqrt_mul_self (abs_nonneg _)]

theorem sqrt_sq_eq_abs (x : ℝ) : sqrt (x ^ 2) = |x| :=
by rw [sq, sqrt_mul_self_eq_abs]

@[simp] theorem sqrt_zero : sqrt 0 = 0 := by simp [sqrt]

@[simp] theorem sqrt_one : sqrt 1 = 1 := by simp [sqrt]

@[simp] theorem sqrt_le_sqrt_iff (hy : 0 ≤ y) : sqrt x ≤ sqrt y ↔ x ≤ y :=
by rw [sqrt, sqrt, nnreal.coe_le_coe, nnreal.sqrt_le_sqrt_iff, real.to_nnreal_le_to_nnreal_iff hy]

@[simp] theorem sqrt_lt_sqrt_iff (hx : 0 ≤ x) : sqrt x < sqrt y ↔ x < y :=
lt_iff_lt_of_le_iff_le (sqrt_le_sqrt_iff hx)

theorem sqrt_lt_sqrt_iff_of_pos (hy : 0 < y) : sqrt x < sqrt y ↔ x < y :=
by rw [sqrt, sqrt, nnreal.coe_lt_coe, nnreal.sqrt_lt_sqrt_iff, to_nnreal_lt_to_nnreal_iff hy]

theorem sqrt_le_sqrt (h : x ≤ y) : sqrt x ≤ sqrt y :=
by { rw [sqrt, sqrt, nnreal.coe_le_coe, nnreal.sqrt_le_sqrt_iff], exact to_nnreal_le_to_nnreal h }

theorem sqrt_lt_sqrt (hx : 0 ≤ x) (h : x < y) : sqrt x < sqrt y :=
(sqrt_lt_sqrt_iff hx).2 h

theorem sqrt_le_left (hy : 0 ≤ y) : sqrt x ≤ y ↔ x ≤ y ^ 2 :=
by rw [sqrt, ← real.le_to_nnreal_iff_coe_le hy, nnreal.sqrt_le_iff, sq, ← real.to_nnreal_mul hy,
  real.to_nnreal_le_to_nnreal_iff (mul_self_nonneg y), sq]

theorem sqrt_le_iff : sqrt x ≤ y ↔ 0 ≤ y ∧ x ≤ y ^ 2 :=
begin
  rw [← and_iff_right_of_imp (λ h, (sqrt_nonneg x).trans h), and.congr_right_iff],
  exact sqrt_le_left
end

lemma sqrt_lt (hx : 0 ≤ x) (hy : 0 ≤ y) : sqrt x < y ↔ x < y ^ 2 :=
by rw [←sqrt_lt_sqrt_iff hx, sqrt_sq hy]

lemma sqrt_lt' (hy : 0 < y) : sqrt x < y ↔ x < y ^ 2 :=
by rw [←sqrt_lt_sqrt_iff_of_pos (pow_pos hy _), sqrt_sq hy.le]

/- note: if you want to conclude `x ≤ sqrt y`, then use `le_sqrt_of_sq_le`.
   if you have `x > 0`, consider using `le_sqrt'` -/
theorem le_sqrt (hx : 0 ≤ x) (hy : 0 ≤ y) : x ≤ sqrt y ↔ x ^ 2 ≤ y :=
le_iff_le_iff_lt_iff_lt.2 $ sqrt_lt hy hx

lemma le_sqrt' (hx : 0 < x) : x ≤ sqrt y ↔ x ^ 2 ≤ y := le_iff_le_iff_lt_iff_lt.2 $ sqrt_lt' hx

theorem abs_le_sqrt (h : x^2 ≤ y) : |x| ≤ sqrt y :=
by rw ← sqrt_sq_eq_abs; exact sqrt_le_sqrt h

theorem sq_le (h : 0 ≤ y) : x^2 ≤ y ↔ -sqrt y ≤ x ∧ x ≤ sqrt y :=
begin
  split,
  { simpa only [abs_le] using abs_le_sqrt },
  { rw [← abs_le, ← sq_abs],
    exact (le_sqrt (abs_nonneg x) h).mp },
end

theorem neg_sqrt_le_of_sq_le (h : x^2 ≤ y) : -sqrt y ≤ x :=
((sq_le ((sq_nonneg x).trans h)).mp h).1

theorem le_sqrt_of_sq_le (h : x^2 ≤ y) : x ≤ sqrt y :=
((sq_le ((sq_nonneg x).trans h)).mp h).2

@[simp] theorem sqrt_inj (hx : 0 ≤ x) (hy : 0 ≤ y) : sqrt x = sqrt y ↔ x = y :=
by simp [le_antisymm_iff, hx, hy]

@[simp] theorem sqrt_eq_zero (h : 0 ≤ x) : sqrt x = 0 ↔ x = 0 :=
by simpa using sqrt_inj h le_rfl

theorem sqrt_eq_zero' : sqrt x = 0 ↔ x ≤ 0 :=
by rw [sqrt, nnreal.coe_eq_zero, nnreal.sqrt_eq_zero, real.to_nnreal_eq_zero]

theorem sqrt_ne_zero (h : 0 ≤ x) : sqrt x ≠ 0 ↔ x ≠ 0 :=
by rw [not_iff_not, sqrt_eq_zero h]

theorem sqrt_ne_zero' : sqrt x ≠ 0 ↔ 0 < x :=
by rw [← not_le, not_iff_not, sqrt_eq_zero']

@[simp] theorem sqrt_pos : 0 < sqrt x ↔ 0 < x :=
lt_iff_lt_of_le_iff_le (iff.trans
  (by simp [le_antisymm_iff, sqrt_nonneg]) sqrt_eq_zero')

alias sqrt_pos ↔ _ sqrt_pos_of_pos

section
open tactic tactic.positivity

/-- Extension for the `positivity` tactic: a square root is nonnegative, and is strictly positive if
its input is. -/
@[positivity]
meta def _root_.tactic.positivity_sqrt : expr → tactic strictness
| `(real.sqrt %%a) := do
  (do -- if can prove `0 < a`, report positivity
    positive pa ← core a,
    positive <$> mk_app ``sqrt_pos_of_pos [pa]) <|>
  nonnegative <$> mk_app ``sqrt_nonneg [a] -- else report nonnegativity
| _ := failed

end

@[simp] theorem sqrt_mul (hx : 0 ≤ x) (y : ℝ) : sqrt (x * y) = sqrt x * sqrt y :=
by simp_rw [sqrt, ← nnreal.coe_mul, nnreal.coe_eq, real.to_nnreal_mul hx, nnreal.sqrt_mul]

@[simp] theorem sqrt_mul' (x) {y : ℝ} (hy : 0 ≤ y) : sqrt (x * y) = sqrt x * sqrt y :=
by rw [mul_comm, sqrt_mul hy, mul_comm]

@[simp] theorem sqrt_inv (x : ℝ) : sqrt x⁻¹ = (sqrt x)⁻¹ :=
by rw [sqrt, real.to_nnreal_inv, nnreal.sqrt_inv, nnreal.coe_inv, sqrt]

@[simp] theorem sqrt_div (hx : 0 ≤ x) (y : ℝ) : sqrt (x / y) = sqrt x / sqrt y :=
by rw [division_def, sqrt_mul hx, sqrt_inv, division_def]

@[simp] theorem div_sqrt : x / sqrt x = sqrt x :=
begin
  cases le_or_lt x 0,
  { rw [sqrt_eq_zero'.mpr h, div_zero] },
  { rw [div_eq_iff (sqrt_ne_zero'.mpr h), mul_self_sqrt h.le] },
end

theorem sqrt_div_self' : sqrt x / x = 1 / sqrt x :=
by rw [←div_sqrt, one_div_div, div_sqrt]

theorem sqrt_div_self : sqrt x / x = (sqrt x)⁻¹ :=
by rw [sqrt_div_self', one_div]

lemma lt_sqrt (hx : 0 ≤ x) : x < sqrt y ↔ x ^ 2 < y :=
by rw [←sqrt_lt_sqrt_iff (sq_nonneg _), sqrt_sq hx]

lemma sq_lt : x^2 < y ↔ -sqrt y < x ∧ x < sqrt y := by rw [←abs_lt, ←sq_abs, lt_sqrt (abs_nonneg _)]

theorem neg_sqrt_lt_of_sq_lt (h : x^2 < y) : -sqrt y < x := (sq_lt.mp h).1

theorem lt_sqrt_of_sq_lt (h : x^2 < y) : x < sqrt y := (sq_lt.mp h).2

lemma lt_sq_of_sqrt_lt {x y : ℝ} (h : sqrt x < y) : x < y ^ 2 :=
by { have hy := x.sqrt_nonneg.trans_lt h,
  rwa [←sqrt_lt_sqrt_iff_of_pos (sq_pos_of_pos hy), sqrt_sq hy.le] }

/-- The natural square root is at most the real square root -/
lemma nat_sqrt_le_real_sqrt {a : ℕ} : ↑(nat.sqrt a) ≤ real.sqrt ↑a :=
begin
  rw real.le_sqrt (nat.cast_nonneg _) (nat.cast_nonneg _),
  norm_cast,
  exact nat.sqrt_le' a,
end

/-- The real square root is at most the natural square root plus one -/
lemma real_sqrt_le_nat_sqrt_succ {a : ℕ} : real.sqrt ↑a ≤ nat.sqrt a + 1 :=
begin
  rw real.sqrt_le_iff,
  split,
  { norm_cast, simp, },
  { norm_cast, exact le_of_lt (nat.lt_succ_sqrt' a), },
end

instance : star_ordered_ring ℝ :=
{ nonneg_iff := λ r, by
  { refine ⟨λ hr, ⟨sqrt r, show r = sqrt r * sqrt r, by rw [←sqrt_mul hr, sqrt_mul_self hr]⟩, _⟩,
    rintros ⟨s, rfl⟩,
    exact mul_self_nonneg s },
  ..real.ordered_add_comm_group }

end real

open real

variables {α : Type*}

lemma filter.tendsto.sqrt {f : α → ℝ} {l : filter α} {x : ℝ} (h : tendsto f l (𝓝 x)) :
  tendsto (λ x, sqrt (f x)) l (𝓝 (sqrt x)) :=
(continuous_sqrt.tendsto _).comp h

variables [topological_space α] {f : α → ℝ} {s : set α} {x : α}

lemma continuous_within_at.sqrt (h : continuous_within_at f s x) :
  continuous_within_at (λ x, sqrt (f x)) s x :=
h.sqrt

lemma continuous_at.sqrt (h : continuous_at f x) : continuous_at (λ x, sqrt (f x)) x := h.sqrt

lemma continuous_on.sqrt (h : continuous_on f s) : continuous_on (λ x, sqrt (f x)) s :=
λ x hx, (h x hx).sqrt

@[continuity]
lemma continuous.sqrt (h : continuous f) : continuous (λ x, sqrt (f x)) := continuous_sqrt.comp h
