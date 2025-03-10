/-
Copyright (c) 2019 Chris Hughes. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Hughes, Johan Commelin
-/
import data.polynomial.field_division
import ring_theory.integral_closure
import ring_theory.polynomial.gauss_lemma

/-!
# Minimal polynomials

This file defines the minimal polynomial of an element `x` of an `A`-algebra `B`,
under the assumption that x is integral over `A`.

After stating the defining property we specialize to the setting of field extensions
and derive some well-known properties, amongst which the fact that minimal polynomials
are irreducible, and uniquely determined by their defining property.

-/

open_locale classical polynomial
open polynomial set function

variables {A B : Type*}

section min_poly_def
variables (A) [comm_ring A] [ring B] [algebra A B]

/--
Suppose `x : B`, where `B` is an `A`-algebra.

The minimal polynomial `minpoly A x` of `x`
is a monic polynomial with coefficients in `A` of smallest degree that has `x` as its root,
if such exists (`is_integral A x`) or zero otherwise.

For example, if `V` is a `𝕜`-vector space for some field `𝕜` and `f : V →ₗ[𝕜] V` then
the minimal polynomial of `f` is `minpoly 𝕜 f`.
-/
noncomputable def minpoly (x : B) : A[X] :=
if hx : is_integral A x then well_founded.min degree_lt_wf _ hx else 0

end min_poly_def

namespace minpoly

section ring
variables [comm_ring A] [ring B] [algebra A B]
variables {x : B}

/-- A minimal polynomial is monic. -/
lemma monic (hx : is_integral A x) : monic (minpoly A x) :=
by { delta minpoly, rw dif_pos hx, exact (well_founded.min_mem degree_lt_wf _ hx).1 }

/-- A minimal polynomial is nonzero. -/
lemma ne_zero [nontrivial A] (hx : is_integral A x) : minpoly A x ≠ 0 :=
(monic hx).ne_zero

lemma eq_zero (hx : ¬ is_integral A x) : minpoly A x = 0 :=
dif_neg hx

variables (A x)

/-- An element is a root of its minimal polynomial. -/
@[simp] lemma aeval : aeval x (minpoly A x) = 0 :=
begin
  delta minpoly, split_ifs with hx,
  { exact (well_founded.min_mem degree_lt_wf _ hx).2 },
  { exact aeval_zero _ }
end

/-- A minimal polynomial is not `1`. -/
lemma ne_one [nontrivial B] : minpoly A x ≠ 1 :=
begin
  intro h,
  refine (one_ne_zero : (1 : B) ≠ 0) _,
  simpa using congr_arg (polynomial.aeval x) h
end

lemma map_ne_one [nontrivial B] {R : Type*} [semiring R] [nontrivial R] (f : A →+* R) :
  (minpoly A x).map f ≠ 1 :=
begin
  by_cases hx : is_integral A x,
  { exact mt ((monic hx).eq_one_of_map_eq_one f) (ne_one A x) },
  { rw [eq_zero hx, polynomial.map_zero], exact zero_ne_one },
end

/-- A minimal polynomial is not a unit. -/
lemma not_is_unit [nontrivial B] : ¬ is_unit (minpoly A x) :=
begin
  haveI : nontrivial A := (algebra_map A B).domain_nontrivial,
  by_cases hx : is_integral A x,
  { exact mt (monic hx).eq_one_of_is_unit (ne_one A x) },
  { rw [eq_zero hx], exact not_is_unit_zero }
end

lemma mem_range_of_degree_eq_one (hx : (minpoly A x).degree = 1) : x ∈ (algebra_map A B).range :=
begin
  have h : is_integral A x,
  { by_contra h,
    rw [eq_zero h, degree_zero, ←with_bot.coe_one] at hx,
    exact (ne_of_lt (show ⊥ < ↑1, from with_bot.bot_lt_coe 1) hx) },
  have key := minpoly.aeval A x,
  rw [eq_X_add_C_of_degree_eq_one hx, (minpoly.monic h).leading_coeff, C_1, one_mul, aeval_add,
      aeval_C, aeval_X, ←eq_neg_iff_add_eq_zero, ←ring_hom.map_neg] at key,
  exact ⟨-(minpoly A x).coeff 0, key.symm⟩,
end

/-- The defining property of the minimal polynomial of an element `x`:
it is the monic polynomial with smallest degree that has `x` as its root. -/
lemma min {p : A[X]} (pmonic : p.monic) (hp : polynomial.aeval x p = 0) :
  degree (minpoly A x) ≤ degree p :=
