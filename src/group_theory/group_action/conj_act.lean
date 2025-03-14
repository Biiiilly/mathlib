/-
Copyright (c) 2021 . All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Hughes
-/
import group_theory.group_action.basic
import group_theory.subgroup.basic
import algebra.group_ring_action.basic
/-!
# Conjugation action of a group on itself

This file defines the conjugation action of a group on itself. See also `mul_aut.conj` for
the definition of conjugation as a homomorphism into the automorphism group.

## Main definitions

A type alias `conj_act G` is introduced for a group `G`. The group `conj_act G` acts on `G`
by conjugation. The group `conj_act G` also acts on any normal subgroup of `G` by conjugation.

As a generalization, this also allows:
* `conj_act Mˣ` to act on `M`, when `M` is a `monoid`
* `conj_act G₀` to act on `G₀`, when `G₀` is a `group_with_zero`

## Implementation Notes

The scalar action in defined in this file can also be written using `mul_aut.conj g • h`. This
has the advantage of not using the type alias `conj_act`, but the downside of this approach
is that some theorems about the group actions will not apply when since this
`mul_aut.conj g • h` describes an action of `mul_aut G` on `G`, and not an action of `G`.

-/

variables (α M G G₀ R K : Type*)

/-- A type alias for a group `G`. `conj_act G` acts on `G` by conjugation -/
def conj_act : Type* := G

namespace conj_act
open mul_action subgroup

variables {M G G₀ R K}

instance : Π [group G], group (conj_act G) := id
instance : Π [div_inv_monoid G], div_inv_monoid (conj_act G) := id
instance : Π [group_with_zero G], group_with_zero (conj_act G) := id
instance : Π [fintype G], fintype (conj_act G) := id

@[simp] lemma card [fintype G] : fintype.card (conj_act G) = fintype.card G := rfl

section div_inv_monoid

variable [div_inv_monoid G]

instance : inhabited (conj_act G) := ⟨1⟩

/-- Reinterpret `g : conj_act G` as an element of `G`. -/
def of_conj_act : conj_act G ≃* G := ⟨id, id, λ _, rfl, λ _, rfl, λ _ _, rfl⟩

/-- Reinterpret `g : G` as an element of `conj_act G`. -/
def to_conj_act : G ≃* conj_act G := of_conj_act.symm

/-- A recursor for `conj_act`, for use as `induction x using conj_act.rec` when `x : conj_act G`. -/
protected def rec {C : conj_act G → Sort*} (h : Π g, C (to_conj_act g)) : Π g, C g := h

@[simp] lemma «forall» (p : conj_act G → Prop) :
  (∀ (x : conj_act G), p x) ↔ ∀ x : G, p (to_conj_act x) := iff.rfl

@[simp] lemma of_mul_symm_eq : (@of_conj_act G _).symm = to_conj_act := rfl
@[simp] lemma to_mul_symm_eq : (@to_conj_act G _).symm = of_conj_act := rfl
@[simp] lemma to_conj_act_of_conj_act (x : conj_act G) : to_conj_act (of_conj_act x) = x := rfl
@[simp] lemma of_conj_act_to_conj_act (x : G) : of_conj_act (to_conj_act x) = x := rfl
@[simp] lemma of_conj_act_one : of_conj_act (1 : conj_act G) = 1 := rfl
@[simp] lemma to_conj_act_one : to_conj_act (1 : G) = 1 := rfl
@[simp] lemma of_conj_act_inv (x : conj_act G) : of_conj_act (x⁻¹) = (of_conj_act x)⁻¹ := rfl
@[simp] lemma to_conj_act_inv (x : G) : to_conj_act (x⁻¹) = (to_conj_act x)⁻¹ := rfl
@[simp] lemma of_conj_act_mul (x y : conj_act G) :
  of_conj_act (x * y) = of_conj_act x * of_conj_act y := rfl
@[simp] lemma to_conj_act_mul (x y : G) : to_conj_act (x * y) =
  to_conj_act x * to_conj_act y := rfl

