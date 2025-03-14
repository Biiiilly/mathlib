/-
Copyright (c) 2018 Chris Hughes. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Hughes, Abhimanyu Pallavi Sudhir, Jean Lo, Calle Sönne, Benjamin Davidson
-/
import analysis.special_functions.exp_deriv
import analysis.special_functions.trigonometric.basic
import data.set.intervals.monotone

/-!
# Differentiability of trigonometric functions

## Main statements

The differentiability of the usual trigonometric functions is proved, and their derivatives are
computed.

## Tags

sin, cos, tan, angle
-/

noncomputable theory
open_locale classical topological_space filter
open set filter

namespace complex

/-- The complex sine function is everywhere strictly differentiable, with the derivative `cos x`. -/
lemma has_strict_deriv_at_sin (x : ℂ) : has_strict_deriv_at sin (cos x) x :=
begin
  simp only [cos, div_eq_mul_inv],
  convert ((((has_strict_deriv_at_id x).neg.mul_const I).cexp.sub
    ((has_strict_deriv_at_id x).mul_const I).cexp).mul_const I).mul_const (2:ℂ)⁻¹,
  simp only [function.comp, id],
  rw [sub_mul, mul_assoc, mul_assoc, I_mul_I, neg_one_mul, neg_neg, mul_one, one_mul, mul_assoc,
      I_mul_I, mul_neg_one, sub_neg_eq_add, add_comm]
end

/-- The complex sine function is everywhere differentiable, with the derivative `cos x`. -/
lemma has_deriv_at_sin (x : ℂ) : has_deriv_at sin (cos x) x :=
(has_strict_deriv_at_sin x).has_deriv_at

lemma cont_diff_sin {n} : cont_diff ℂ n sin :=
(((cont_diff_neg.mul cont_diff_const).cexp.sub
  (cont_diff_id.mul cont_diff_const).cexp).mul cont_diff_const).div_const

lemma differentiable_sin : differentiable ℂ sin :=
λx, (has_deriv_at_sin x).differentiable_at

lemma differentiable_at_sin {x : ℂ} : differentiable_at ℂ sin x :=
differentiable_sin x

@[simp] lemma deriv_sin : deriv sin = cos :=
funext $ λ x, (has_deriv_at_sin x).deriv

/-- The complex cosine function is everywhere strictly differentiable, with the derivative
`-sin x`. -/
lemma has_strict_deriv_at_cos (x : ℂ) : has_strict_deriv_at cos (-sin x) x :=
begin
  simp only [sin, div_eq_mul_inv, neg_mul_eq_neg_mul],
  convert (((has_strict_deriv_at_id x).mul_const I).cexp.add
    ((has_strict_deriv_at_id x).neg.mul_const I).cexp).mul_const (2:ℂ)⁻¹,
  simp only [function.comp, id],
  ring
end

/-- The complex cosine function is everywhere differentiable, with the derivative `-sin x`. -/
lemma has_deriv_at_cos (x : ℂ) : has_deriv_at cos (-sin x) x :=
(has_strict_deriv_at_cos x).has_deriv_at

lemma cont_diff_cos {n} : cont_diff ℂ n cos :=
((cont_diff_id.mul cont_diff_const).cexp.add
  (cont_diff_neg.mul cont_diff_const).cexp).div_const

lemma differentiable_cos : differentiable ℂ cos :=
λx, (has_deriv_at_cos x).differentiable_at

lemma differentiable_at_cos {x : ℂ} : differentiable_at ℂ cos x :=
differentiable_cos x

lemma deriv_cos {x : ℂ} : deriv cos x = -sin x :=
(has_deriv_at_cos x).deriv

@[simp] lemma deriv_cos' : deriv cos = (λ x, -sin x) :=
funext $ λ x, deriv_cos

/-- The complex hyperbolic sine function is everywhere strictly differentiable, with the derivative
`cosh x`. -/
lemma has_strict_deriv_at_sinh (x : ℂ) : has_strict_deriv_at sinh (cosh x) x :=
begin
  simp only [cosh, div_eq_mul_inv],
  convert ((has_strict_deriv_at_exp x).sub (has_strict_deriv_at_id x).neg.cexp).mul_const (2:ℂ)⁻¹,
  rw [id, mul_neg_one, sub_eq_add_neg, neg_neg]
end

/-- The complex hyperbolic sine function is everywhere differentiable, with the derivative
`cosh x`. -/
lemma has_deriv_at_sinh (x : ℂ) : has_deriv_at sinh (cosh x) x :=
(has_strict_deriv_at_sinh x).has_deriv_at

lemma cont_diff_sinh {n} : cont_diff ℂ n sinh :=
(cont_diff_exp.sub cont_diff_neg.cexp).div_const

lemma differentiable_sinh : differentiable ℂ sinh :=
λx, (has_deriv_at_sinh x).differentiable_at

lemma differentiable_at_sinh {x : ℂ} : differentiable_at ℂ sinh x :=
differentiable_sinh x

@[simp] lemma deriv_sinh : deriv sinh = cosh :=
funext $ λ x, (has_deriv_at_sinh x).deriv

/-- The complex hyperbolic cosine function is everywhere strictly differentiable, with the
derivative `sinh x`. -/
lemma has_strict_deriv_at_cosh (x : ℂ) : has_strict_deriv_at cosh (sinh x) x :=
begin
  simp only [sinh, div_eq_mul_inv],
  convert ((has_strict_deriv_at_exp x).add (has_strict_deriv_at_id x).neg.cexp).mul_const (2:ℂ)⁻¹,
  rw [id, mul_neg_one, sub_eq_add_neg]
end

/-- The complex hyperbolic cosine function is everywhere differentiable, with the derivative
`sinh x`. -/
lemma has_deriv_at_cosh (x : ℂ) : has_deriv_at cosh (sinh x) x :=
(has_strict_deriv_at_cosh x).has_deriv_at

lemma cont_diff_cosh {n} : cont_diff ℂ n cosh :=
(cont_diff_exp.add cont_diff_neg.cexp).div_const

lemma differentiable_cosh : differentiable ℂ cosh :=
λx, (has_deriv_at_cosh x).differentiable_at

lemma differentiable_at_cosh {x : ℂ} : differentiable_at ℂ cosh x :=
differentiable_cosh x

@[simp] lemma deriv_cosh : deriv cosh = sinh :=
funext $ λ x, (has_deriv_at_cosh x).deriv

end complex

section
/-! ### Simp lemmas for derivatives of `λ x, complex.cos (f x)` etc., `f : ℂ → ℂ` -/