begin
  delta minpoly, split_ifs with hx,
  { exact le_of_not_lt (well_founded.not_lt_min degree_lt_wf _ hx ⟨pmonic, hp⟩) },
  { simp only [degree_zero, bot_le] }
end

@[nontriviality] lemma subsingleton [subsingleton B] : minpoly A x = 1 :=
begin
  nontriviality A,
  have := minpoly.min A x monic_one (subsingleton.elim _ _),
  rw degree_one at this,
  cases le_or_lt (minpoly A x).degree 0 with h h,
  { rwa (monic ⟨1, monic_one, by simp⟩ : (minpoly A x).monic).degree_le_zero_iff_eq_one at h },
  { exact (this.not_lt h).elim },
end

end ring

section comm_ring

variables [comm_ring A]

section ring

variables [ring B] [algebra A B] [nontrivial B]
variables {x : B}

/-- The degree of a minimal polynomial, as a natural number, is positive. -/
lemma nat_degree_pos (hx : is_integral A x) : 0 < nat_degree (minpoly A x) :=
begin
  rw pos_iff_ne_zero,
  intro ndeg_eq_zero,
  have eq_one : minpoly A x = 1,
  { rw eq_C_of_nat_degree_eq_zero ndeg_eq_zero, convert C_1,
    simpa only [ndeg_eq_zero.symm] using (monic hx).leading_coeff },
  simpa only [eq_one, alg_hom.map_one, one_ne_zero] using aeval A x
end

/-- The degree of a minimal polynomial is positive. -/
lemma degree_pos (hx : is_integral A x) : 0 < degree (minpoly A x) :=
nat_degree_pos_iff_degree_pos.mp (nat_degree_pos hx)

/-- If `B/A` is an injective ring extension, and `a` is an element of `A`,
then the minimal polynomial of `algebra_map A B a` is `X - C a`. -/
lemma eq_X_sub_C_of_algebra_map_inj
  (a : A) (hf : function.injective (algebra_map A B)) :
  minpoly A (algebra_map A B a) = X - C a :=
begin
  nontriviality A,
  have hdegle : (minpoly A (algebra_map A B a)).nat_degree ≤ 1,
  { apply with_bot.coe_le_coe.1,
    rw [←degree_eq_nat_degree (ne_zero (@is_integral_algebra_map A B _ _ _ a)),
      with_top.coe_one, ←degree_X_sub_C a],
    refine min A (algebra_map A B a) (monic_X_sub_C a) _,
    simp only [aeval_C, aeval_X, alg_hom.map_sub, sub_self] },
  have hdeg : (minpoly A (algebra_map A B a)).degree = 1,
  { apply (degree_eq_iff_nat_degree_eq (ne_zero (@is_integral_algebra_map A B _ _ _ a))).2,
    apply le_antisymm hdegle (nat_degree_pos (@is_integral_algebra_map A B _ _ _ a)) },
  have hrw := eq_X_add_C_of_degree_eq_one hdeg,
  simp only [monic (@is_integral_algebra_map A B _ _ _ a), one_mul,
    monic.leading_coeff, ring_hom.map_one] at hrw,
  have h0 : (minpoly A (algebra_map A B a)).coeff 0 = -a,
  { have hroot := aeval A (algebra_map A B a),
    rw [hrw, add_comm] at hroot,
    simp only [aeval_C, aeval_X, aeval_add] at hroot,
    replace hroot := eq_neg_of_add_eq_zero_left hroot,
    rw [←ring_hom.map_neg _ a] at hroot,
    exact (hf hroot) },
  rw hrw,
  simp only [h0, ring_hom.map_neg, sub_eq_add_neg],
end

end ring

section is_domain

variables [is_domain A] [ring B] [algebra A B]
variables {x : B}

/-- If `a` strictly divides the minimal polynomial of `x`, then `x` cannot be a root for `a`. -/
lemma aeval_ne_zero_of_dvd_not_unit_minpoly {a : A[X]} (hx : is_integral A x)
  (hamonic : a.monic) (hdvd : dvd_not_unit a (minpoly A x)) :
  polynomial.aeval x a ≠ 0 :=