instance : has_smul (conj_act G) G :=
{ smul := λ g h, of_conj_act g * h * (of_conj_act g)⁻¹ }

lemma smul_def (g : conj_act G) (h : G) : g • h = of_conj_act g * h * (of_conj_act g)⁻¹ := rfl

end div_inv_monoid

section units

section monoid
variables [monoid M]

instance has_units_scalar : has_smul (conj_act Mˣ) M :=
{ smul := λ g h, of_conj_act g * h * ↑(of_conj_act g)⁻¹ }

lemma units_smul_def (g : conj_act Mˣ) (h : M) : g • h = of_conj_act g * h * ↑(of_conj_act g)⁻¹ :=
rfl

instance units_mul_distrib_mul_action : mul_distrib_mul_action (conj_act Mˣ) M :=
{ smul := (•),
  one_smul := by simp [units_smul_def],
  mul_smul := by simp [units_smul_def, mul_assoc, mul_inv_rev],
  smul_mul := by simp [units_smul_def, mul_assoc],
  smul_one := by simp [units_smul_def], }

instance units_smul_comm_class [has_smul α M] [smul_comm_class α M M] [is_scalar_tower α M M] :
  smul_comm_class α (conj_act Mˣ) M :=
{ smul_comm := λ a um m, by rw [units_smul_def, units_smul_def, mul_smul_comm, smul_mul_assoc] }

instance units_smul_comm_class' [has_smul α M] [smul_comm_class M α M] [is_scalar_tower α M M] :
  smul_comm_class (conj_act Mˣ) α M :=
by { haveI : smul_comm_class α M M := smul_comm_class.symm _ _ _, exact smul_comm_class.symm _ _ _ }

end monoid

section semiring
variables [semiring R]

instance units_mul_semiring_action : mul_semiring_action (conj_act Rˣ) R :=
{ smul := (•),
  smul_zero := by simp [units_smul_def],
  smul_add := by simp [units_smul_def, mul_add, add_mul],
  ..conj_act.units_mul_distrib_mul_action}

end semiring

end units

section group_with_zero
variable [group_with_zero G₀]

@[simp] lemma of_conj_act_zero : of_conj_act (0 : conj_act G₀) = 0 := rfl
@[simp] lemma to_conj_act_zero : to_conj_act (0 : G₀) = 0 := rfl

instance mul_action₀ : mul_action (conj_act G₀) G₀ :=
{ smul := (•),
  one_smul := by simp [smul_def],
  mul_smul := by simp [smul_def, mul_assoc, mul_inv_rev] }

instance smul_comm_class₀ [has_smul α G₀] [smul_comm_class α G₀ G₀] [is_scalar_tower α G₀ G₀] :
  smul_comm_class α (conj_act G₀) G₀ :=
{ smul_comm := λ a ug g, by rw [smul_def, smul_def, mul_smul_comm, smul_mul_assoc] }

instance smul_comm_class₀' [has_smul α G₀] [smul_comm_class G₀ α G₀] [is_scalar_tower α G₀ G₀] :
  smul_comm_class (conj_act G₀) α G₀ :=
by { haveI := smul_comm_class.symm G₀ α G₀, exact smul_comm_class.symm _ _ _ }

end group_with_zero

section division_ring
variables [division_ring K]

instance distrib_mul_action₀ : distrib_mul_action (conj_act K) K :=
{ smul := (•),
  smul_zero := by simp [smul_def],
  smul_add := by simp [smul_def, mul_add, add_mul],
  ..conj_act.mul_action₀ }

end division_ring

variables [group G]

instance : mul_distrib_mul_action (conj_act G) G :=
{ smul := (•),
  smul_mul := by simp [smul_def, mul_assoc],
  smul_one := by simp [smul_def],
  one_smul := by simp [smul_def],
  mul_smul := by simp [smul_def, mul_assoc] }