variables {f : ℂ → ℂ} {f' x : ℂ} {s : set ℂ}

/-! #### `complex.cos` -/

lemma has_strict_deriv_at.ccos (hf : has_strict_deriv_at f f' x) :
  has_strict_deriv_at (λ x, complex.cos (f x)) (- complex.sin (f x) * f') x :=
(complex.has_strict_deriv_at_cos (f x)).comp x hf

lemma has_deriv_at.ccos (hf : has_deriv_at f f' x) :
  has_deriv_at (λ x, complex.cos (f x)) (- complex.sin (f x) * f') x :=
(complex.has_deriv_at_cos (f x)).comp x hf

lemma has_deriv_within_at.ccos (hf : has_deriv_within_at f f' s x) :
  has_deriv_within_at (λ x, complex.cos (f x)) (- complex.sin (f x) * f') s x :=
(complex.has_deriv_at_cos (f x)).comp_has_deriv_within_at x hf

lemma deriv_within_ccos (hf : differentiable_within_at ℂ f s x)
  (hxs : unique_diff_within_at ℂ s x) :
  deriv_within (λx, complex.cos (f x)) s x = - complex.sin (f x) * (deriv_within f s x) :=
hf.has_deriv_within_at.ccos.deriv_within hxs

@[simp] lemma deriv_ccos (hc : differentiable_at ℂ f x) :
  deriv (λx, complex.cos (f x)) x = - complex.sin (f x) * (deriv f x) :=
hc.has_deriv_at.ccos.deriv

/-! #### `complex.sin` -/

lemma has_strict_deriv_at.csin (hf : has_strict_deriv_at f f' x) :
  has_strict_deriv_at (λ x, complex.sin (f x)) (complex.cos (f x) * f') x :=
(complex.has_strict_deriv_at_sin (f x)).comp x hf

lemma has_deriv_at.csin (hf : has_deriv_at f f' x) :
  has_deriv_at (λ x, complex.sin (f x)) (complex.cos (f x) * f') x :=
(complex.has_deriv_at_sin (f x)).comp x hf

lemma has_deriv_within_at.csin (hf : has_deriv_within_at f f' s x) :
  has_deriv_within_at (λ x, complex.sin (f x)) (complex.cos (f x) * f') s x :=
(complex.has_deriv_at_sin (f x)).comp_has_deriv_within_at x hf

lemma deriv_within_csin (hf : differentiable_within_at ℂ f s x)
  (hxs : unique_diff_within_at ℂ s x) :
  deriv_within (λx, complex.sin (f x)) s x = complex.cos (f x) * (deriv_within f s x) :=
hf.has_deriv_within_at.csin.deriv_within hxs

@[simp] lemma deriv_csin (hc : differentiable_at ℂ f x) :
  deriv (λx, complex.sin (f x)) x = complex.cos (f x) * (deriv f x) :=
hc.has_deriv_at.csin.deriv

/-! #### `complex.cosh` -/

lemma has_strict_deriv_at.ccosh (hf : has_strict_deriv_at f f' x) :
  has_strict_deriv_at (λ x, complex.cosh (f x)) (complex.sinh (f x) * f') x :=
(complex.has_strict_deriv_at_cosh (f x)).comp x hf

lemma has_deriv_at.ccosh (hf : has_deriv_at f f' x) :
  has_deriv_at (λ x, complex.cosh (f x)) (complex.sinh (f x) * f') x :=
(complex.has_deriv_at_cosh (f x)).comp x hf

lemma has_deriv_within_at.ccosh (hf : has_deriv_within_at f f' s x) :
  has_deriv_within_at (λ x, complex.cosh (f x)) (complex.sinh (f x) * f') s x :=
(complex.has_deriv_at_cosh (f x)).comp_has_deriv_within_at x hf

lemma deriv_within_ccosh (hf : differentiable_within_at ℂ f s x)
  (hxs : unique_diff_within_at ℂ s x) :
  deriv_within (λx, complex.cosh (f x)) s x = complex.sinh (f x) * (deriv_within f s x) :=
hf.has_deriv_within_at.ccosh.deriv_within hxs

@[simp] lemma deriv_ccosh (hc : differentiable_at ℂ f x) :
  deriv (λx, complex.cosh (f x)) x = complex.sinh (f x) * (deriv f x) :=
hc.has_deriv_at.ccosh.deriv

/-! #### `complex.sinh` -/

lemma has_strict_deriv_at.csinh (hf : has_strict_deriv_at f f' x) :
  has_strict_deriv_at (λ x, complex.sinh (f x)) (complex.cosh (f x) * f') x :=
(complex.has_strict_deriv_at_sinh (f x)).comp x hf

lemma has_deriv_at.csinh (hf : has_deriv_at f f' x) :
  has_deriv_at (λ x, complex.sinh (f x)) (complex.cosh (f x) * f') x :=
(complex.has_deriv_at_sinh (f x)).comp x hf

lemma has_deriv_within_at.csinh (hf : has_deriv_within_at f f' s x) :
  has_deriv_within_at (λ x, complex.sinh (f x)) (complex.cosh (f x) * f') s x :=
(complex.has_deriv_at_sinh (f x)).comp_has_deriv_within_at x hf

lemma deriv_within_csinh (hf : differentiable_within_at ℂ f s x)
  (hxs : unique_diff_within_at ℂ s x) :
  deriv_within (λx, complex.sinh (f x)) s x = complex.cosh (f x) * (deriv_within f s x) :=
hf.has_deriv_within_at.csinh.deriv_within hxs

@[simp] lemma deriv_csinh (hc : differentiable_at ℂ f x) :
  deriv (λx, complex.sinh (f x)) x = complex.cosh (f x) * (deriv f x) :=
hc.has_deriv_at.csinh.deriv

end

section
/-! ### Simp lemmas for derivatives of `λ x, complex.cos (f x)` etc., `f : E → ℂ` -/

variables {E : Type*} [normed_add_comm_group E] [normed_space ℂ E] {f : E → ℂ} {f' : E →L[ℂ] ℂ}
  {x : E} {s : set E}

/-! #### `complex.cos` -/

lemma has_strict_fderiv_at.ccos (hf : has_strict_fderiv_at f f' x) :
  has_strict_fderiv_at (λ x, complex.cos (f x)) (- complex.sin (f x) • f') x :=
(complex.has_strict_deriv_at_cos (f x)).comp_has_strict_fderiv_at x hf

lemma has_fderiv_at.ccos (hf : has_fderiv_at f f' x) :
  has_fderiv_at (λ x, complex.cos (f x)) (- complex.sin (f x) • f') x :=
(complex.has_deriv_at_cos (f x)).comp_has_fderiv_at x hf

lemma has_fderiv_within_at.ccos (hf : has_fderiv_within_at f f' s x) :
  has_fderiv_within_at (λ x, complex.cos (f x)) (- complex.sin (f x) • f') s x :=
(complex.has_deriv_at_cos (f x)).comp_has_fderiv_within_at x hf

lemma differentiable_within_at.ccos (hf : differentiable_within_at ℂ f s x) :
  differentiable_within_at ℂ (λ x, complex.cos (f x)) s x :=
hf.has_fderiv_within_at.ccos.differentiable_within_at

@[simp] lemma differentiable_at.ccos (hc : differentiable_at ℂ f x) :
  differentiable_at ℂ (λx, complex.cos (f x)) x :=
hc.has_fderiv_at.ccos.differentiable_at

lemma differentiable_on.ccos (hc : differentiable_on ℂ f s) :
  differentiable_on ℂ (λx, complex.cos (f x)) s :=
λx h, (hc x h).ccos

@[simp] lemma differentiable.ccos (hc : differentiable ℂ f) :
  differentiable ℂ (λx, complex.cos (f x)) :=
λx, (hc x).ccos

lemma fderiv_within_ccos (hf : differentiable_within_at ℂ f s x)
  (hxs : unique_diff_within_at ℂ s x) :
  fderiv_within ℂ (λx, complex.cos (f x)) s x = - complex.sin (f x) • (fderiv_within ℂ f s x) :=
hf.has_fderiv_within_at.ccos.fderiv_within hxs

@[simp] lemma fderiv_ccos (hc : differentiable_at ℂ f x) :
  fderiv ℂ (λx, complex.cos (f x)) x = - complex.sin (f x) • (fderiv ℂ f x) :=
hc.has_fderiv_at.ccos.fderiv

lemma cont_diff.ccos {n} (h : cont_diff ℂ n f) :
  cont_diff ℂ n (λ x, complex.cos (f x)) :=
complex.cont_diff_cos.comp h

lemma cont_diff_at.ccos {n} (hf : cont_diff_at ℂ n f x) :
  cont_diff_at ℂ n (λ x, complex.cos (f x)) x :=
complex.cont_diff_cos.cont_diff_at.comp x hf

lemma cont_diff_on.ccos {n} (hf : cont_diff_on ℂ n f s) :
  cont_diff_on ℂ n (λ x, complex.cos (f x)) s :=
complex.cont_diff_cos.comp_cont_diff_on  hf

lemma cont_diff_within_at.ccos {n} (hf : cont_diff_within_at ℂ n f s x) :
  cont_diff_within_at ℂ n (λ x, complex.cos (f x)) s x :=
complex.cont_diff_cos.cont_diff_at.comp_cont_diff_within_at x hf

/-! #### `complex.sin` -/

lemma has_strict_fderiv_at.csin (hf : has_strict_fderiv_at f f' x) :
  has_strict_fderiv_at (λ x, complex.sin (f x)) (complex.cos (f x) • f') x :=
(complex.has_strict_deriv_at_sin (f x)).comp_has_strict_fderiv_at x hf

lemma has_fderiv_at.csin (hf : has_fderiv_at f f' x) :
  has_fderiv_at (λ x, complex.sin (f x)) (complex.cos (f x) • f') x :=
(complex.has_deriv_at_sin (f x)).comp_has_fderiv_at x hf

lemma has_fderiv_within_at.csin (hf : has_fderiv_within_at f f' s x) :
  has_fderiv_within_at (λ x, complex.sin (f x)) (complex.cos (f x) • f') s x :=
(complex.has_deriv_at_sin (f x)).comp_has_fderiv_within_at x hf

lemma differentiable_within_at.csin (hf : differentiable_within_at ℂ f s x) :
  differentiable_within_at ℂ (λ x, complex.sin (f x)) s x :=
hf.has_fderiv_within_at.csin.differentiable_within_at

@[simp] lemma differentiable_at.csin (hc : differentiable_at ℂ f x) :
  differentiable_at ℂ (λx, complex.sin (f x)) x :=
hc.has_fderiv_at.csin.differentiable_at

lemma differentiable_on.csin (hc : differentiable_on ℂ f s) :
  differentiable_on ℂ (λx, complex.sin (f x)) s :=
λx h, (hc x h).csin

@[simp] lemma differentiable.csin (hc : differentiable ℂ f) :
  differentiable ℂ (λx, complex.sin (f x)) :=
λx, (hc x).csin

lemma fderiv_within_csin (hf : differentiable_within_at ℂ f s x)
  (hxs : unique_diff_within_at ℂ s x) :
  fderiv_within ℂ (λx, complex.sin (f x)) s x = complex.cos (f x) • (fderiv_within ℂ f s x) :=
hf.has_fderiv_within_at.csin.fderiv_within hxs

@[simp] lemma fderiv_csin (hc : differentiable_at ℂ f x) :
  fderiv ℂ (λx, complex.sin (f x)) x = complex.cos (f x) • (fderiv ℂ f x) :=
hc.has_fderiv_at.csin.fderiv

lemma cont_diff.csin {n} (h : cont_diff ℂ n f) :
  cont_diff ℂ n (λ x, complex.sin (f x)) :=
complex.cont_diff_sin.comp h

lemma cont_diff_at.csin {n} (hf : cont_diff_at ℂ n f x) :
  cont_diff_at ℂ n (λ x, complex.sin (f x)) x :=
complex.cont_diff_sin.cont_diff_at.comp x hf

lemma cont_diff_on.csin {n} (hf : cont_diff_on ℂ n f s) :
  cont_diff_on ℂ n (λ x, complex.sin (f x)) s :=
complex.cont_diff_sin.comp_cont_diff_on  hf

lemma cont_diff_within_at.csin {n} (hf : cont_diff_within_at ℂ n f s x) :
  cont_diff_within_at ℂ n (λ x, complex.sin (f x)) s x :=
complex.cont_diff_sin.cont_diff_at.comp_cont_diff_within_at x hf

/-! #### `complex.cosh` -/

lemma has_strict_fderiv_at.ccosh (hf : has_strict_fderiv_at f f' x) :
  has_strict_fderiv_at (λ x, complex.cosh (f x)) (complex.sinh (f x) • f') x :=
(complex.has_strict_deriv_at_cosh (f x)).comp_has_strict_fderiv_at x hf

lemma has_fderiv_at.ccosh (hf : has_fderiv_at f f' x) :
  has_fderiv_at (λ x, complex.cosh (f x)) (complex.sinh (f x) • f') x :=
(complex.has_deriv_at_cosh (f x)).comp_has_fderiv_at x hf

lemma has_fderiv_within_at.ccosh (hf : has_fderiv_within_at f f' s x) :
  has_fderiv_within_at (λ x, complex.cosh (f x)) (complex.sinh (f x) • f') s x :=
(complex.has_deriv_at_cosh (f x)).comp_has_fderiv_within_at x hf

lemma differentiable_within_at.ccosh (hf : differentiable_within_at ℂ f s x) :
  differentiable_within_at ℂ (λ x, complex.cosh (f x)) s x :=
hf.has_fderiv_within_at.ccosh.differentiable_within_at

@[simp] lemma differentiable_at.ccosh (hc : differentiable_at ℂ f x) :
  differentiable_at ℂ (λx, complex.cosh (f x)) x :=
hc.has_fderiv_at.ccosh.differentiable_at

lemma differentiable_on.ccosh (hc : differentiable_on ℂ f s) :
  differentiable_on ℂ (λx, complex.cosh (f x)) s :=
λx h, (hc x h).ccosh

@[simp] lemma differentiable.ccosh (hc : differentiable ℂ f) :
  differentiable ℂ (λx, complex.cosh (f x)) :=
λx, (hc x).ccosh

lemma fderiv_within_ccosh (hf : differentiable_within_at ℂ f s x)
  (hxs : unique_diff_within_at ℂ s x) :
  fderiv_within ℂ (λx, complex.cosh (f x)) s x = complex.sinh (f x) • (fderiv_within ℂ f s x) :=
hf.has_fderiv_within_at.ccosh.fderiv_within hxs

@[simp] lemma fderiv_ccosh (hc : differentiable_at ℂ f x) :
  fderiv ℂ (λx, complex.cosh (f x)) x = complex.sinh (f x) • (fderiv ℂ f x) :=
hc.has_fderiv_at.ccosh.fderiv

lemma cont_diff.ccosh {n} (h : cont_diff ℂ n f) :
  cont_diff ℂ n (λ x, complex.cosh (f x)) :=
complex.cont_diff_cosh.comp h

lemma cont_diff_at.ccosh {n} (hf : cont_diff_at ℂ n f x) :
  cont_diff_at ℂ n (λ x, complex.cosh (f x)) x :=
complex.cont_diff_cosh.cont_diff_at.comp x hf

lemma cont_diff_on.ccosh {n} (hf : cont_diff_on ℂ n f s) :
  cont_diff_on ℂ n (λ x, complex.cosh (f x)) s :=
complex.cont_diff_cosh.comp_cont_diff_on  hf

lemma cont_diff_within_at.ccosh {n} (hf : cont_diff_within_at ℂ n f s x) :
  cont_diff_within_at ℂ n (λ x, complex.cosh (f x)) s x :=
complex.cont_diff_cosh.cont_diff_at.comp_cont_diff_within_at x hf

/-! #### `complex.sinh` -/

lemma has_strict_fderiv_at.csinh (hf : has_strict_fderiv_at f f' x) :
  has_strict_fderiv_at (λ x, complex.sinh (f x)) (complex.cosh (f x) • f') x :=
(complex.has_strict_deriv_at_sinh (f x)).comp_has_strict_fderiv_at x hf

lemma has_fderiv_at.csinh (hf : has_fderiv_at f f' x) :
  has_fderiv_at (λ x, complex.sinh (f x)) (complex.cosh (f x) • f') x :=
(complex.has_deriv_at_sinh (f x)).comp_has_fderiv_at x hf

lemma has_fderiv_within_at.csinh (hf : has_fderiv_within_at f f' s x) :
  has_fderiv_within_at (λ x, complex.sinh (f x)) (complex.cosh (f x) • f') s x :=
(complex.has_deriv_at_sinh (f x)).comp_has_fderiv_within_at x hf

lemma differentiable_within_at.csinh (hf : differentiable_within_at ℂ f s x) :
  differentiable_within_at ℂ (λ x, complex.sinh (f x)) s x :=
hf.has_fderiv_within_at.csinh.differentiable_within_at

@[simp] lemma differentiable_at.csinh (hc : differentiable_at ℂ f x) :
  differentiable_at ℂ (λx, complex.sinh (f x)) x :=
hc.has_fderiv_at.csinh.differentiable_at

lemma differentiable_on.csinh (hc : differentiable_on ℂ f s) :
  differentiable_on ℂ (λx, complex.sinh (f x)) s :=
λx h, (hc x h).csinh

@[simp] lemma differentiable.csinh (hc : differentiable ℂ f) :
  differentiable ℂ (λx, complex.sinh (f x)) :=
λx, (hc x).csinh

lemma fderiv_within_csinh (hf : differentiable_within_at ℂ f s x)
  (hxs : unique_diff_within_at ℂ s x) :
  fderiv_within ℂ (λx, complex.sinh (f x)) s x = complex.cosh (f x) • (fderiv_within ℂ f s x) :=
hf.has_fderiv_within_at.csinh.fderiv_within hxs

@[simp] lemma fderiv_csinh (hc : differentiable_at ℂ f x) :
  fderiv ℂ (λx, complex.sinh (f x)) x = complex.cosh (f x) • (fderiv ℂ f x) :=
hc.has_fderiv_at.csinh.fderiv

lemma cont_diff.csinh {n} (h : cont_diff ℂ n f) :
  cont_diff ℂ n (λ x, complex.sinh (f x)) :=
complex.cont_diff_sinh.comp h

lemma cont_diff_at.csinh {n} (hf : cont_diff_at ℂ n f x) :
  cont_diff_at ℂ n (λ x, complex.sinh (f x)) x :=
complex.cont_diff_sinh.cont_diff_at.comp x hf

lemma cont_diff_on.csinh {n} (hf : cont_diff_on ℂ n f s) :
  cont_diff_on ℂ n (λ x, complex.sinh (f x)) s :=
complex.cont_diff_sinh.comp_cont_diff_on  hf

lemma cont_diff_within_at.csinh {n} (hf : cont_diff_within_at ℂ n f s x) :
  cont_diff_within_at ℂ n (λ x, complex.sinh (f x)) s x :=
complex.cont_diff_sinh.cont_diff_at.comp_cont_diff_within_at x hf

end

namespace real

variables {x y z : ℝ}

lemma has_strict_deriv_at_sin (x : ℝ) : has_strict_deriv_at sin (cos x) x :=
(complex.has_strict_deriv_at_sin x).real_of_complex

lemma has_deriv_at_sin (x : ℝ) : has_deriv_at sin (cos x) x :=
(has_strict_deriv_at_sin x).has_deriv_at

lemma cont_diff_sin {n} : cont_diff ℝ n sin :=
complex.cont_diff_sin.real_of_complex

lemma differentiable_sin : differentiable ℝ sin :=
λx, (has_deriv_at_sin x).differentiable_at

lemma differentiable_at_sin : differentiable_at ℝ sin x :=
differentiable_sin x

@[simp] lemma deriv_sin : deriv sin = cos :=
funext $ λ x, (has_deriv_at_sin x).deriv

lemma has_strict_deriv_at_cos (x : ℝ) : has_strict_deriv_at cos (-sin x) x :=
(complex.has_strict_deriv_at_cos x).real_of_complex

lemma has_deriv_at_cos (x : ℝ) : has_deriv_at cos (-sin x) x :=
(complex.has_deriv_at_cos x).real_of_complex

lemma cont_diff_cos {n} : cont_diff ℝ n cos :=
complex.cont_diff_cos.real_of_complex

lemma differentiable_cos : differentiable ℝ cos :=
λx, (has_deriv_at_cos x).differentiable_at

lemma differentiable_at_cos : differentiable_at ℝ cos x :=
differentiable_cos x

lemma deriv_cos : deriv cos x = - sin x :=
(has_deriv_at_cos x).deriv

@[simp] lemma deriv_cos' : deriv cos = (λ x, - sin x) :=
funext $ λ _, deriv_cos

lemma has_strict_deriv_at_sinh (x : ℝ) : has_strict_deriv_at sinh (cosh x) x :=
(complex.has_strict_deriv_at_sinh x).real_of_complex

lemma has_deriv_at_sinh (x : ℝ) : has_deriv_at sinh (cosh x) x :=
(complex.has_deriv_at_sinh x).real_of_complex

lemma cont_diff_sinh {n} : cont_diff ℝ n sinh :=
complex.cont_diff_sinh.real_of_complex

lemma differentiable_sinh : differentiable ℝ sinh :=
λx, (has_deriv_at_sinh x).differentiable_at

lemma differentiable_at_sinh : differentiable_at ℝ sinh x :=
differentiable_sinh x

@[simp] lemma deriv_sinh : deriv sinh = cosh :=
funext $ λ x, (has_deriv_at_sinh x).deriv

lemma has_strict_deriv_at_cosh (x : ℝ) : has_strict_deriv_at cosh (sinh x) x :=
(complex.has_strict_deriv_at_cosh x).real_of_complex

lemma has_deriv_at_cosh (x : ℝ) : has_deriv_at cosh (sinh x) x :=
(complex.has_deriv_at_cosh x).real_of_complex

lemma cont_diff_cosh {n} : cont_diff ℝ n cosh :=
complex.cont_diff_cosh.real_of_complex

lemma differentiable_cosh : differentiable ℝ cosh :=
λx, (has_deriv_at_cosh x).differentiable_at

lemma differentiable_at_cosh : differentiable_at ℝ cosh x :=
differentiable_cosh x

@[simp] lemma deriv_cosh : deriv cosh = sinh :=
funext $ λ x, (has_deriv_at_cosh x).deriv

/-- `sinh` is strictly monotone. -/
lemma sinh_strict_mono : strict_mono sinh :=
strict_mono_of_deriv_pos $ by { rw real.deriv_sinh, exact cosh_pos }

/-- `sinh` is injective, `∀ a b, sinh a = sinh b → a = b`. -/
lemma sinh_injective : function.injective sinh := sinh_strict_mono.injective

@[simp] lemma sinh_inj : sinh x = sinh y ↔ x = y := sinh_injective.eq_iff
@[simp] lemma sinh_le_sinh : sinh x ≤ sinh y ↔ x ≤ y := sinh_strict_mono.le_iff_le
@[simp] lemma sinh_lt_sinh : sinh x < sinh y ↔ x < y := sinh_strict_mono.lt_iff_lt

@[simp] lemma sinh_pos_iff : 0 < sinh x ↔ 0 < x :=
by simpa only [sinh_zero] using @sinh_lt_sinh 0 x

@[simp] lemma sinh_nonpos_iff : sinh x ≤ 0 ↔ x ≤ 0 :=
by simpa only [sinh_zero] using @sinh_le_sinh x 0

@[simp] lemma sinh_neg_iff : sinh x < 0 ↔ x < 0 :=
by simpa only [sinh_zero] using @sinh_lt_sinh x 0

@[simp] lemma sinh_nonneg_iff : 0 ≤ sinh x ↔ 0 ≤ x :=
by simpa only [sinh_zero] using @sinh_le_sinh 0 x

lemma abs_sinh (x : ℝ) : |sinh x| = sinh (|x|) :=
by cases le_total x 0; simp [abs_of_nonneg, abs_of_nonpos, *]

lemma cosh_strict_mono_on : strict_mono_on cosh (Ici 0) :=
(convex_Ici _).strict_mono_on_of_deriv_pos continuous_cosh.continuous_on $ λ x hx,
  by { rw [interior_Ici, mem_Ioi] at hx, rwa [deriv_cosh, sinh_pos_iff] }

@[simp] lemma cosh_le_cosh : cosh x ≤ cosh y ↔ |x| ≤ |y| :=
cosh_abs x ▸ cosh_abs y ▸ cosh_strict_mono_on.le_iff_le (_root_.abs_nonneg x) (_root_.abs_nonneg y)

@[simp] lemma cosh_lt_cosh : cosh x < cosh y ↔ |x| < |y| :=
lt_iff_lt_of_le_iff_le cosh_le_cosh

@[simp] lemma one_le_cosh (x : ℝ) : 1 ≤ cosh x :=
cosh_zero ▸ cosh_le_cosh.2 (by simp only [_root_.abs_zero, _root_.abs_nonneg])

@[simp] lemma one_lt_cosh : 1 < cosh x ↔ x ≠ 0 :=
cosh_zero ▸ cosh_lt_cosh.trans (by simp only [_root_.abs_zero, abs_pos])

lemma sinh_sub_id_strict_mono : strict_mono (λ x, sinh x - x) :=
begin
  refine strict_mono_of_odd_strict_mono_on_nonneg (λ x, by simp) _,
  refine (convex_Ici _).strict_mono_on_of_deriv_pos _ (λ x hx, _),
  { exact (continuous_sinh.sub continuous_id).continuous_on },
  { rw [interior_Ici, mem_Ioi] at hx,
    rw [deriv_sub, deriv_sinh, deriv_id'', sub_pos, one_lt_cosh],
    exacts [hx.ne', differentiable_at_sinh, differentiable_at_id] }
end

@[simp] lemma self_le_sinh_iff : x ≤ sinh x ↔ 0 ≤ x :=
calc x ≤ sinh x ↔ sinh 0 - 0 ≤ sinh x - x : by simp
... ↔ 0 ≤ x : sinh_sub_id_strict_mono.le_iff_le

@[simp] lemma sinh_le_self_iff : sinh x ≤ x ↔ x ≤ 0 :=
calc sinh x ≤ x ↔ sinh x - x ≤ sinh 0 - 0 : by simp
... ↔ x ≤ 0 : sinh_sub_id_strict_mono.le_iff_le

@[simp] lemma self_lt_sinh_iff : x < sinh x ↔ 0 < x :=
lt_iff_lt_of_le_iff_le sinh_le_self_iff

@[simp] lemma sinh_lt_self_iff : sinh x < x ↔ x < 0 :=
lt_iff_lt_of_le_iff_le self_le_sinh_iff

end real

section
/-! ### Simp lemmas for derivatives of `λ x, real.cos (f x)` etc., `f : ℝ → ℝ` -/

variables {f : ℝ → ℝ} {f' x : ℝ} {s : set ℝ}

/-! #### `real.cos` -/

lemma has_strict_deriv_at.cos (hf : has_strict_deriv_at f f' x) :
  has_strict_deriv_at (λ x, real.cos (f x)) (- real.sin (f x) * f') x :=
(real.has_strict_deriv_at_cos (f x)).comp x hf

lemma has_deriv_at.cos (hf : has_deriv_at f f' x) :
  has_deriv_at (λ x, real.cos (f x)) (- real.sin (f x) * f') x :=
(real.has_deriv_at_cos (f x)).comp x hf

lemma has_deriv_within_at.cos (hf : has_deriv_within_at f f' s x) :
  has_deriv_within_at (λ x, real.cos (f x)) (- real.sin (f x) * f') s x :=
(real.has_deriv_at_cos (f x)).comp_has_deriv_within_at x hf

lemma deriv_within_cos (hf : differentiable_within_at ℝ f s x)
  (hxs : unique_diff_within_at ℝ s x) :
  deriv_within (λx, real.cos (f x)) s x = - real.sin (f x) * (deriv_within f s x) :=
hf.has_deriv_within_at.cos.deriv_within hxs

@[simp] lemma deriv_cos (hc : differentiable_at ℝ f x) :
  deriv (λx, real.cos (f x)) x = - real.sin (f x) * (deriv f x) :=
hc.has_deriv_at.cos.deriv

/-! #### `real.sin` -/

lemma has_strict_deriv_at.sin (hf : has_strict_deriv_at f f' x) :
  has_strict_deriv_at (λ x, real.sin (f x)) (real.cos (f x) * f') x :=
(real.has_strict_deriv_at_sin (f x)).comp x hf

lemma has_deriv_at.sin (hf : has_deriv_at f f' x) :
  has_deriv_at (λ x, real.sin (f x)) (real.cos (f x) * f') x :=
(real.has_deriv_at_sin (f x)).comp x hf

lemma has_deriv_within_at.sin (hf : has_deriv_within_at f f' s x) :
  has_deriv_within_at (λ x, real.sin (f x)) (real.cos (f x) * f') s x :=
(real.has_deriv_at_sin (f x)).comp_has_deriv_within_at x hf

lemma deriv_within_sin (hf : differentiable_within_at ℝ f s x)
  (hxs : unique_diff_within_at ℝ s x) :
  deriv_within (λx, real.sin (f x)) s x = real.cos (f x) * (deriv_within f s x) :=
hf.has_deriv_within_at.sin.deriv_within hxs

@[simp] lemma deriv_sin (hc : differentiable_at ℝ f x) :
  deriv (λx, real.sin (f x)) x = real.cos (f x) * (deriv f x) :=
hc.has_deriv_at.sin.deriv

/-! #### `real.cosh` -/

lemma has_strict_deriv_at.cosh (hf : has_strict_deriv_at f f' x) :
  has_strict_deriv_at (λ x, real.cosh (f x)) (real.sinh (f x) * f') x :=
(real.has_strict_deriv_at_cosh (f x)).comp x hf

lemma has_deriv_at.cosh (hf : has_deriv_at f f' x) :
  has_deriv_at (λ x, real.cosh (f x)) (real.sinh (f x) * f') x :=
(real.has_deriv_at_cosh (f x)).comp x hf

lemma has_deriv_within_at.cosh (hf : has_deriv_within_at f f' s x) :
  has_deriv_within_at (λ x, real.cosh (f x)) (real.sinh (f x) * f') s x :=
(real.has_deriv_at_cosh (f x)).comp_has_deriv_within_at x hf

lemma deriv_within_cosh (hf : differentiable_within_at ℝ f s x)
  (hxs : unique_diff_within_at ℝ s x) :
  deriv_within (λx, real.cosh (f x)) s x = real.sinh (f x) * (deriv_within f s x) :=
hf.has_deriv_within_at.cosh.deriv_within hxs

@[simp] lemma deriv_cosh (hc : differentiable_at ℝ f x) :
  deriv (λx, real.cosh (f x)) x = real.sinh (f x) * (deriv f x) :=
hc.has_deriv_at.cosh.deriv

/-! #### `real.sinh` -/

lemma has_strict_deriv_at.sinh (hf : has_strict_deriv_at f f' x) :
  has_strict_deriv_at (λ x, real.sinh (f x)) (real.cosh (f x) * f') x :=
(real.has_strict_deriv_at_sinh (f x)).comp x hf

lemma has_deriv_at.sinh (hf : has_deriv_at f f' x) :
  has_deriv_at (λ x, real.sinh (f x)) (real.cosh (f x) * f') x :=
(real.has_deriv_at_sinh (f x)).comp x hf

lemma has_deriv_within_at.sinh (hf : has_deriv_within_at f f' s x) :
  has_deriv_within_at (λ x, real.sinh (f x)) (real.cosh (f x) * f') s x :=
(real.has_deriv_at_sinh (f x)).comp_has_deriv_within_at x hf

lemma deriv_within_sinh (hf : differentiable_within_at ℝ f s x)
  (hxs : unique_diff_within_at ℝ s x) :
  deriv_within (λx, real.sinh (f x)) s x = real.cosh (f x) * (deriv_within f s x) :=
hf.has_deriv_within_at.sinh.deriv_within hxs

@[simp] lemma deriv_sinh (hc : differentiable_at ℝ f x) :
  deriv (λx, real.sinh (f x)) x = real.cosh (f x) * (deriv f x) :=
hc.has_deriv_at.sinh.deriv

end

section

/-! ### Simp lemmas for derivatives of `λ x, real.cos (f x)` etc., `f : E → ℝ` -/

variables {E : Type*} [normed_add_comm_group E] [normed_space ℝ E] {f : E → ℝ} {f' : E →L[ℝ] ℝ}
  {x : E} {s : set E}

/-! #### `real.cos` -/

lemma has_strict_fderiv_at.cos (hf : has_strict_fderiv_at f f' x) :
  has_strict_fderiv_at (λ x, real.cos (f x)) (- real.sin (f x) • f') x :=
(real.has_strict_deriv_at_cos (f x)).comp_has_strict_fderiv_at x hf

lemma has_fderiv_at.cos (hf : has_fderiv_at f f' x) :
  has_fderiv_at (λ x, real.cos (f x)) (- real.sin (f x) • f') x :=
(real.has_deriv_at_cos (f x)).comp_has_fderiv_at x hf

lemma has_fderiv_within_at.cos (hf : has_fderiv_within_at f f' s x) :
  has_fderiv_within_at (λ x, real.cos (f x)) (- real.sin (f x) • f') s x :=
(real.has_deriv_at_cos (f x)).comp_has_fderiv_within_at x hf

lemma differentiable_within_at.cos (hf : differentiable_within_at ℝ f s x) :
  differentiable_within_at ℝ (λ x, real.cos (f x)) s x :=
hf.has_fderiv_within_at.cos.differentiable_within_at

@[simp] lemma differentiable_at.cos (hc : differentiable_at ℝ f x) :
  differentiable_at ℝ (λx, real.cos (f x)) x :=
hc.has_fderiv_at.cos.differentiable_at

lemma differentiable_on.cos (hc : differentiable_on ℝ f s) :
  differentiable_on ℝ (λx, real.cos (f x)) s :=
λx h, (hc x h).cos

@[simp] lemma differentiable.cos (hc : differentiable ℝ f) :
  differentiable ℝ (λx, real.cos (f x)) :=
λx, (hc x).cos

lemma fderiv_within_cos (hf : differentiable_within_at ℝ f s x)
  (hxs : unique_diff_within_at ℝ s x) :
  fderiv_within ℝ (λx, real.cos (f x)) s x = - real.sin (f x) • (fderiv_within ℝ f s x) :=
hf.has_fderiv_within_at.cos.fderiv_within hxs

@[simp] lemma fderiv_cos (hc : differentiable_at ℝ f x) :
  fderiv ℝ (λx, real.cos (f x)) x = - real.sin (f x) • (fderiv ℝ f x) :=
hc.has_fderiv_at.cos.fderiv

lemma cont_diff.cos {n} (h : cont_diff ℝ n f) :
  cont_diff ℝ n (λ x, real.cos (f x)) :=
real.cont_diff_cos.comp h

lemma cont_diff_at.cos {n} (hf : cont_diff_at ℝ n f x) :
  cont_diff_at ℝ n (λ x, real.cos (f x)) x :=
real.cont_diff_cos.cont_diff_at.comp x hf

lemma cont_diff_on.cos {n} (hf : cont_diff_on ℝ n f s) :
  cont_diff_on ℝ n (λ x, real.cos (f x)) s :=
real.cont_diff_cos.comp_cont_diff_on  hf

lemma cont_diff_within_at.cos {n} (hf : cont_diff_within_at ℝ n f s x) :
  cont_diff_within_at ℝ n (λ x, real.cos (f x)) s x :=
real.cont_diff_cos.cont_diff_at.comp_cont_diff_within_at x hf

/-! #### `real.sin` -/

lemma has_strict_fderiv_at.sin (hf : has_strict_fderiv_at f f' x) :
  has_strict_fderiv_at (λ x, real.sin (f x)) (real.cos (f x) • f') x :=
(real.has_strict_deriv_at_sin (f x)).comp_has_strict_fderiv_at x hf

lemma has_fderiv_at.sin (hf : has_fderiv_at f f' x) :
  has_fderiv_at (λ x, real.sin (f x)) (real.cos (f x) • f') x :=
(real.has_deriv_at_sin (f x)).comp_has_fderiv_at x hf

lemma has_fderiv_within_at.sin (hf : has_fderiv_within_at f f' s x) :
  has_fderiv_within_at (λ x, real.sin (f x)) (real.cos (f x) • f') s x :=
(real.has_deriv_at_sin (f x)).comp_has_fderiv_within_at x hf

lemma differentiable_within_at.sin (hf : differentiable_within_at ℝ f s x) :
  differentiable_within_at ℝ (λ x, real.sin (f x)) s x :=
hf.has_fderiv_within_at.sin.differentiable_within_at

@[simp] lemma differentiable_at.sin (hc : differentiable_at ℝ f x) :
  differentiable_at ℝ (λx, real.sin (f x)) x :=
hc.has_fderiv_at.sin.differentiable_at

lemma differentiable_on.sin (hc : differentiable_on ℝ f s) :
  differentiable_on ℝ (λx, real.sin (f x)) s :=
λx h, (hc x h).sin

@[simp] lemma differentiable.sin (hc : differentiable ℝ f) :
  differentiable ℝ (λx, real.sin (f x)) :=
λx, (hc x).sin

lemma fderiv_within_sin (hf : differentiable_within_at ℝ f s x)
  (hxs : unique_diff_within_at ℝ s x) :
  fderiv_within ℝ (λx, real.sin (f x)) s x = real.cos (f x) • (fderiv_within ℝ f s x) :=
hf.has_fderiv_within_at.sin.fderiv_within hxs

@[simp] lemma fderiv_sin (hc : differentiable_at ℝ f x) :
  fderiv ℝ (λx, real.sin (f x)) x = real.cos (f x) • (fderiv ℝ f x) :=
hc.has_fderiv_at.sin.fderiv

lemma cont_diff.sin {n} (h : cont_diff ℝ n f) :
  cont_diff ℝ n (λ x, real.sin (f x)) :=
real.cont_diff_sin.comp h

lemma cont_diff_at.sin {n} (hf : cont_diff_at ℝ n f x) :
  cont_diff_at ℝ n (λ x, real.sin (f x)) x :=
real.cont_diff_sin.cont_diff_at.comp x hf

lemma cont_diff_on.sin {n} (hf : cont_diff_on ℝ n f s) :
  cont_diff_on ℝ n (λ x, real.sin (f x)) s :=
real.cont_diff_sin.comp_cont_diff_on  hf

lemma cont_diff_within_at.sin {n} (hf : cont_diff_within_at ℝ n f s x) :
  cont_diff_within_at ℝ n (λ x, real.sin (f x)) s x :=
real.cont_diff_sin.cont_diff_at.comp_cont_diff_within_at x hf

/-! #### `real.cosh` -/

lemma has_strict_fderiv_at.cosh (hf : has_strict_fderiv_at f f' x) :
  has_strict_fderiv_at (λ x, real.cosh (f x)) (real.sinh (f x) • f') x :=
(real.has_strict_deriv_at_cosh (f x)).comp_has_strict_fderiv_at x hf

lemma has_fderiv_at.cosh (hf : has_fderiv_at f f' x) :
  has_fderiv_at (λ x, real.cosh (f x)) (real.sinh (f x) • f') x :=
(real.has_deriv_at_cosh (f x)).comp_has_fderiv_at x hf

lemma has_fderiv_within_at.cosh (hf : has_fderiv_within_at f f' s x) :
  has_fderiv_within_at (λ x, real.cosh (f x)) (real.sinh (f x) • f') s x :=
(real.has_deriv_at_cosh (f x)).comp_has_fderiv_within_at x hf

lemma differentiable_within_at.cosh (hf : differentiable_within_at ℝ f s x) :
  differentiable_within_at ℝ (λ x, real.cosh (f x)) s x :=
hf.has_fderiv_within_at.cosh.differentiable_within_at

@[simp] lemma differentiable_at.cosh (hc : differentiable_at ℝ f x) :
  differentiable_at ℝ (λx, real.cosh (f x)) x :=
hc.has_fderiv_at.cosh.differentiable_at

lemma differentiable_on.cosh (hc : differentiable_on ℝ f s) :
  differentiable_on ℝ (λx, real.cosh (f x)) s :=
λx h, (hc x h).cosh

@[simp] lemma differentiable.cosh (hc : differentiable ℝ f) :
  differentiable ℝ (λx, real.cosh (f x)) :=
λx, (hc x).cosh

lemma fderiv_within_cosh (hf : differentiable_within_at ℝ f s x)
  (hxs : unique_diff_within_at ℝ s x) :
  fderiv_within ℝ (λx, real.cosh (f x)) s x = real.sinh (f x) • (fderiv_within ℝ f s x) :=
hf.has_fderiv_within_at.cosh.fderiv_within hxs

@[simp] lemma fderiv_cosh (hc : differentiable_at ℝ f x) :
  fderiv ℝ (λx, real.cosh (f x)) x = real.sinh (f x) • (fderiv ℝ f x) :=
hc.has_fderiv_at.cosh.fderiv

lemma cont_diff.cosh {n} (h : cont_diff ℝ n f) :
  cont_diff ℝ n (λ x, real.cosh (f x)) :=
real.cont_diff_cosh.comp h

lemma cont_diff_at.cosh {n} (hf : cont_diff_at ℝ n f x) :
  cont_diff_at ℝ n (λ x, real.cosh (f x)) x :=
real.cont_diff_cosh.cont_diff_at.comp x hf

lemma cont_diff_on.cosh {n} (hf : cont_diff_on ℝ n f s) :
  cont_diff_on ℝ n (λ x, real.cosh (f x)) s :=
real.cont_diff_cosh.comp_cont_diff_on  hf

lemma cont_diff_within_at.cosh {n} (hf : cont_diff_within_at ℝ n f s x) :
  cont_diff_within_at ℝ n (λ x, real.cosh (f x)) s x :=
real.cont_diff_cosh.cont_diff_at.comp_cont_diff_within_at x hf

/-! #### `real.sinh` -/

lemma has_strict_fderiv_at.sinh (hf : has_strict_fderiv_at f f' x) :
  has_strict_fderiv_at (λ x, real.sinh (f x)) (real.cosh (f x) • f') x :=
(real.has_strict_deriv_at_sinh (f x)).comp_has_strict_fderiv_at x hf

lemma has_fderiv_at.sinh (hf : has_fderiv_at f f' x) :
  has_fderiv_at (λ x, real.sinh (f x)) (real.cosh (f x) • f') x :=
(real.has_deriv_at_sinh (f x)).comp_has_fderiv_at x hf

lemma has_fderiv_within_at.sinh (hf : has_fderiv_within_at f f' s x) :
  has_fderiv_within_at (λ x, real.sinh (f x)) (real.cosh (f x) • f') s x :=
(real.has_deriv_at_sinh (f x)).comp_has_fderiv_within_at x hf

lemma differentiable_within_at.sinh (hf : differentiable_within_at ℝ f s x) :
  differentiable_within_at ℝ (λ x, real.sinh (f x)) s x :=
hf.has_fderiv_within_at.sinh.differentiable_within_at

@[simp] lemma differentiable_at.sinh (hc : differentiable_at ℝ f x) :
  differentiable_at ℝ (λx, real.sinh (f x)) x :=
hc.has_fderiv_at.sinh.differentiable_at

lemma differentiable_on.sinh (hc : differentiable_on ℝ f s) :
  differentiable_on ℝ (λx, real.sinh (f x)) s :=
λx h, (hc x h).sinh

@[simp] lemma differentiable.sinh (hc : differentiable ℝ f) :
  differentiable ℝ (λx, real.sinh (f x)) :=
λx, (hc x).sinh

lemma fderiv_within_sinh (hf : differentiable_within_at ℝ f s x)
  (hxs : unique_diff_within_at ℝ s x) :
  fderiv_within ℝ (λx, real.sinh (f x)) s x = real.cosh (f x) • (fderiv_within ℝ f s x) :=
hf.has_fderiv_within_at.sinh.fderiv_within hxs

@[simp] lemma fderiv_sinh (hc : differentiable_at ℝ f x) :
  fderiv ℝ (λx, real.sinh (f x)) x = real.cosh (f x) • (fderiv ℝ f x) :=
hc.has_fderiv_at.sinh.fderiv

lemma cont_diff.sinh {n} (h : cont_diff ℝ n f) :
  cont_diff ℝ n (λ x, real.sinh (f x)) :=
real.cont_diff_sinh.comp h

lemma cont_diff_at.sinh {n} (hf : cont_diff_at ℝ n f x) :
  cont_diff_at ℝ n (λ x, real.sinh (f x)) x :=
real.cont_diff_sinh.cont_diff_at.comp x hf

lemma cont_diff_on.sinh {n} (hf : cont_diff_on ℝ n f s) :
  cont_diff_on ℝ n (λ x, real.sinh (f x)) s :=
real.cont_diff_sinh.comp_cont_diff_on  hf

lemma cont_diff_within_at.sinh {n} (hf : cont_diff_within_at ℝ n f s x) :
  cont_diff_within_at ℝ n (λ x, real.sinh (f x)) s x :=
real.cont_diff_sinh.cont_diff_at.comp_cont_diff_within_at x hf

end