begin
  intro ha,
  refine not_lt_of_ge (minpoly.min A x hamonic ha) _,
  obtain ⟨hzeroa, b, hb_nunit, prod⟩ := hdvd,
  have hbmonic : b.monic,
  { rw monic.def,
    have := monic hx,
    rwa [monic.def, prod, leading_coeff_mul, monic.def.mp hamonic, one_mul] at this },
  have hzerob : b ≠ 0 := hbmonic.ne_zero,
  have degbzero : 0 < b.nat_degree,
  { apply nat.pos_of_ne_zero,
    intro h,
    have h₁ := eq_C_of_nat_degree_eq_zero h,
    rw [←h, ←leading_coeff, monic.def.1 hbmonic, C_1] at h₁,
    rw h₁ at hb_nunit,
    have := is_unit_one,
    contradiction },
  rw [prod, degree_mul, degree_eq_nat_degree hzeroa, degree_eq_nat_degree hzerob],
  exact_mod_cast lt_add_of_pos_right _ degbzero,
end

variables [is_domain B]

/-- A minimal polynomial is irreducible. -/
lemma irreducible (hx : is_integral A x) : irreducible (minpoly A x) :=
begin
  cases irreducible_or_factor (minpoly A x) (not_is_unit A x) with hirr hred,
  { exact hirr },
  exfalso,
  obtain ⟨a, b, ha_nunit, hb_nunit, hab_eq⟩ := hred,
  have coeff_prod : a.leading_coeff * b.leading_coeff = 1,
  { rw [←monic.def.1 (monic hx), ←hab_eq],
    simp only [leading_coeff_mul] },
  have hamonic : (a * C b.leading_coeff).monic,
  { rw monic.def,
    simp only [coeff_prod, leading_coeff_mul, leading_coeff_C] },
  have hbmonic : (b * C a.leading_coeff).monic,
  { rw [monic.def, mul_comm],
    simp only [coeff_prod, leading_coeff_mul, leading_coeff_C] },
  have prod : minpoly A x = (a * C b.leading_coeff) * (b * C a.leading_coeff),
  { symmetry,
    calc a * C b.leading_coeff * (b * C a.leading_coeff)
        = a * b * (C a.leading_coeff * C b.leading_coeff) : by ring
    ... = a * b * (C (a.leading_coeff * b.leading_coeff)) : by simp only [ring_hom.map_mul]
    ... = a * b : by rw [coeff_prod, C_1, mul_one]
    ... = minpoly A x : hab_eq },
  have hzero := aeval A x,
  rw [prod, aeval_mul, mul_eq_zero] at hzero,
  cases hzero,
  { refine aeval_ne_zero_of_dvd_not_unit_minpoly hx hamonic _ hzero,
    exact ⟨hamonic.ne_zero, _, mt is_unit_of_mul_is_unit_left hb_nunit, prod⟩ },
  { refine aeval_ne_zero_of_dvd_not_unit_minpoly hx hbmonic _ hzero,
    rw mul_comm at prod,
    exact ⟨hbmonic.ne_zero, _, mt is_unit_of_mul_is_unit_left ha_nunit, prod⟩ },
end

end is_domain

end comm_ring

section field
variables [field A]

section ring
variables [ring B] [algebra A B]
variables {x : B}

variables (A x)

/-- If an element `x` is a root of a nonzero polynomial `p`, then the degree of `p` is at least the
degree of the minimal polynomial of `x`. See also `gcd_domain_degree_le_of_ne_zero` which relaxes
the assumptions on `A` in exchange for stronger assumptions on `B`. -/
lemma degree_le_of_ne_zero
  {p : A[X]} (pnz : p ≠ 0) (hp : polynomial.aeval x p = 0) :
  degree (minpoly A x) ≤ degree p :=
calc degree (minpoly A x) ≤ degree (p * C (leading_coeff p)⁻¹) :
    min A x (monic_mul_leading_coeff_inv pnz) (by simp [hp])
  ... = degree p : degree_mul_leading_coeff_inv p pnz

lemma ne_zero_of_finite_field_extension (e : B) [finite_dimensional A B] : minpoly A e ≠ 0 :=
minpoly.ne_zero $ is_integral_of_noetherian (is_noetherian.iff_fg.2 infer_instance) _

/-- The minimal polynomial of an element `x` is uniquely characterized by its defining property:
if there is another monic polynomial of minimal degree that has `x` as a root, then this polynomial
is equal to the minimal polynomial of `x`. See also `minpoly.gcd_unique` which relaxes the
assumptions on `A` in exchange for stronger assumptions on `B`. -/
lemma unique {p : A[X]}
  (pmonic : p.monic) (hp : polynomial.aeval x p = 0)
  (pmin : ∀ q : A[X], q.monic → polynomial.aeval x q = 0 → degree p ≤ degree q) :
  p = minpoly A x :=
