/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl

Lebesgue measure on the real line
-/
import topology.measure topology.borel_space
noncomputable theory
open classical set lattice filter
open ennreal (of_real)

section real
open topological_space

lemma inv_le_inv {α : Type*} [discrete_linear_ordered_field α] {a b : α} (hb : 0 < b) (h : b ≤ a) :
  a⁻¹ ≤ b⁻¹ :=
begin
  rw [inv_eq_one_div, inv_eq_one_div],
  exact one_div_le_one_div_of_le hb h
end

lemma min_of_rat_of_rat {a b : ℚ} : min (of_rat a) (of_rat b) = of_rat (min a b) :=
by by_cases a ≤ b; simp [h, min, of_rat_le_of_rat]

lemma max_of_rat_of_rat {a b : ℚ} : max (of_rat a) (of_rat b) = of_rat (max a b) :=
by by_cases a ≤ b; simp [h, max, of_rat_le_of_rat]

lemma is_topological_basis_of_open_of_nhds {α : Type*} [topological_space α] {s : set (set α)}
  (h_inter : ∀(u₁ u₂ : set α), u₁ ∈ s → u₂ ∈ s → u₁ ∩ u₂ ≠ ∅ → u₁ ∩ u₂ ∈ s)
  (h_univ : ∀a:α, ∃u:set α, u ∈ s ∧ a ∈ u)
  (h_open : ∀(u : set α), u ∈ s → is_open u)
  (h_nhds : ∀(a:α) (u : set α), a ∈ u → is_open u → ∃v, v ∈ s ∧ a ∈ v ∧ v ⊆ u) :
  is_topological_basis s :=
have @is_topological_basis α (generate_from s) s,
  from ⟨assume t₁ ht₁ t₂ ht₂, h_inter t₁ t₂ ht₁ ht₂,
    eq_univ_of_forall $ assume a, by simpa using h_univ a, rfl⟩,
⟨this.1, this.2.1,
  le_antisymm
    (assume u hu,
      (@is_open_iff_nhds α (generate_from _) _).mpr $ assume a hau,
        let ⟨v, hvs, hav, hvu⟩ := h_nhds a u hau hu in
        by rw [nhds_generate_from]; exact (infi_le_of_le v $ infi_le_of_le ⟨hav, hvs⟩ $ by simp [hvu]))
    (generate_from_le h_open)⟩

lemma is_topological_basis_Ioo_of_rat_of_rat :
  @is_topological_basis ℝ _ (⋃(a b : ℚ) (h : a < b), {Ioo (of_rat a) (of_rat b)}) :=