instance smul_comm_class [has_smul α G] [smul_comm_class α G G] [is_scalar_tower α G G] :
  smul_comm_class α (conj_act G) G :=
{ smul_comm := λ a ug g, by rw [smul_def, smul_def, mul_smul_comm, smul_mul_assoc] }

instance smul_comm_class' [has_smul α G] [smul_comm_class G α G] [is_scalar_tower α G G] :
  smul_comm_class (conj_act G) α G :=
by { haveI := smul_comm_class.symm G α G, exact smul_comm_class.symm _ _ _ }

lemma smul_eq_mul_aut_conj (g : conj_act G) (h : G) : g • h = mul_aut.conj (of_conj_act g) h := rfl

/-- The set of fixed points of the conjugation action of `G` on itself is the center of `G`. -/
lemma fixed_points_eq_center : fixed_points (conj_act G) G = center G :=
begin
  ext x,
  simp [mem_center_iff, smul_def, mul_inv_eq_iff_eq_mul]
end

lemma stabilizer_eq_centralizer (g : G) : stabilizer (conj_act G) g = (zpowers g).centralizer :=
le_antisymm (le_centralizer_iff.mp (zpowers_le.mpr (λ x, mul_inv_eq_iff_eq_mul.mp)))
  (λ x h, mul_inv_eq_of_eq_mul (h g (mem_zpowers g)).symm)

/-- As normal subgroups are closed under conjugation, they inherit the conjugation action
  of the underlying group. -/
instance subgroup.conj_action {H : subgroup G} [hH : H.normal] :
  has_smul (conj_act G) H :=
⟨λ g h, ⟨g • h, hH.conj_mem h.1 h.2 (of_conj_act g)⟩⟩

lemma subgroup.coe_conj_smul {H : subgroup G} [hH : H.normal] (g : conj_act G) (h : H) :
  ↑(g • h) = g • (h : G) := rfl

instance subgroup.conj_mul_distrib_mul_action {H : subgroup G} [hH : H.normal] :
  mul_distrib_mul_action (conj_act G) H :=
(subtype.coe_injective).mul_distrib_mul_action H.subtype subgroup.coe_conj_smul

/-- Group conjugation on a normal subgroup. Analogous to `mul_aut.conj`. -/
def _root_.mul_aut.conj_normal {H : subgroup G} [hH : H.normal] : G →* mul_aut H :=
(mul_distrib_mul_action.to_mul_aut (conj_act G) H).comp to_conj_act.to_monoid_hom

@[simp] lemma _root_.mul_aut.conj_normal_apply {H : subgroup G} [H.normal] (g : G) (h : H) :
  ↑(mul_aut.conj_normal g h) = g * h * g⁻¹ := rfl

@[simp] lemma _root_.mul_aut.conj_normal_symm_apply {H : subgroup G} [H.normal] (g : G) (h : H) :
  ↑((mul_aut.conj_normal g).symm h) = g⁻¹ * h * g :=
by { change _ * (_)⁻¹⁻¹ = _, rw inv_inv, refl }

@[simp] lemma _root_.mul_aut.conj_normal_inv_apply {H : subgroup G} [H.normal] (g : G) (h : H) :
  ↑((mul_aut.conj_normal g)⁻¹ h) = g⁻¹ * h * g :=
mul_aut.conj_normal_symm_apply g h

lemma _root_.mul_aut.conj_normal_coe {H : subgroup G} [H.normal] {h : H} :
  mul_aut.conj_normal ↑h = mul_aut.conj h :=
mul_equiv.ext (λ x, rfl)

instance normal_of_characteristic_of_normal {H : subgroup G} [hH : H.normal]
  {K : subgroup H} [h : K.characteristic] : (K.map H.subtype).normal :=
⟨λ a ha b, by
{ obtain ⟨a, ha, rfl⟩ := ha,
  exact K.apply_coe_mem_map H.subtype
    ⟨_, ((set_like.ext_iff.mp (h.fixed (mul_aut.conj_normal b)) a).mpr ha)⟩ }⟩

end conj_act