begin
  have hx : is_integral A x := ⟨p, pmonic, hp⟩,
  symmetry, apply eq_of_sub_eq_zero,
  by_contra hnz,
  have := degree_le_of_ne_zero A x hnz (by simp [hp]),
  contrapose! this,
  apply degree_sub_lt _ (ne_zero hx),
  { rw [(monic hx).leading_coeff, pmonic.leading_coeff] },
  { exact le_antisymm (min A x pmonic hp)
      (pmin (minpoly A x) (monic hx) (aeval A x)) }
end

/-- If an element `x` is a root of a polynomial `p`, then the minimal polynomial of `x` divides `p`.
See also `minpoly.gcd_domain_dvd` which relaxes the assumptions on `A` in exchange for stronger
assumptions on `B`. -/
lemma dvd {p : A[X]} (hp : polynomial.aeval x p = 0) : minpoly A x ∣ p :=
begin
  by_cases hp0 : p = 0,
  { simp only [hp0, dvd_zero] },
  have hx : is_integral A x,
  { rw ← is_algebraic_iff_is_integral, exact ⟨p, hp0, hp⟩ },
  rw ← dvd_iff_mod_by_monic_eq_zero (monic hx),
  by_contra hnz,
  have := degree_le_of_ne_zero A x hnz _,
  { contrapose! this,
    exact degree_mod_by_monic_lt _ (monic hx) },
  { rw ← mod_by_monic_add_div p (monic hx) at hp,
    simpa using hp }
end

lemma dvd_map_of_is_scalar_tower (A K : Type*) {R : Type*} [comm_ring A] [field K] [comm_ring R]
  [algebra A K] [algebra A R] [algebra K R] [is_scalar_tower A K R] (x : R) :
  minpoly K x ∣ (minpoly A x).map (algebra_map A K) :=
by { refine minpoly.dvd K x _, rw [aeval_map_algebra_map, minpoly.aeval] }

/-- If `y` is a conjugate of `x` over a field `K`, then it is a conjugate over a subring `R`. -/
lemma aeval_of_is_scalar_tower (R : Type*) {K T U : Type*} [comm_ring R] [field K] [comm_ring T]
  [algebra R K] [algebra K T] [algebra R T] [is_scalar_tower R K T]
  [comm_semiring U] [algebra K U] [algebra R U] [is_scalar_tower R K U]
  (x : T) (y : U)
  (hy : polynomial.aeval y (minpoly K x) = 0) : polynomial.aeval y (minpoly R x) = 0 :=
aeval_map_algebra_map K y (minpoly R x) ▸ eval₂_eq_zero_of_dvd_of_eval₂_eq_zero (algebra_map K U)
                                              y (minpoly.dvd_map_of_is_scalar_tower R K x) hy

variables {A x}

theorem eq_of_irreducible_of_monic
  [nontrivial B] {p : A[X]} (hp1 : _root_.irreducible p)
  (hp2 : polynomial.aeval x p = 0) (hp3 : p.monic) : p = minpoly A x :=
let ⟨q, hq⟩ := dvd A x hp2 in
eq_of_monic_of_associated hp3 (monic ⟨p, ⟨hp3, hp2⟩⟩) $
mul_one (minpoly A x) ▸ hq.symm ▸ associated.mul_left _ $
associated_one_iff_is_unit.2 $ (hp1.is_unit_or_is_unit hq).resolve_left $ not_is_unit A x

lemma eq_of_irreducible [nontrivial B] {p : A[X]}
  (hp1 : _root_.irreducible p) (hp2 : polynomial.aeval x p = 0) :
  p * C p.leading_coeff⁻¹ = minpoly A x :=
begin
  have : p.leading_coeff ≠ 0 := leading_coeff_ne_zero.mpr hp1.ne_zero,
  apply eq_of_irreducible_of_monic,
  { exact associated.irreducible ⟨⟨C p.leading_coeff⁻¹, C p.leading_coeff,
      by rwa [←C_mul, inv_mul_cancel, C_1], by rwa [←C_mul, mul_inv_cancel, C_1]⟩, rfl⟩ hp1 },
  { rw [aeval_mul, hp2, zero_mul] },
  { rwa [polynomial.monic, leading_coeff_mul, leading_coeff_C, mul_inv_cancel] },