is_topological_basis_of_open_of_nhds
  (assume t₁ t₂ ht₁ ht₂ h,
    have ∃a b, a < b ∧ t₁ = Ioo (of_rat a) (of_rat b), by simp at ht₁; simp [ht₁],
    let ⟨a₁, b₁, hab₁, eq₁⟩ := this in
    have ∃a b, a < b ∧ t₂ = Ioo (of_rat a) (of_rat b), by simp at ht₂; simp [ht₂],
    let ⟨a₂, b₂, hab₂, eq₂⟩ := this in
    have t₁₂ : t₁ ∩ t₂ = Ioo (of_rat $ max a₁ a₂) (of_rat $ min b₁ b₂),
      by simp [eq₁, eq₂, Ioo_inter_Ioo, min_of_rat_of_rat, max_of_rat_of_rat],
    have max a₁ a₂ < min b₁ b₂,
      from have ∃a, a ∈ Ioo (of_rat $ max a₁ a₂) (of_rat $ min b₁ b₂),
        from ne_empty_iff_exists_mem.mp $ by simp [t₁₂.symm, h],
      let ⟨c, hc₁, hc₂⟩ := this in
      have of_rat (max a₁ a₂) < of_rat (min b₁ b₂), from lt_trans hc₁ hc₂,
      of_rat_lt_of_rat.mp this,
    by simp [t₁₂]; exact ⟨max a₁ a₂, min b₁ b₂, this, rfl⟩)
  (suffices ∀r, ∃(t : set ℝ), r ∈ t ∧ ∃a b, t = Ioo (of_rat a) (of_rat b) ∧ a < b,
      by simpa,
    assume r,
    let ⟨a, ha⟩ := exists_gt_of_rat r, ⟨b, hb⟩ := exists_lt_of_rat r in
    ⟨Ioo (of_rat a) (of_rat b), ⟨ha, hb⟩, a, b, rfl, of_rat_lt_of_rat.mp $ lt_trans ha hb⟩)
  begin simp [is_open_Ioo] {contextual:=tt} end
  (assume a v hav hv,
    let
      ⟨l, u, hl, hu, h⟩ := (mem_nhds_unbounded (no_top _) (no_bot _)).mp (mem_nhds_sets hv hav),
      ⟨q, hlq, hqa⟩ := exists_lt_of_rat_of_rat_gt hl,
      ⟨p, hap, hpu⟩ := exists_lt_of_rat_of_rat_gt hu
    in
    ⟨Ioo (of_rat q) (of_rat p),
      begin simp; exact ⟨q, p, of_rat_lt_of_rat.mp $ lt_trans hqa hap, rfl⟩ end,
      ⟨hqa, hap⟩, assume a' ⟨hqa', ha'p⟩, h _ (lt_trans hlq hqa') (lt_trans ha'p hpu)⟩)

instance : second_countable_topology ℝ :=
⟨⟨(⋃(a b : ℚ) (h : a < b), {Ioo (of_rat a) (of_rat b)}),
  by simp [countable_Union, countable_Union_Prop],
  is_topological_basis_Ioo_of_rat_of_rat.2.2⟩⟩

open measure_theory measurable_space

lemma borel_eq_generate_from_Ioo_of_rat_of_rat :
  measure_theory.borel ℝ = generate_from (⋃(a b : ℚ) (h : a < b), {Ioo (of_rat a) (of_rat b)}) :=
borel_eq_generate_from_of_subbasis is_topological_basis_Ioo_of_rat_of_rat.2.2

lemma borel_eq_generate_from_Iio_of_rat :
  measure_theory.borel ℝ = generate_from (⋃a, {Iio (of_rat a)}) :=
let g := measurable_space.generate_from (⋃a, {Iio (of_rat a)} : set (set ℝ)) in
have ∀a b, a < b → g.is_measurable (Ioo (of_rat a) (of_rat b)),
  from assume a b h,
  have hg : ∀q, g.is_measurable (Iio (of_rat q)),
    from assume q, generate_measurable.basic _ $ by simp; exact ⟨_, rfl⟩,
  have hgc : ∀q, g.is_measurable (- Iio (of_rat q)),
    from assume q, g.is_measurable_compl _ $ hg q,
  have (⋃c>a, - Iio (of_rat c)) ∩ Iio (of_rat b) = Ioo (of_rat a) (of_rat b),
    from set.ext $ assume x,
    have h₁ : x < of_rat b → ∀p, of_rat p ≤ x → p > a → of_rat a < x,
      from assume hxb p hpx hpa, lt_of_lt_of_le (of_rat_lt_of_rat.mpr hpa) hpx,
    have h₂ : x < of_rat b → of_rat a < x → (∃ (i : ℚ), of_rat i ≤ x ∧ i > a),
      from assume hxb hax,
      let ⟨c, hac, hcx⟩ := exists_lt_of_rat_of_rat_gt hax in
      ⟨c, le_of_lt hcx, of_rat_lt_of_rat.mp hac⟩,
    by simp [iff_def, Iio, Ioo] {contextual := tt}; exact ⟨h₁, h₂⟩,
  this ▸ @is_measurable_inter _ g _ _
    (@is_measurable_bUnion _ _ g _ _ countable_encodable $ assume b hb, hgc b)
    (hg b),
le_antisymm
  (borel_eq_generate_from_Ioo_of_rat_of_rat.symm ▸ generate_from_le
    (by simp [this] {contextual:=tt}))
  (generate_from_le $ assume t,
    have ∀r:ℝ, is_measurable (Iio r), from assume r, generate_measurable.basic _ $ is_open_gt' _,
    by simp {contextual:=tt}; exact assume h _, this _)

end real

namespace measure_theory

/- "Lebesgue" lebesgue_length of an interval

Important: if `s` is not a interval [a, b) its value is `∞`. This is important to extend this to the
Lebesgue measure. -/
def lebesgue_length (s : set ℝ) : ennreal := ⨅a b (h₁ : a ≤ b) (h₂ : s = Ico a b), of_real (b - a)

@[simp] lemma lebesgue_length_Ico {a b : ℝ} (h : a ≤ b) :
  lebesgue_length (Ico a b) = of_real (b - a) :=
le_antisymm
  (infi_le_of_le a $ infi_le_of_le b $ infi_le_of_le h $ infi_le_of_le rfl $ le_refl _)
  (le_infi $ assume a', le_infi $ assume b', le_infi $ assume h', le_infi $ assume eq,
    match Ico_eq_Ico_iff.mp eq with
    | or.inl ⟨h₁, h₂⟩ :=
      have a = b, from le_antisymm h h₁,
      have a' = b', from le_antisymm h' h₂,
      by simp *
    | or.inr ⟨h₁, h⟩ := by simp *
    end)

@[simp] lemma lebesgue_length_empty : lebesgue_length ∅ = 0 :=
have ∅ = Ico 0 (0:ℝ),
  from set.ext $ by simp [Ico, not_le_iff],
by rw [this, lebesgue_length_Ico]; simp [le_refl]

lemma le_lebesgue_length {r : ennreal} {s : set ℝ } (h : ∀a b, a ≤ b → s ≠ Ico a b) :
  r ≤ lebesgue_length s :=
le_infi $ assume a, le_infi $ assume b, le_infi $ assume hab, le_infi $ assume heq, (h a b hab heq).elim

lemma lebesgue_length_Ico_le_lebesgue_length_Ico {a₁ b₁ a₂ b₂ : ℝ} (ha : a₂ ≤ a₁) (hb : b₁ ≤ b₂) :
  lebesgue_length (Ico a₁ b₁) ≤ lebesgue_length (Ico a₂ b₂) :=
by_cases
  (assume : b₁ ≤ a₁, by simp [Ico_eq_empty_iff.mpr this])
  (assume : ¬ b₁ ≤ a₁,
    have h₁ : a₁ ≤ b₁, from le_of_lt $ not_le_iff.mp this,
    have h₂ : a₂ ≤ b₂, from le_trans (le_trans ha h₁) hb,
    have b₁ + a₂ ≤ a₁ + (b₂ - a₂) + a₂,
      from calc b₁ + a₂ ≤ b₂ + a₁ : add_le_add hb ha
        ... = a₁ + (b₂ - a₂) + a₂ : by rw [add_sub, sub_add_cancel, add_comm],
    have b₁ ≤ a₁ + (b₂ - a₂), from le_of_add_le_add_right this,
    by simp [h₁, h₂, -sub_eq_add_neg]; exact this)

lemma lebesgue_length_subadditive {a b : ℝ} {c d : ℕ → ℝ}
  (hab : a ≤ b) (hcd : ∀i, c i ≤ d i) (habcd : Ico a b ⊆ (⋃i, Ico (c i) (d i))) :
  lebesgue_length (Ico a b) ≤ (∑i, lebesgue_length (Ico (c i) (d i))) :=
let
  s := λx, ∑i, lebesgue_length (Ico (c i) (min (d i) x)),
  M := {x : ℝ | a ≤ x ∧ x ≤ b ∧ of_real (x - a) ≤ s x }
in
have a ∈ M, by simp [M, le_refl, hab],
have b ∈ upper_bounds M, by simp [upper_bounds, M] {contextual:=tt},
let ⟨x, hx⟩ := exists_supremum_real ‹a ∈ M› ‹b ∈ upper_bounds M› in
have h' : is_lub ((λx, of_real (x - a)) '' M) (of_real (x - a)),
  from is_lub_of_is_lub_of_tendsto
    (assume x ⟨hx, _, _⟩ y ⟨hy, _, _⟩ h,
      have hx : 0 ≤ x - a, by rw [le_sub_iff_add_le]; simp [hx],
      have hy : 0 ≤ y - a, by rw [le_sub_iff_add_le]; simp [hy],
      by rw [ennreal.of_real_le_of_real_iff hx hy]; from sub_le_sub h (le_refl a))
    hx
    (ne_empty_iff_exists_mem.mpr ⟨a, ‹_›⟩)
    (tendsto_compose (tendsto_sub (tendsto_id' inf_le_left) tendsto_const_nhds) ennreal.tendsto_of_real),
have hax : a ≤ x, from hx.left a ‹a ∈ M›,
have hxb : x ≤ b, from hx.right b ‹b ∈ upper_bounds M›,
have hx_sx : of_real (x - a) ≤ s x,
  from h'.right _ $ assume r ⟨y, hy, eq⟩,
    have ∀i, lebesgue_length (Ico (c i) (min (d i) y)) ≤ lebesgue_length (Ico (c i) (min (d i) x)),
      from assume i,
      lebesgue_length_Ico_le_lebesgue_length_Ico (le_refl _) (inf_le_inf (le_refl _) (hx.left _ hy)),
    eq ▸ le_trans hy.2.2 $ ennreal.tsum_le_tsum this,
have hxM : x ∈ M,
  from ⟨hax, hxb, hx_sx⟩,
have x = b,
  from le_antisymm hxb $ not_lt_iff.mp $ assume hxb : x < b,
  have ∃k, x ∈ Ico (c k) (d k), by simpa using habcd ⟨hxM.left, hxb⟩,
  let ⟨k, hxc, hxd⟩ := this, y := min (d k) b in
  have hxy' : x < y, from lt_min hxd hxb,
  have hxy : x ≤ y, from le_of_lt hxy',
  have of_real (y - a) ≤ s y,
    from calc of_real (y - a) = of_real (x - a) + of_real (y - x) :
      begin
        rw [ennreal.of_real_add_of_real],
        simp,
        repeat { simp [hax, hxy, -sub_eq_add_neg] }
      end
      ... ≤ s x + (∑i, ⨆ h : i = k, of_real (y - x)) :
        add_le_add' hx_sx (le_trans (by simp) (@ennreal.le_tsum _ _ k))
      ... ≤ (∑i, lebesgue_length (Ico (c i) (min (d i) x)) + ⨆ h : i = k, of_real (y - x)) :
        by rw [tsum_add]; simp [ennreal.has_sum]
      ... ≤ s y : ennreal.tsum_le_tsum $ assume i, by_cases
          (assume : i = k,
            have eq₁ : min (d k) y = y, from min_eq_right $ min_le_left _ _,
            have eq₂ : min (d k) x = x, from min_eq_right $ le_of_lt hxd,
            have h : c k ≤ y, from le_min (hcd _) (le_trans hxc $ le_of_lt hxb),
            have eq: y - x + (x - c k) = y - c k, by rw [add_sub, sub_add_cancel],
            by simp [h, hxy, hxc, eq, eq₁, eq₂, this, -sub_eq_add_neg, add_sub_cancel'_right, le_refl])
          (assume h : i ≠ k, by simp [h, ennreal.bot_eq_zero];
            from lebesgue_length_Ico_le_lebesgue_length_Ico (le_refl _) (inf_le_inf (le_refl _) hxy)),
  have ¬ x < y, from not_lt_iff.mpr $ hx.left y ⟨le_trans hax hxy, min_le_right _ _, this⟩,
  this hxy',
have hbM : b ∈ M, from this ▸ hxM,
calc lebesgue_length (Ico a b) ≤ s b : by simp [hab]; exact hbM.right.right
  ... ≤ ∑i, lebesgue_length (Ico (c i) (d i)) : ennreal.tsum_le_tsum $ assume a,
    lebesgue_length_Ico_le_lebesgue_length_Ico (le_refl _) (min_le_left _ _)

def lebesgue_outer : outer_measure ℝ :=
outer_measure.of_function lebesgue_length lebesgue_length_empty

lemma lebesgue_outer_Ico {a b : ℝ} (h : a ≤ b) :
  lebesgue_outer.measure_of (Ico a b) = of_real (b - a) :=
le_antisymm
  (let f : ℕ → set ℝ := λi, nat.rec_on i (Ico a b) (λn s, ∅) in
    infi_le_of_le f $ infi_le_of_le (subset_Union f 0) $
    calc (∑i, lebesgue_length (f i)) = ({0} : finset ℕ).sum (λi, lebesgue_length (f i)) :
        tsum_eq_sum $ by intro i; cases i; simp
      ... = lebesgue_length (Ico a b) : by simp; refl
      ... ≤ of_real (b - a) : by simp [h])
  (le_infi $ assume f, le_infi $ assume hf, by_cases
    (assume : ∀i, ∃p:ℝ×ℝ, p.1 ≤ p.2 ∧ f i = Ico p.1 p.2,
      let ⟨cd, hcd⟩ := axiom_of_choice this in
      have hcd₁ : ∀i, (cd i).1 ≤ (cd i).2, from assume i, (hcd i).1,
      have hcd₂ : ∀i, f i = Ico (cd i).1 (cd i).2, from assume i, (hcd i).2,
      calc of_real (b - a) = lebesgue_length (Ico a b) :
          by simp [h]
        ... ≤ (∑i, lebesgue_length (Ico (cd i).1 (cd i).2)) :
          lebesgue_length_subadditive h hcd₁ (by simpa [hcd₂] using hf)
        ... = _ :
          by simp [hcd₂])
    (assume h,
      have ∃i, ∀(c d : ℝ), c ≤ d → f i ≠ Ico c d,
        by simpa [classical.not_forall] using h,
      let ⟨i, hi⟩ := this in
      calc of_real (b - a) ≤ lebesgue_length (f i) : le_lebesgue_length hi
        ... ≤ (∑i, lebesgue_length (f i)) : ennreal.le_tsum))

lemma lebesgue_outer_is_measurable_Iio {c : ℝ} :
  lebesgue_outer.caratheodory.is_measurable (Iio c) :=
outer_measure.caratheodory_is_measurable $ assume t, by_cases
  (assume : ∃a b, a ≤ b ∧ t = Ico a b,
    let ⟨a, b, hab, ht⟩ := this in
    begin
      cases le_total a c with hac hca; cases le_total b c with hbc hcb;
      simp [*, max_eq_right, max_eq_left, min_eq_left, min_eq_right, le_refl,
        -sub_eq_add_neg, add_sub_cancel'_right, add_sub],
      { show of_real (b + b - a - a) ≤ of_real (b - a),
        rw [ennreal.of_real_of_nonpos],
        { exact zero_le },
        { have : b ≤ a, from le_trans hbc hca,
          have : b + b ≤ a + a, from add_le_add this this,
          have : (b + b) - (a + a) ≤ 0, by simp [sub_le_iff_le_add, -sub_eq_add_neg, this],
          { simp, simp at this, exact this } } }
    end)
  (assume h, by simp at h; from le_lebesgue_length h)

/-- Lebesgue measure on the Borel sets

The outer Lebesgue measure is the completion of this measure. (TODO: proof this)
-/
def lebesgue : measure_space ℝ :=
lebesgue_outer.to_measure $
  calc measure_theory.borel ℝ = measurable_space.generate_from (⋃a, {Iio (of_rat a)}) :
      borel_eq_generate_from_Iio_of_rat
    ... ≤ lebesgue_outer.caratheodory :
      measurable_space.generate_from_le $ by simp [lebesgue_outer_is_measurable_Iio] {contextual := tt}

lemma tendsto_of_nat_at_top_at_top : tendsto (of_nat : ℕ → ℝ) at_top at_top :=
tendsto_infi $ assume r, tendsto_principal $
  let ⟨q, hq⟩ := exists_lt_of_rat r in
  show {n : ℕ | r ≤ of_nat n} ∈ at_top.sets,
    from mem_at_top_iff.mpr ⟨rat.nat_ceil q, assume b (hb : rat.nat_ceil q ≤ b),
      calc r ≤ of_rat q : le_of_lt hq
        ... ≤ of_rat (rat.nat_ceil q) : of_rat_le_of_rat.mpr (rat.le_nat_ceil q)
        ... = of_nat (rat.nat_ceil q) : by rw [rat_coe_eq_of_nat, real_of_rat_of_nat_eq_of_nat]
        ... ≤ of_nat b : of_nat_le_of_nat hb⟩

lemma lebesgue_Ico {a b : ℝ} : lebesgue.measure (Ico a b) = of_real (b - a) :=
match le_total a b with
| or.inl h :=
  begin
    rw [lebesgue.measure_eq is_measurable_Ico],
    { exact lebesgue_outer_Ico h },
    repeat {apply_instance}
  end
| or.inr h :=
  have hba : b - a ≤ 0, by simp [-sub_eq_add_neg, h],
  have eq : Ico a b = ∅, from Ico_eq_empty_iff.mpr h,
  by simp [ennreal.of_real_of_nonpos, *] at *
end

lemma lebesgue_Ioo {a b : ℝ} : lebesgue.measure (Ioo a b) = of_real (b - a) :=
by_cases (assume h : b ≤ a, by simp [h, -sub_eq_add_neg, ennreal.of_real_of_nonpos]) $
assume : ¬ b ≤ a,
have h : a < b, from not_le_iff.mp this,
let s := λn:ℕ, a + (b - a) * (of_nat (n + 1))⁻¹ in
have tendsto s at_top (nhds (a + (b - a) * 0)),
  from tendsto_add tendsto_const_nhds $ tendsto_mul tendsto_const_nhds $ tendsto_compose
   (tendsto_comp_succ_at_top_iff.mpr tendsto_of_nat_at_top_at_top) tendsto_inverse_at_top_nhds_0,
have hs : tendsto s at_top (nhds a), by simpa,
have hsm : ∀i j, j ≤ i → s i ≤ s j,
  from assume i j hij,
  have h₁ : ∀j:ℕ, (0:ℝ) < of_nat (j + 1),
    from assume j, of_nat_pos $ add_pos_of_nonneg_of_pos (nat.zero_le j) zero_lt_one,
  have h₂ : of_nat (j + 1) ≤ (of_nat (i + 1) : ℝ), from of_nat_le_of_nat $ add_le_add hij (le_refl _),
  add_le_add (le_refl _) $ mul_le_mul (le_refl _) (inv_le_inv (h₁ j) h₂) (le_of_lt $ inv_pos $ h₁ i) $
    by simp [le_sub_iff_add_le, -sub_eq_add_neg, le_of_lt h],
have has : ∀i, a < s i,
  from assume i,
  have (0:ℝ) < of_nat (i + 1), from of_nat_pos $ lt_add_of_le_of_pos (nat.zero_le _) zero_lt_one,
  (lt_add_iff_pos_right _).mpr $ mul_pos
    (by simp [-sub_eq_add_neg, sub_lt_iff, (>), ‹a < b›]) (inv_pos this),
have eq₁ : Ioo a b = (⋃n, Ico (s n) b),
  from set.ext $ assume x,
  begin
    simp [iff_def, Ico, Ioo, -sub_eq_add_neg] {contextual := tt},
    constructor,
    exact assume hxb i hsx, lt_of_lt_of_le (has i) hsx,
    exact assume hax hxb,
      have {a | a < x } ∈ (nhds a).sets, from mem_nhds_sets (is_open_gt' _) hax,
      have {n | s n < x} ∈ at_top.sets, from hs this,
      let ⟨n, hn⟩ := inhabited_of_mem_sets at_top_ne_bot this in
      ⟨n, le_of_lt hn⟩
  end,
have (⨆i, of_real (b - s i)) = of_real (b - a),
  from is_lub_iff_supr_eq.mp $ is_lub_of_mem_nhds
    (assume x ⟨i, eq⟩, eq ▸ ennreal.of_real_le_of_real $ sub_le_sub (le_refl _) $ le_of_lt $ has _)
    begin
      show range (λi, of_real (b - s i)) ∈ (at_top.map (λi, of_real (b - s i))).sets,
      rw [range_eq_image]; exact image_mem_map univ_mem_sets
    end
    begin
      have : tendsto (λi, of_real (b - s i)) at_top (nhds (of_real (b - a))),
        from tendsto_compose (tendsto_sub tendsto_const_nhds hs) ennreal.tendsto_of_real,
      rw [inf_of_le_left this],
      exact map_ne_bot at_top_ne_bot
    end,
have eq₂ : (⨆i, lebesgue.measure (Ico (s i) b)) = of_real (b - a),
  by simp only [lebesgue_Ico, this],
begin
  rw [eq₁, measure_Union_eq_supr_nat, eq₂],
  show ∀i, is_measurable (Ico (s i) b), from assume i, is_measurable_Ico,
  show monotone (λi, Ico (s i) b),
    from assume i j hij x hx, ⟨le_trans (hsm _ _ hij) hx.1, hx.2⟩
end

lemma lebesgue_singleton {a : ℝ} : lebesgue.measure {a} = 0 :=
have Ico a (a + 1) \ Ioo a (a + 1) = {a},
  from set.ext $ assume a',
  begin
    simp [iff_def, Ico, Ioo, lt_irrefl, le_refl, zero_lt_one,
      le_iff_eq_or_lt, or_imp_distrib] {contextual := tt},
    exact assume h₁ h₂,
      ⟨assume eq, by rw [eq] at h₂; exact (lt_irrefl _ h₂).elim,
      assume h₃, (lt_irrefl a' $ lt_trans h₂ h₃).elim⟩
  end,
calc lebesgue.measure {a} = lebesgue.measure (Ico a (a + 1) \ Ioo a (a + 1)) :
    congr_arg _ this.symm
  ... = lebesgue.measure (Ico a (a + 1)) - lebesgue.measure (Ioo a (a + 1)) :
    measure_sdiff (assume x, and.imp le_of_lt id) is_measurable_Ico is_measurable_Ioo $
      by simp [lebesgue_Ico]; exact ennreal.of_real_lt_infty
  ... = 0 : by simp [lebesgue_Ico, lebesgue_Ioo]

end measure_theory