end

/-- If `y` is the image of `x` in an extension, their minimal polynomials coincide.

We take `h : y = algebra_map L T x` as an argument because `rw h` typically fails
since `is_integral R y` depends on y.
-/
lemma eq_of_algebra_map_eq {K S T : Type*} [field K] [comm_ring S] [comm_ring T]
  [algebra K S] [algebra K T] [algebra S T]
  [is_scalar_tower K S T] (hST : function.injective (algebra_map S T))
  {x : S} {y : T} (hx : is_integral K x) (h : y = algebra_map S T x) :
  minpoly K x = minpoly K y :=
minpoly.unique _ _ (minpoly.monic hx)
  (by rw [h, aeval_algebra_map_apply, minpoly.aeval, ring_hom.map_zero])
  (λ q q_monic root_q, minpoly.min _ _ q_monic
    ((aeval_algebra_map_eq_zero_iff_of_injective hST).mp
      (h ▸ root_q : polynomial.aeval (algebra_map S T x) q = 0)))

lemma add_algebra_map {B : Type*} [comm_ring B] [algebra A B] {x : B}
  (hx : is_integral A x) (a : A) :
  minpoly A (x + (algebra_map A B a)) = (minpoly A x).comp (X - C a) :=
begin
  refine (minpoly.unique _ _ ((minpoly.monic hx).comp_X_sub_C _) _ (λ q qmo hq, _)).symm,
  { simp [aeval_comp] },
  { have : (polynomial.aeval x) (q.comp (X + C a)) = 0 := by simpa [aeval_comp] using hq,
    have H := minpoly.min A x (qmo.comp_X_add_C _) this,
    rw [degree_eq_nat_degree qmo.ne_zero, degree_eq_nat_degree
      ((minpoly.monic hx).comp_X_sub_C _).ne_zero, with_bot.coe_le_coe, nat_degree_comp,
      nat_degree_X_sub_C, mul_one],
    rwa [degree_eq_nat_degree (minpoly.ne_zero hx), degree_eq_nat_degree
      (qmo.comp_X_add_C _).ne_zero, with_bot.coe_le_coe, nat_degree_comp,
      nat_degree_X_add_C, mul_one] at H }
end

lemma sub_algebra_map {B : Type*} [comm_ring B] [algebra A B] {x : B}
  (hx : is_integral A x) (a : A) :
  minpoly A (x - (algebra_map A B a)) = (minpoly A x).comp (X + C a) :=
by simpa [sub_eq_add_neg] using add_algebra_map hx (-a)

section alg_hom_fintype

/-- A technical finiteness result. -/
noncomputable def fintype.subtype_prod {E : Type*} {X : set E} (hX : X.finite) {L : Type*}
  (F : E → multiset L) : fintype (Π x : X, {l : L // l ∈ F x}) :=
let hX := finite.fintype hX in by exactI pi.fintype

variables (F E K : Type*) [field F] [ring E] [comm_ring K] [is_domain K]
  [algebra F E] [algebra F K] [finite_dimensional F E]

/-- Function from Hom_K(E,L) to pi type Π (x : basis), roots of min poly of x -/
-- Marked as `noncomputable!` since this definition takes multiple seconds to compile,
-- and isn't very computable in practice (since neither `finrank` nor `fin_basis` are).
noncomputable! def roots_of_min_poly_pi_type (φ : E →ₐ[F] K)
  (x : range (finite_dimensional.fin_basis F E : _ → E)) :
  {l : K // l ∈ (((minpoly F x.1).map (algebra_map F K)).roots : multiset K)} :=
⟨φ x, by rw [mem_roots_map (minpoly.ne_zero_of_finite_field_extension F x.val),
  subtype.val_eq_coe, ←aeval_def, aeval_alg_hom_apply, minpoly.aeval, map_zero]⟩

lemma aux_inj_roots_of_min_poly : injective (roots_of_min_poly_pi_type F E K) :=
begin
  intros f g h,
  suffices : (f : E →ₗ[F] K) = g,
  { rwa fun_like.ext'_iff at this ⊢ },
  rw funext_iff at h,
  exact linear_map.ext_on (finite_dimensional.fin_basis F E).span_eq
    (λ e he, subtype.ext_iff.mp (h ⟨e, he⟩)),
end

/-- Given field extensions `E/F` and `K/F`, with `E/F` finite, there are finitely many `F`-algebra
  homomorphisms `E →ₐ[K] K`. -/
noncomputable instance alg_hom.fintype : fintype (E →ₐ[F] K) :=
@fintype.of_injective _ _ (fintype.subtype_prod (finite_range (finite_dimensional.fin_basis F E))
  (λ e, ((minpoly F e).map (algebra_map F K)).roots)) _ (aux_inj_roots_of_min_poly F E K)

end alg_hom_fintype

section gcd_domain

variables {R S : Type*} (K L : Type*) [comm_ring R] [is_domain R] [normalized_gcd_monoid R]
  [field K] [comm_ring S] [is_domain S] [algebra R K] [is_fraction_ring R K] [algebra R S] [field L]
  [algebra S L] [algebra K L] [algebra R L] [is_scalar_tower R K L] [is_scalar_tower R S L]
  {s : S} (hs : is_integral R s)

include hs

/-- For GCD domains, the minimal polynomial over the ring is the same as the minimal polynomial
over the fraction field. See `minpoly.gcd_domain_eq_field_fractions'` if `S` is already a
`K`-algebra. -/
lemma gcd_domain_eq_field_fractions :
  minpoly K (algebra_map S L s) = (minpoly R s).map (algebra_map R K) :=
begin
  refine (eq_of_irreducible_of_monic _ _ _).symm,
  { exact (polynomial.is_primitive.irreducible_iff_irreducible_map_fraction_map
      (polynomial.monic.is_primitive (monic hs))).1 (irreducible hs) },
   { rw [aeval_map_algebra_map, aeval_algebra_map_apply, aeval, map_zero] },
  { exact (monic hs).map _ }
end

/-- For GCD domains, the minimal polynomial over the ring is the same as the minimal polynomial
over the fraction field. Compared to `minpoly.gcd_domain_eq_field_fractions`, this version is useful
if the element is in a ring that is already a `K`-algebra. -/
lemma gcd_domain_eq_field_fractions' [algebra K S] [is_scalar_tower R K S] :
  minpoly K s = (minpoly R s).map (algebra_map R K) :=
begin
  let L := fraction_ring S,
  rw [← gcd_domain_eq_field_fractions K L hs],
  refine minpoly.eq_of_algebra_map_eq (is_fraction_ring.injective S L)
    (is_integral_of_is_scalar_tower hs) rfl
end

variable [no_zero_smul_divisors R S]

/-- For GCD domains, the minimal polynomial divides any primitive polynomial that has the integral
element as root. See also `minpoly.dvd` which relaxes the assumptions on `S` in exchange for
stronger assumptions on `R`. -/
lemma gcd_domain_dvd {P : R[X]} (hP : P ≠ 0) (hroot : polynomial.aeval s P = 0) : minpoly R s ∣ P :=
begin
  let K := fraction_ring R,
  let L := fraction_ring S,
  let P₁ := P.prim_part,
  suffices : minpoly R s ∣ P₁,
  { exact dvd_trans this (prim_part_dvd _) },
  apply (is_primitive.dvd_iff_fraction_map_dvd_fraction_map K (monic hs).is_primitive
    P.is_primitive_prim_part).2,
  let y := algebra_map S L s,
  have hy : is_integral R y := hs.algebra_map,
  rw [← gcd_domain_eq_field_fractions K L hs],
  refine dvd _ _ _,
  rw [aeval_map_algebra_map, aeval_algebra_map_apply, aeval_prim_part_eq_zero hP hroot, map_zero]
end

/-- If an element `x` is a root of a nonzero polynomial `p`, then the degree of `p` is at least the
degree of the minimal polynomial of `x`. See also `minpoly.degree_le_of_ne_zero` which relaxes the
assumptions on `S` in exchange for stronger assumptions on `R`. -/
lemma gcd_domain_degree_le_of_ne_zero {p : R[X]} (hp0 : p ≠ 0) (hp : polynomial.aeval s p = 0) :
  degree (minpoly R s) ≤ degree p :=
begin
  rw [degree_eq_nat_degree (minpoly.ne_zero hs), degree_eq_nat_degree hp0],
  norm_cast,
  exact nat_degree_le_of_dvd (gcd_domain_dvd hs hp0 hp) hp0
end

omit hs

/-- The minimal polynomial of an element `x` is uniquely characterized by its defining property:
if there is another monic polynomial of minimal degree that has `x` as a root, then this polynomial
is equal to the minimal polynomial of `x`. See also `minpoly.unique` which relaxes the
assumptions on `S` in exchange for stronger assumptions on `R`. -/
lemma gcd_domain_unique {P : R[X]} (hmo : P.monic) (hP : polynomial.aeval s P = 0)
  (Pmin : ∀ Q : R[X], Q.monic → polynomial.aeval s Q = 0 → degree P ≤ degree Q) :
  P = minpoly R s :=
begin
  have hs : is_integral R s := ⟨P, hmo, hP⟩,
  symmetry, apply eq_of_sub_eq_zero,
  by_contra hnz,
  have := gcd_domain_degree_le_of_ne_zero hs hnz (by simp [hP]),
  contrapose! this,
  refine degree_sub_lt _ (ne_zero hs) _,
  { exact le_antisymm (min R s hmo hP)
      (Pmin (minpoly R s) (monic hs) (aeval R s)) },
  { rw [(monic hs).leading_coeff, hmo.leading_coeff] }
end

end gcd_domain

variables (B) [nontrivial B]

/-- If `B/K` is a nontrivial algebra over a field, and `x` is an element of `K`,
then the minimal polynomial of `algebra_map K B x` is `X - C x`. -/
lemma eq_X_sub_C (a : A) : minpoly A (algebra_map A B a) = X - C a :=
eq_X_sub_C_of_algebra_map_inj a (algebra_map A B).injective

lemma eq_X_sub_C' (a : A) : minpoly A a = X - C a := eq_X_sub_C A a

variables (A)

/-- The minimal polynomial of `0` is `X`. -/
@[simp] lemma zero : minpoly A (0:B) = X :=
by simpa only [add_zero, C_0, sub_eq_add_neg, neg_zero, ring_hom.map_zero]
  using eq_X_sub_C B (0:A)

/-- The minimal polynomial of `1` is `X - 1`. -/
@[simp] lemma one : minpoly A (1:B) = X - 1 :=
by simpa only [ring_hom.map_one, C_1, sub_eq_add_neg] using eq_X_sub_C B (1:A)

end ring

section is_domain
variables [ring B] [is_domain B] [algebra A B]
variables {x : B}

/-- A minimal polynomial is prime. -/
lemma prime (hx : is_integral A x) : prime (minpoly A x) :=
begin
  refine ⟨ne_zero hx, not_is_unit A x, _⟩,
  rintros p q ⟨d, h⟩,
  have :    polynomial.aeval x (p*q) = 0 := by simp [h, aeval A x],
  replace : polynomial.aeval x p = 0 ∨ polynomial.aeval x q = 0 := by simpa,
  exact or.imp (dvd A x) (dvd A x) this
end

/-- If `L/K` is a field extension and an element `y` of `K` is a root of the minimal polynomial
of an element `x ∈ L`, then `y` maps to `x` under the field embedding. -/
lemma root {x : B} (hx : is_integral A x) {y : A} (h : is_root (minpoly A x) y) :
  algebra_map A B y = x :=
have key : minpoly A x = X - C y :=
eq_of_monic_of_associated (monic hx) (monic_X_sub_C y) (associated_of_dvd_dvd
  ((irreducible_X_sub_C y).dvd_symm (irreducible hx) (dvd_iff_is_root.2 h))
  (dvd_iff_is_root.2 h)),
by { have := aeval A x, rwa [key, alg_hom.map_sub, aeval_X, aeval_C, sub_eq_zero, eq_comm] at this }

/-- The constant coefficient of the minimal polynomial of `x` is `0` if and only if `x = 0`. -/
@[simp] lemma coeff_zero_eq_zero (hx : is_integral A x) : coeff (minpoly A x) 0 = 0 ↔ x = 0 :=
begin
  split,
  { intro h,
    have zero_root := zero_is_root_of_coeff_zero_eq_zero h,
    rw ← root hx zero_root,
    exact ring_hom.map_zero _ },
  { rintro rfl, simp }
end

/-- The minimal polynomial of a nonzero element has nonzero constant coefficient. -/
lemma coeff_zero_ne_zero (hx : is_integral A x) (h : x ≠ 0) : coeff (minpoly A x) 0 ≠ 0 :=
by { contrapose! h, simpa only [hx, coeff_zero_eq_zero] using h }

end is_domain

end field

end minpoly
