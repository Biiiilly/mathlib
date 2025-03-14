/-
Copyright (c) 2020 Anne Baanen. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Nathaniel Thomas, Jeremy Avigad, Johannes Hölzl, Mario Carneiro, Anne Baanen,
  Frédéric Dupuis, Heather Macbeth
-/
import algebra.hom.group_action
import algebra.module.pi
import algebra.star.basic
import data.set.pointwise.smul
import algebra.ring.comp_typeclasses

/-!
# (Semi)linear maps

In this file we define

* `linear_map σ M M₂`, `M →ₛₗ[σ] M₂` : a semilinear map between two `module`s. Here,
  `σ` is a `ring_hom` from `R` to `R₂` and an `f : M →ₛₗ[σ] M₂` satisfies
  `f (c • x) = (σ c) • (f x)`. We recover plain linear maps by choosing `σ` to be `ring_hom.id R`.
  This is denoted by `M →ₗ[R] M₂`. We also add the notation `M →ₗ⋆[R] M₂` for star-linear maps.

* `is_linear_map R f` : predicate saying that `f : M → M₂` is a linear map. (Note that this
  was not generalized to semilinear maps.)

We then provide `linear_map` with the following instances:

* `linear_map.add_comm_monoid` and `linear_map.add_comm_group`: the elementwise addition structures
  corresponding to addition in the codomain
* `linear_map.distrib_mul_action` and `linear_map.module`: the elementwise scalar action structures
  corresponding to applying the action in the codomain.
* `module.End.semiring` and `module.End.ring`: the (semi)ring of endomorphisms formed by taking the
  additive structure above with composition as multiplication.

## Implementation notes

To ensure that composition works smoothly for semilinear maps, we use the typeclasses
`ring_hom_comp_triple`, `ring_hom_inv_pair` and `ring_hom_surjective` from
`algebra/ring/comp_typeclasses`.

## Notation

* Throughout the file, we denote regular linear maps by `fₗ`, `gₗ`, etc, and semilinear maps
  by `f`, `g`, etc.

## TODO

* Parts of this file have not yet been generalized to semilinear maps (i.e. `compatible_smul`)

## Tags

linear map
-/

open function
open_locale big_operators

universes u u' v w x y z
variables {R : Type*} {R₁ : Type*} {R₂ : Type*} {R₃ : Type*}
variables {k : Type*} {S : Type*} {S₃ : Type*} {T : Type*}
variables {M : Type*} {M₁ : Type*} {M₂ : Type*} {M₃ : Type*}
variables {N₁ : Type*} {N₂ : Type*} {N₃ : Type*} {ι : Type*}

/-- A map `f` between modules over a semiring is linear if it satisfies the two properties
`f (x + y) = f x + f y` and `f (c • x) = c • f x`. The predicate `is_linear_map R f` asserts this
property. A bundled version is available with `linear_map`, and should be favored over
`is_linear_map` most of the time. -/
structure is_linear_map (R : Type u) {M : Type v} {M₂ : Type w}
  [semiring R] [add_comm_monoid M] [add_comm_monoid M₂] [module R M] [module R M₂]
  (f : M → M₂) : Prop :=
(map_add : ∀ x y, f (x + y) = f x + f y)
(map_smul : ∀ (c : R) x, f (c • x) = c • f x)

section

set_option old_structure_cmd true

/-- A map `f` between an `R`-module and an `S`-module over a ring homomorphism `σ : R →+* S`
is semilinear if it satisfies the two properties `f (x + y) = f x + f y` and
`f (c • x) = (σ c) • f x`. Elements of `linear_map σ M M₂` (available under the notation
`M →ₛₗ[σ] M₂`) are bundled versions of such maps. For plain linear maps (i.e. for which
`σ = ring_hom.id R`), the notation `M →ₗ[R] M₂` is available. An unbundled version of plain linear
maps is available with the predicate `is_linear_map`, but it should be avoided most of the time. -/
structure linear_map {R : Type*} {S : Type*} [semiring R] [semiring S] (σ : R →+* S)
  (M : Type*) (M₂ : Type*)
  [add_comm_monoid M] [add_comm_monoid M₂] [module R M] [module S M₂]
  extends add_hom M M₂ :=
(map_smul' : ∀ (r : R) (x : M), to_fun (r • x) = (σ r) • to_fun x)

/-- The `add_hom` underlying a `linear_map`. -/
add_decl_doc linear_map.to_add_hom

notation M ` →ₛₗ[`:25 σ:25 `] `:0 M₂:0 := linear_map σ M M₂
notation M ` →ₗ[`:25 R:25 `] `:0 M₂:0 := linear_map (ring_hom.id R) M M₂
notation M ` →ₗ⋆[`:25 R:25 `] `:0 M₂:0 := linear_map (star_ring_end R) M M₂

/-- `semilinear_map_class F σ M M₂` asserts `F` is a type of bundled `σ`-semilinear maps `M → M₂`.

See also `linear_map_class F R M M₂` for the case where `σ` is the identity map on `R`.

A map `f` between an `R`-module and an `S`-module over a ring homomorphism `σ : R →+* S`
is semilinear if it satisfies the two properties `f (x + y) = f x + f y` and
`f (c • x) = (σ c) • f x`. -/
class semilinear_map_class (F : Type*) {R S : out_param Type*} [semiring R] [semiring S]
  (σ : out_param $ R →+* S) (M M₂ : out_param Type*)
  [add_comm_monoid M] [add_comm_monoid M₂] [module R M] [module S M₂]
  extends add_hom_class F M M₂ :=
(map_smulₛₗ : ∀ (f : F) (r : R) (x : M), f (r • x) = (σ r) • f x)

end

-- `σ` becomes a metavariable but that's fine because it's an `out_param`
attribute [nolint dangerous_instance] semilinear_map_class.to_add_hom_class

export semilinear_map_class (map_smulₛₗ)
attribute [simp] map_smulₛₗ

/-- `linear_map_class F R M M₂` asserts `F` is a type of bundled `R`-linear maps `M → M₂`.

This is an abbreviation for `semilinear_map_class F (ring_hom.id R) M M₂`.
-/
abbreviation linear_map_class (F : Type*) (R M M₂ : out_param Type*)
  [semiring R] [add_comm_monoid M] [add_comm_monoid M₂] [module R M] [module R M₂] :=
semilinear_map_class F (ring_hom.id R) M M₂

namespace semilinear_map_class

variables (F : Type*)
variables [semiring R] [semiring S]
variables [add_comm_monoid M] [add_comm_monoid M₁] [add_comm_monoid M₂] [add_comm_monoid M₃]
variables [add_comm_monoid N₁] [add_comm_monoid N₂] [add_comm_monoid N₃]
variables [module R M] [module R M₂] [module S M₃]
variables {σ : R →+* S}

@[priority 100, nolint dangerous_instance] -- `σ` is an `out_param` so it's not dangerous
instance [semilinear_map_class F σ M M₃] : add_monoid_hom_class F M M₃ :=
{ coe := λ f, (f : M → M₃),
  map_zero := λ f, show f 0 = 0, by { rw [← zero_smul R (0 : M), map_smulₛₗ], simp },
  .. semilinear_map_class.to_add_hom_class F σ M M₃ }

@[priority 100, nolint dangerous_instance] -- `R` is an `out_param` so it's not dangerous
instance [linear_map_class F R M M₂] : distrib_mul_action_hom_class F R M M₂ :=
{ coe := λ f, (f : M → M₂),
  map_smul := λ f c x, by rw [map_smulₛₗ, ring_hom.id_apply],
  .. semilinear_map_class.add_monoid_hom_class F }

variables {F} (f : F) [i : semilinear_map_class F σ M M₃]
include i

lemma map_smul_inv {σ' : S →+* R} [ring_hom_inv_pair σ σ'] (c : S) (x : M) :
  c • f x = f (σ' c • x) :=
by simp

end semilinear_map_class

namespace linear_map

section add_comm_monoid

variables [semiring R] [semiring S]

section
variables [add_comm_monoid M] [add_comm_monoid M₁] [add_comm_monoid M₂] [add_comm_monoid M₃]
variables [add_comm_monoid N₁] [add_comm_monoid N₂] [add_comm_monoid N₃]
variables [module R M] [module R M₂] [module S M₃]
variables {σ : R →+* S}

instance : semilinear_map_class (M →ₛₗ[σ] M₃) σ M M₃ :=
{ coe := linear_map.to_fun,
  coe_injective' := λ f g h, by cases f; cases g; congr',
  map_add := linear_map.map_add',
  map_smulₛₗ := linear_map.map_smul' }

/-- Helper instance for when there's too many metavariables to apply `fun_like.has_coe_to_fun`
directly.
-/
instance : has_coe_to_fun (M →ₛₗ[σ] M₃) (λ _, M → M₃) := ⟨λ f, f⟩

/-- The `distrib_mul_action_hom` underlying a `linear_map`. -/
def to_distrib_mul_action_hom (f : M →ₗ[R] M₂) : distrib_mul_action_hom R M M₂ :=
{ map_zero' := show f 0 = 0, from map_zero f, ..f }

@[simp] lemma to_fun_eq_coe {f : M →ₛₗ[σ] M₃} : f.to_fun = (f : M → M₃) := rfl

@[ext] theorem ext {f g : M →ₛₗ[σ] M₃} (h : ∀ x, f x = g x) : f = g := fun_like.ext f g h

/-- Copy of a `linear_map` with a new `to_fun` equal to the old one. Useful to fix definitional
equalities. -/
protected def copy (f : M →ₛₗ[σ] M₃) (f' : M → M₃) (h : f' = ⇑f) : M →ₛₗ[σ] M₃ :=
{ to_fun := f',
  map_add' := h.symm ▸ f.map_add',
  map_smul' := h.symm ▸ f.map_smul' }

@[simp] lemma coe_copy (f : M →ₛₗ[σ] M₃) (f' : M → M₃) (h : f' = ⇑f) : ⇑(f.copy f' h) = f' := rfl
lemma copy_eq (f : M →ₛₗ[σ] M₃) (f' : M → M₃) (h : f' = ⇑f) : f.copy f' h = f := fun_like.ext' h

/-- See Note [custom simps projection]. -/
protected def simps.apply {R S : Type*} [semiring R] [semiring S] (σ : R →+* S)
  (M M₃ : Type*) [add_comm_monoid M] [add_comm_monoid M₃] [module R M] [module S M₃]
  (f : M →ₛₗ[σ] M₃) : M → M₃ := f

initialize_simps_projections linear_map (to_fun → apply)

@[simp] lemma coe_mk {σ : R →+* S} (f : M → M₃) (h₁ h₂) :
  ((linear_map.mk f h₁ h₂ : M →ₛₗ[σ] M₃) : M → M₃) = f := rfl

/-- Identity map as a `linear_map` -/
def id : M →ₗ[R] M :=
{ to_fun := id, ..distrib_mul_action_hom.id R }

lemma id_apply (x : M) :
  @id R M _ _ _ x = x := rfl

@[simp, norm_cast] lemma id_coe : ((linear_map.id : M →ₗ[R] M) : M → M) = _root_.id := rfl

end

section
variables [add_comm_monoid M] [add_comm_monoid M₁] [add_comm_monoid M₂] [add_comm_monoid M₃]
variables [add_comm_monoid N₁] [add_comm_monoid N₂] [add_comm_monoid N₃]
variables [module R M] [module R M₂] [module S M₃]
variables (σ : R →+* S)
variables (fₗ gₗ : M →ₗ[R] M₂) (f g : M →ₛₗ[σ] M₃)

theorem is_linear : is_linear_map R fₗ := ⟨fₗ.map_add', fₗ.map_smul'⟩

variables {fₗ gₗ f g σ}

theorem coe_injective : @injective (M →ₛₗ[σ] M₃) (M → M₃) coe_fn :=
fun_like.coe_injective

protected lemma congr_arg {x x' : M} : x = x' → f x = f x' :=
fun_like.congr_arg f

/-- If two linear maps are equal, they are equal at each point. -/
protected lemma congr_fun (h : f = g) (x : M) : f x = g x :=
fun_like.congr_fun h x

theorem ext_iff : f = g ↔ ∀ x, f x = g x :=
fun_like.ext_iff

@[simp] lemma mk_coe (f : M →ₛₗ[σ] M₃) (h₁ h₂) :
  (linear_map.mk f h₁ h₂ : M →ₛₗ[σ] M₃) = f := ext $ λ _, rfl

variables (fₗ gₗ f g)

protected lemma map_add (x y : M) : f (x + y) = f x + f y := map_add f x y
protected lemma map_zero : f 0 = 0 := map_zero f
-- TODO: `simp` isn't picking up `map_smulₛₗ` for `linear_map`s without specifying `map_smulₛₗ f`
@[simp] protected lemma map_smulₛₗ (c : R) (x : M) : f (c • x) = (σ c) • f x := map_smulₛₗ f c x
protected lemma map_smul (c : R) (x : M) : fₗ (c • x) = c • fₗ x := map_smul fₗ c x
protected lemma map_smul_inv {σ' : S →+* R} [ring_hom_inv_pair σ σ'] (c : S) (x : M) :
  c • f x = f (σ' c • x) :=
by simp

-- TODO: generalize to `zero_hom_class`
@[simp] lemma map_eq_zero_iff (h : function.injective f) {x : M} : f x = 0 ↔ x = 0 :=
⟨λ w, by { apply h, simp [w], }, λ w, by { subst w, simp, }⟩

section pointwise
open_locale pointwise

variables (M M₃ σ) {F : Type*} (h : F)

@[simp] lemma _root_.image_smul_setₛₗ [semilinear_map_class F σ M M₃] (c : R) (s : set M) :
  h '' (c • s) = (σ c) • h '' s :=
begin
  apply set.subset.antisymm,
  { rintros x ⟨y, ⟨z, zs, rfl⟩, rfl⟩,
    exact ⟨h z, set.mem_image_of_mem _ zs, (map_smulₛₗ _ _ _).symm ⟩ },
  { rintros x ⟨y, ⟨z, hz, rfl⟩, rfl⟩,
    exact (set.mem_image _ _ _).2 ⟨c • z, set.smul_mem_smul_set hz, map_smulₛₗ _ _ _⟩ }
end

lemma _root_.preimage_smul_setₛₗ [semilinear_map_class F σ M M₃] {c : R} (hc : is_unit c)
  (s : set M₃) : h ⁻¹' (σ c • s) = c • h ⁻¹' s :=
begin
  apply set.subset.antisymm,
  { rintros x ⟨y, ys, hy⟩,
    refine ⟨(hc.unit.inv : R) • x, _, _⟩,
    { simp only [←hy, smul_smul, set.mem_preimage, units.inv_eq_coe_inv, map_smulₛₗ h, ← map_mul,
        is_unit.coe_inv_mul, one_smul, map_one, ys] },
    { simp only [smul_smul, is_unit.mul_coe_inv, one_smul, units.inv_eq_coe_inv] } },
  { rintros x ⟨y, hy, rfl⟩,
    refine ⟨h y, hy, by simp only [ring_hom.id_apply, map_smulₛₗ h]⟩ }
end

variables (R M₂)

lemma _root_.image_smul_set [linear_map_class F R M M₂] (c : R) (s : set M) :
  h '' (c • s) = c • h '' s :=
image_smul_setₛₗ _ _ _ h c s

lemma _root_.preimage_smul_set [linear_map_class F R M M₂] {c : R} (hc : is_unit c) (s : set M₂) :
  h ⁻¹' (c • s) = c • h ⁻¹' s :=
preimage_smul_setₛₗ _ _ _ h hc s

end pointwise

variables (M M₂)
/--
A typeclass for `has_smul` structures which can be moved through a `linear_map`.
This typeclass is generated automatically from a `is_scalar_tower` instance, but exists so that
we can also add an instance for `add_comm_group.int_module`, allowing `z •` to be moved even if
`R` does not support negation.
-/
class compatible_smul (R S : Type*) [semiring S] [has_smul R M]
  [module S M] [has_smul R M₂] [module S M₂] :=
(map_smul : ∀ (fₗ : M →ₗ[S] M₂) (c : R) (x : M), fₗ (c • x) = c • fₗ x)
variables {M M₂}

@[priority 100]
instance is_scalar_tower.compatible_smul
  {R S : Type*} [semiring S] [has_smul R S]
  [has_smul R M] [module S M] [is_scalar_tower R S M]
  [has_smul R M₂] [module S M₂] [is_scalar_tower R S M₂] : compatible_smul M M₂ R S :=
⟨λ fₗ c x, by rw [← smul_one_smul S c x, ← smul_one_smul S c (fₗ x), map_smul]⟩

@[simp, priority 900]
lemma map_smul_of_tower {R S : Type*} [semiring S] [has_smul R M]
  [module S M] [has_smul R M₂] [module S M₂]
  [compatible_smul M M₂ R S] (fₗ : M →ₗ[S] M₂) (c : R) (x : M) :
  fₗ (c • x) = c • fₗ x :=
compatible_smul.map_smul fₗ c x

/-- convert a linear map to an additive map -/
def to_add_monoid_hom : M →+ M₃ :=
{ to_fun := f,
  map_zero' := f.map_zero,
  map_add' := f.map_add }

@[simp] lemma to_add_monoid_hom_coe : ⇑f.to_add_monoid_hom = f := rfl

section restrict_scalars

variables (R) [module S M] [module S M₂] [compatible_smul M M₂ R S]

/-- If `M` and `M₂` are both `R`-modules and `S`-modules and `R`-module structures
are defined by an action of `R` on `S` (formally, we have two scalar towers), then any `S`-linear
map from `M` to `M₂` is `R`-linear.

See also `linear_map.map_smul_of_tower`. -/
def restrict_scalars (fₗ : M →ₗ[S] M₂) : M →ₗ[R] M₂ :=
{ to_fun := fₗ,
  map_add' := fₗ.map_add,
  map_smul' := fₗ.map_smul_of_tower }

@[simp] lemma coe_restrict_scalars (fₗ : M →ₗ[S] M₂) : ⇑(restrict_scalars R fₗ) = fₗ :=
rfl

lemma restrict_scalars_apply (fₗ : M →ₗ[S] M₂) (x) : restrict_scalars R fₗ x = fₗ x :=
rfl

lemma restrict_scalars_injective :
  function.injective (restrict_scalars R : (M →ₗ[S] M₂) → (M →ₗ[R] M₂)) :=
λ fₗ gₗ h, ext (linear_map.congr_fun h : _)

@[simp]
lemma restrict_scalars_inj (fₗ gₗ : M →ₗ[S] M₂) :
  fₗ.restrict_scalars R = gₗ.restrict_scalars R ↔ fₗ = gₗ :=
(restrict_scalars_injective R).eq_iff

end restrict_scalars

variable {R}

@[simp] lemma map_sum {ι} {t : finset ι} {g : ι → M} :
  f (∑ i in t, g i) = (∑ i in t, f (g i)) :=
f.to_add_monoid_hom.map_sum _ _

theorem to_add_monoid_hom_injective :
  function.injective (to_add_monoid_hom : (M →ₛₗ[σ] M₃) → (M →+ M₃)) :=
λ f g h, ext $ add_monoid_hom.congr_fun h

/-- If two `σ`-linear maps from `R` are equal on `1`, then they are equal. -/
@[ext] theorem ext_ring {f g : R →ₛₗ[σ] M₃} (h : f 1 = g 1) : f = g :=
ext $ λ x, by rw [← mul_one x, ← smul_eq_mul, f.map_smulₛₗ, g.map_smulₛₗ, h]

theorem ext_ring_iff {σ : R →+* R} {f g : R →ₛₗ[σ] M} : f = g ↔ f 1 = g 1 :=
⟨λ h, h ▸ rfl, ext_ring⟩

@[ext] theorem ext_ring_op {σ : Rᵐᵒᵖ →+* S} {f g : R →ₛₗ[σ] M₃} (h : f 1 = g 1) : f = g :=
ext $ λ x, by rw [← one_mul x, ← op_smul_eq_mul, f.map_smulₛₗ, g.map_smulₛₗ, h]

end

/-- Interpret a `ring_hom` `f` as an `f`-semilinear map. -/
@[simps]
def _root_.ring_hom.to_semilinear_map (f : R →+* S) : R →ₛₗ[f] S :=
{ to_fun := f,
  map_smul' := f.map_mul,
  .. f}

section

variables [semiring R₁] [semiring R₂] [semiring R₃]
variables [add_comm_monoid M] [add_comm_monoid M₁] [add_comm_monoid M₂] [add_comm_monoid M₃]
variables {module_M₁ : module R₁ M₁} {module_M₂ : module R₂ M₂} {module_M₃ : module R₃ M₃}
variables {σ₁₂ : R₁ →+* R₂} {σ₂₃ : R₂ →+* R₃} {σ₁₃ : R₁ →+* R₃}
variables [ring_hom_comp_triple σ₁₂ σ₂₃ σ₁₃]
variables (f : M₂ →ₛₗ[σ₂₃] M₃) (g : M₁ →ₛₗ[σ₁₂] M₂)

include module_M₁ module_M₂ module_M₃
/-- Composition of two linear maps is a linear map -/
def comp : M₁ →ₛₗ[σ₁₃] M₃ :=
{ to_fun := f ∘ g,
  map_add' := by simp only [map_add, forall_const, eq_self_iff_true, comp_app],
  map_smul' := λ r x, by rw [comp_app, map_smulₛₗ, map_smulₛₗ, ring_hom_comp_triple.comp_apply] }
omit module_M₁ module_M₂ module_M₃

infixr ` ∘ₗ `:80 := @linear_map.comp _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
  (ring_hom.id _) (ring_hom.id _) (ring_hom.id _) ring_hom_comp_triple.ids

include σ₁₃
lemma comp_apply (x : M₁) : f.comp g x = f (g x) := rfl
omit σ₁₃

include σ₁₃
@[simp, norm_cast] lemma coe_comp : (f.comp g : M₁ → M₃) = f ∘ g := rfl
omit σ₁₃

@[simp] theorem comp_id : f.comp id = f :=
linear_map.ext $ λ x, rfl

@[simp] theorem id_comp : id.comp f = f :=
linear_map.ext $ λ x, rfl

variables {f g} {f' : M₂ →ₛₗ[σ₂₃] M₃} {g' : M₁ →ₛₗ[σ₁₂] M₂}

include σ₁₃
theorem cancel_right (hg : function.surjective g) :
  f.comp g = f'.comp g ↔ f = f' :=
⟨λ h, ext $ hg.forall.2 (ext_iff.1 h), λ h, h ▸ rfl⟩

theorem cancel_left (hf : function.injective f) :
  f.comp g = f.comp g' ↔ g = g' :=
⟨λ h, ext $ λ x, hf $ by rw [← comp_apply, h, comp_apply], λ h, h ▸ rfl⟩
omit σ₁₃

end

variables [add_comm_monoid M] [add_comm_monoid M₁] [add_comm_monoid M₂] [add_comm_monoid M₃]

/-- If a function `g` is a left and right inverse of a linear map `f`, then `g` is linear itself. -/
def inverse [module R M] [module S M₂] {σ : R →+* S} {σ' : S →+* R} [ring_hom_inv_pair σ σ']
  (f : M →ₛₗ[σ] M₂) (g : M₂ → M) (h₁ : left_inverse g f) (h₂ : right_inverse g f) :
  M₂ →ₛₗ[σ'] M :=
by dsimp [left_inverse, function.right_inverse] at h₁ h₂; exact
  { to_fun := g,
    map_add' := λ x y, by { rw [← h₁ (g (x + y)), ← h₁ (g x + g y)]; simp [h₂] },
    map_smul' := λ a b, by { rw [← h₁ (g (a • b)), ← h₁ ((σ' a) • g b)], simp [h₂] } }

end add_comm_monoid

section add_comm_group

variables [semiring R] [semiring S] [add_comm_group M] [add_comm_group M₂]
variables {module_M : module R M} {module_M₂ : module S M₂} {σ : R →+* S}
variables (f : M →ₛₗ[σ] M₂)

protected lemma map_neg (x : M) : f (- x) = - f x := map_neg f x

protected lemma map_sub (x y : M) : f (x - y) = f x - f y := map_sub f x y

instance compatible_smul.int_module
  {S : Type*} [semiring S] [module S M] [module S M₂] : compatible_smul M M₂ ℤ S :=
⟨λ fₗ c x, begin
  induction c using int.induction_on,
  case hz : { simp },
  case hp : n ih { simp [add_smul, ih] },
  case hn : n ih { simp [sub_smul, ih] }
end⟩

instance compatible_smul.units {R S : Type*}
  [monoid R] [mul_action R M] [mul_action R M₂] [semiring S] [module S M] [module S M₂]
  [compatible_smul M M₂ R S] :
  compatible_smul M M₂ Rˣ S :=
⟨λ fₗ c x, (compatible_smul.map_smul fₗ (c : R) x : _)⟩

end add_comm_group

end linear_map

namespace module

/-- `g : R →+* S` is `R`-linear when the module structure on `S` is `module.comp_hom S g` . -/
@[simps]
def comp_hom.to_linear_map {R S : Type*} [semiring R] [semiring S] (g : R →+* S) :
  (by haveI := comp_hom S g; exact (R →ₗ[R] S)) :=
by exact
{ to_fun := (g : R → S),
  map_add' := g.map_add,
  map_smul' := g.map_mul }

end module

namespace distrib_mul_action_hom

variables [semiring R] [add_comm_monoid M] [add_comm_monoid M₂] [module R M] [module R M₂]

/-- A `distrib_mul_action_hom` between two modules is a linear map. -/
def to_linear_map (fₗ : M →+[R] M₂) : M →ₗ[R] M₂ := { ..fₗ }

instance : has_coe (M →+[R] M₂) (M →ₗ[R] M₂) := ⟨to_linear_map⟩

@[simp] lemma to_linear_map_eq_coe (f : M →+[R] M₂) :
  f.to_linear_map = ↑f :=
rfl

@[simp, norm_cast] lemma coe_to_linear_map (f : M →+[R] M₂) :
  ((f : M →ₗ[R] M₂) : M → M₂) = f :=
rfl

lemma to_linear_map_injective {f g : M →+[R] M₂} (h : (f : M →ₗ[R] M₂) = (g : M →ₗ[R] M₂)) :
  f = g :=
by { ext m, exact linear_map.congr_fun h m, }

end distrib_mul_action_hom

namespace is_linear_map

section add_comm_monoid
variables [semiring R] [add_comm_monoid M] [add_comm_monoid M₂]
variables [module R M] [module R M₂]
include R

/-- Convert an `is_linear_map` predicate to a `linear_map` -/
def mk' (f : M → M₂) (H : is_linear_map R f) : M →ₗ[R] M₂ :=
{ to_fun := f, map_add' := H.1, map_smul' := H.2 }

@[simp] theorem mk'_apply {f : M → M₂} (H : is_linear_map R f) (x : M) :
  mk' f H x = f x := rfl

lemma is_linear_map_smul {R M : Type*} [comm_semiring R] [add_comm_monoid M] [module R M]
  (c : R) :
  is_linear_map R (λ (z : M), c • z) :=
begin
  refine is_linear_map.mk (smul_add c) _,
  intros _ _,
  simp only [smul_smul, mul_comm]
end

lemma is_linear_map_smul' {R M : Type*} [semiring R] [add_comm_monoid M] [module R M] (a : M) :
  is_linear_map R (λ (c : R), c • a) :=
is_linear_map.mk (λ x y, add_smul x y a) (λ x y, mul_smul x y a)

variables {f : M → M₂} (lin : is_linear_map R f)
include M M₂ lin

lemma map_zero : f (0 : M) = (0 : M₂) := (lin.mk' f).map_zero

end add_comm_monoid

section add_comm_group

variables [semiring R] [add_comm_group M] [add_comm_group M₂]
variables [module R M] [module R M₂]
include R

lemma is_linear_map_neg :
  is_linear_map R (λ (z : M), -z) :=
is_linear_map.mk neg_add (λ x y, (smul_neg x y).symm)

variables {f : M → M₂} (lin : is_linear_map R f)
include M M₂ lin

lemma map_neg (x : M) : f (- x) = - f x := (lin.mk' f).map_neg x

lemma map_sub (x y) : f (x - y) = f x - f y := (lin.mk' f).map_sub x y

end add_comm_group

end is_linear_map

/-- Linear endomorphisms of a module, with associated ring structure
`module.End.semiring` and algebra structure `module.End.algebra`. -/
abbreviation module.End (R : Type u) (M : Type v)
  [semiring R] [add_comm_monoid M] [module R M] := M →ₗ[R] M

/-- Reinterpret an additive homomorphism as a `ℕ`-linear map. -/
def add_monoid_hom.to_nat_linear_map [add_comm_monoid M] [add_comm_monoid M₂] (f : M →+ M₂) :
  M →ₗ[ℕ] M₂ :=
{ to_fun := f, map_add' := f.map_add, map_smul' := map_nsmul f }

lemma add_monoid_hom.to_nat_linear_map_injective [add_comm_monoid M] [add_comm_monoid M₂] :
  function.injective (@add_monoid_hom.to_nat_linear_map M M₂ _ _) :=
by { intros f g h, ext, exact linear_map.congr_fun h x }

/-- Reinterpret an additive homomorphism as a `ℤ`-linear map. -/
def add_monoid_hom.to_int_linear_map [add_comm_group M] [add_comm_group M₂] (f : M →+ M₂) :
  M →ₗ[ℤ] M₂ :=
{ to_fun := f, map_add' := f.map_add, map_smul' := map_zsmul f }

lemma add_monoid_hom.to_int_linear_map_injective [add_comm_group M] [add_comm_group M₂] :
  function.injective (@add_monoid_hom.to_int_linear_map M M₂ _ _) :=
by { intros f g h, ext, exact linear_map.congr_fun h x }

@[simp] lemma add_monoid_hom.coe_to_int_linear_map [add_comm_group M] [add_comm_group M₂]
  (f : M →+ M₂) :
  ⇑f.to_int_linear_map = f := rfl

/-- Reinterpret an additive homomorphism as a `ℚ`-linear map. -/
def add_monoid_hom.to_rat_linear_map [add_comm_group M] [module ℚ M]
  [add_comm_group M₂] [module ℚ M₂] (f : M →+ M₂) :
  M →ₗ[ℚ] M₂ :=
{ map_smul' := map_rat_smul f, ..f }

lemma add_monoid_hom.to_rat_linear_map_injective
  [add_comm_group M] [module ℚ M] [add_comm_group M₂] [module ℚ M₂] :
  function.injective (@add_monoid_hom.to_rat_linear_map M M₂ _ _ _ _) :=
by { intros f g h, ext, exact linear_map.congr_fun h x }

@[simp] lemma add_monoid_hom.coe_to_rat_linear_map [add_comm_group M] [module ℚ M]
  [add_comm_group M₂] [module ℚ M₂] (f : M →+ M₂) :
  ⇑f.to_rat_linear_map = f := rfl

namespace linear_map

section has_smul

variables [semiring R] [semiring R₂] [semiring R₃]
variables [add_comm_monoid M] [add_comm_monoid M₂] [add_comm_monoid M₃]
variables [module R M] [module R₂ M₂] [module R₃ M₃]
variables {σ₁₂ : R →+* R₂} {σ₂₃ : R₂ →+* R₃} {σ₁₃ : R →+* R₃} [ring_hom_comp_triple σ₁₂ σ₂₃ σ₁₃]
variables [monoid S] [distrib_mul_action S M₂] [smul_comm_class R₂ S M₂]
variables [monoid S₃] [distrib_mul_action S₃ M₃] [smul_comm_class R₃ S₃ M₃]
variables [monoid T] [distrib_mul_action T M₂] [smul_comm_class R₂ T M₂]

instance : has_smul S (M →ₛₗ[σ₁₂] M₂) :=
⟨λ a f, { to_fun := a • f,
          map_add' := λ x y, by simp only [pi.smul_apply, f.map_add, smul_add],
          map_smul' := λ c x, by simp [pi.smul_apply, smul_comm (σ₁₂ c)] }⟩

@[simp] lemma smul_apply (a : S) (f : M →ₛₗ[σ₁₂] M₂) (x : M) : (a • f) x = a • f x := rfl

lemma coe_smul (a : S) (f : M →ₛₗ[σ₁₂] M₂) : ⇑(a • f) = a • f := rfl

instance [smul_comm_class S T M₂] : smul_comm_class S T (M →ₛₗ[σ₁₂] M₂) :=
⟨λ a b f, ext $ λ x, smul_comm _ _ _⟩

-- example application of this instance: if S -> T -> R are homomorphisms of commutative rings and
-- M and M₂ are R-modules then the S-module and T-module structures on Hom_R(M,M₂) are compatible.
instance [has_smul S T] [is_scalar_tower S T M₂] : is_scalar_tower S T (M →ₛₗ[σ₁₂] M₂) :=
{ smul_assoc := λ _ _ _, ext $ λ _, smul_assoc _ _ _ }

instance [distrib_mul_action Sᵐᵒᵖ M₂] [smul_comm_class R₂ Sᵐᵒᵖ M₂] [is_central_scalar S M₂] :
  is_central_scalar S (M →ₛₗ[σ₁₂] M₂) :=
{ op_smul_eq_smul := λ a b, ext $ λ x, op_smul_eq_smul _ _ }

end has_smul

/-! ### Arithmetic on the codomain -/
section arithmetic

variables [semiring R₁] [semiring R₂] [semiring R₃]
variables [add_comm_monoid M] [add_comm_monoid M₂] [add_comm_monoid M₃]
variables [add_comm_group N₁] [add_comm_group N₂] [add_comm_group N₃]
variables [module R₁ M] [module R₂ M₂] [module R₃ M₃]
variables [module R₁ N₁] [module R₂ N₂] [module R₃ N₃]
variables {σ₁₂ : R₁ →+* R₂} {σ₂₃ : R₂ →+* R₃} {σ₁₃ : R₁ →+* R₃} [ring_hom_comp_triple σ₁₂ σ₂₃ σ₁₃]

/-- The constant 0 map is linear. -/
instance : has_zero (M →ₛₗ[σ₁₂] M₂) :=
⟨{ to_fun := 0, map_add' := by simp, map_smul' := by simp }⟩

@[simp] lemma zero_apply (x : M) : (0 : M →ₛₗ[σ₁₂] M₂) x = 0 := rfl

@[simp] theorem comp_zero (g : M₂ →ₛₗ[σ₂₃] M₃) : (g.comp (0 : M →ₛₗ[σ₁₂] M₂) : M →ₛₗ[σ₁₃] M₃) = 0 :=
ext $ assume c, by rw [comp_apply, zero_apply, zero_apply, g.map_zero]

@[simp] theorem zero_comp (f : M →ₛₗ[σ₁₂] M₂) : ((0 : M₂ →ₛₗ[σ₂₃] M₃).comp f : M →ₛₗ[σ₁₃] M₃) = 0 :=
rfl

instance : inhabited (M →ₛₗ[σ₁₂] M₂) := ⟨0⟩

@[simp] lemma default_def : (default : (M →ₛₗ[σ₁₂] M₂)) = 0 := rfl

/-- The sum of two linear maps is linear. -/
instance : has_add (M →ₛₗ[σ₁₂] M₂) :=
⟨λ f g, { to_fun := f + g,
          map_add' := by simp [add_comm, add_left_comm],
          map_smul' := by simp [smul_add] }⟩

@[simp] lemma add_apply (f g : M →ₛₗ[σ₁₂] M₂) (x : M) : (f + g) x = f x + g x := rfl

lemma add_comp (f : M →ₛₗ[σ₁₂] M₂) (g h : M₂ →ₛₗ[σ₂₃] M₃) :
  ((h + g).comp f : M →ₛₗ[σ₁₃] M₃) = h.comp f + g.comp f := rfl

lemma comp_add (f g : M →ₛₗ[σ₁₂] M₂) (h : M₂ →ₛₗ[σ₂₃] M₃) :
  (h.comp (f + g) : M →ₛₗ[σ₁₃] M₃) = h.comp f + h.comp g :=
ext $ λ _, h.map_add _ _

/-- The type of linear maps is an additive monoid. -/
instance : add_comm_monoid (M →ₛₗ[σ₁₂] M₂) :=
fun_like.coe_injective.add_comm_monoid _ rfl (λ _ _, rfl) (λ _ _, rfl)

/-- The negation of a linear map is linear. -/
instance : has_neg (M →ₛₗ[σ₁₂] N₂) :=
⟨λ f, { to_fun := -f, map_add' := by simp [add_comm], map_smul' := by simp }⟩

@[simp] lemma neg_apply (f : M →ₛₗ[σ₁₂] N₂) (x : M) : (- f) x = - f x := rfl

include σ₁₃
@[simp] lemma neg_comp (f : M →ₛₗ[σ₁₂] M₂) (g : M₂ →ₛₗ[σ₂₃] N₃) : (- g).comp f = - g.comp f := rfl

@[simp] lemma comp_neg (f : M →ₛₗ[σ₁₂] N₂) (g : N₂ →ₛₗ[σ₂₃] N₃) : g.comp (- f) = - g.comp f :=
ext $ λ _, g.map_neg _
omit σ₁₃

/-- The negation of a linear map is linear. -/
instance : has_sub (M →ₛₗ[σ₁₂] N₂) :=
⟨λ f g, { to_fun := f - g,
          map_add' := λ x y, by simp only [pi.sub_apply, map_add, add_sub_add_comm],
          map_smul' := λ r x, by simp [pi.sub_apply, map_smul, smul_sub] }⟩

@[simp] lemma sub_apply (f g : M →ₛₗ[σ₁₂] N₂) (x : M) : (f - g) x = f x - g x := rfl

include σ₁₃
lemma sub_comp (f : M →ₛₗ[σ₁₂] M₂) (g h : M₂ →ₛₗ[σ₂₃] N₃) :
  (g - h).comp f = g.comp f - h.comp f := rfl

lemma comp_sub (f g : M →ₛₗ[σ₁₂] N₂) (h : N₂ →ₛₗ[σ₂₃] N₃) :
  h.comp (g - f) = h.comp g - h.comp f :=
ext $ λ _, h.map_sub _ _
omit σ₁₃

/-- The type of linear maps is an additive group. -/
instance : add_comm_group (M →ₛₗ[σ₁₂] N₂) :=
fun_like.coe_injective.add_comm_group _
  rfl (λ _ _, rfl) (λ _, rfl) (λ _ _, rfl) (λ _ _, rfl)  (λ _ _, rfl)

end arithmetic

section actions

variables [semiring R] [semiring R₂] [semiring R₃]
variables [add_comm_monoid M] [add_comm_monoid M₂] [add_comm_monoid M₃]
variables [module R M] [module R₂ M₂] [module R₃ M₃]
variables {σ₁₂ : R →+* R₂} {σ₂₃ : R₂ →+* R₃} {σ₁₃ : R →+* R₃} [ring_hom_comp_triple σ₁₂ σ₂₃ σ₁₃]

section has_smul
variables [monoid S] [distrib_mul_action S M₂] [smul_comm_class R₂ S M₂]
variables [monoid S₃] [distrib_mul_action S₃ M₃] [smul_comm_class R₃ S₃ M₃]
variables [monoid T] [distrib_mul_action T M₂] [smul_comm_class R₂ T M₂]

instance : distrib_mul_action S (M →ₛₗ[σ₁₂] M₂) :=
{ one_smul := λ f, ext $ λ _, one_smul _ _,
  mul_smul := λ c c' f, ext $ λ _, mul_smul _ _ _,
  smul_add := λ c f g, ext $ λ x, smul_add _ _ _,
  smul_zero := λ c, ext $ λ x, smul_zero _ }

include σ₁₃
theorem smul_comp (a : S₃) (g : M₂ →ₛₗ[σ₂₃] M₃) (f : M →ₛₗ[σ₁₂] M₂) :
  (a • g).comp f = a • (g.comp f) := rfl
omit σ₁₃

-- TODO: generalize this to semilinear maps
theorem comp_smul [module R M₂] [module R M₃] [smul_comm_class R S M₂] [distrib_mul_action S M₃]
  [smul_comm_class R S M₃] [compatible_smul M₃ M₂ S R]
  (g : M₃ →ₗ[R] M₂) (a : S) (f : M →ₗ[R] M₃) : g.comp (a • f) = a • (g.comp f) :=
ext $ λ x, g.map_smul_of_tower _ _

end has_smul

section module
variables [semiring S] [module S M₂] [smul_comm_class R₂ S M₂]

instance : module S (M →ₛₗ[σ₁₂] M₂) :=
{ add_smul := λ a b f, ext $ λ x, add_smul _ _ _,
  zero_smul := λ f, ext $ λ x, zero_smul _ _ }

instance [no_zero_smul_divisors S M₂] : no_zero_smul_divisors S (M →ₛₗ[σ₁₂] M₂) :=
coe_injective.no_zero_smul_divisors _ rfl coe_smul

end module

end actions

/-!
### Monoid structure of endomorphisms

Lemmas about `pow` such as `linear_map.pow_apply` appear in later files.
-/
section endomorphisms

variables [semiring R] [add_comm_monoid M] [add_comm_group N₁] [module R M] [module R N₁]

instance : has_one (module.End R M) := ⟨linear_map.id⟩
instance : has_mul (module.End R M) := ⟨linear_map.comp⟩

lemma one_eq_id : (1 : module.End R M) = id := rfl
lemma mul_eq_comp (f g : module.End R M) : f * g = f.comp g := rfl

@[simp] lemma one_apply (x : M) : (1 : module.End R M) x = x := rfl
@[simp] lemma mul_apply (f g : module.End R M) (x : M) : (f * g) x = f (g x) := rfl

lemma coe_one : ⇑(1 : module.End R M) = _root_.id := rfl
lemma coe_mul (f g : module.End R M) : ⇑(f * g) = f ∘ g := rfl

instance _root_.module.End.monoid : monoid (module.End R M) :=
{ mul := (*),
  one := (1 : M →ₗ[R] M),
  mul_assoc := λ f g h, linear_map.ext $ λ x, rfl,
  mul_one := comp_id,
  one_mul := id_comp }

instance _root_.module.End.semiring : semiring (module.End R M) :=
{ mul := (*),
  one := (1 : M →ₗ[R] M),
  zero := 0,
  add := (+),
  mul_zero := comp_zero,
  zero_mul := zero_comp,
  left_distrib := λ f g h, comp_add _ _ _,
  right_distrib := λ f g h, add_comp _ _ _,
  nat_cast := λ n, n • 1,
  nat_cast_zero := add_monoid.nsmul_zero' _,
  nat_cast_succ := λ n, (add_monoid.nsmul_succ' n 1).trans (add_comm _ _),
  .. add_monoid_with_one.unary,
  .. _root_.module.End.monoid,
  .. linear_map.add_comm_monoid }

/-- See also `module.End.nat_cast_def`. -/
@[simp] lemma _root_.module.End.nat_cast_apply (n : ℕ) (m : M) :
  (↑n : module.End R M) m = n • m := rfl

instance _root_.module.End.ring : ring (module.End R N₁) :=
{ int_cast := λ z, z • 1,
  int_cast_of_nat := of_nat_zsmul _,
  int_cast_neg_succ_of_nat := zsmul_neg_succ_of_nat _,
  ..module.End.semiring, ..linear_map.add_comm_group }

/-- See also `module.End.int_cast_def`. -/
@[simp] lemma _root_.module.End.int_cast_apply (z : ℤ) (m : N₁) :
  (↑z : module.End R N₁) m = z • m := rfl

section
variables [monoid S] [distrib_mul_action S M] [smul_comm_class R S M]

instance _root_.module.End.is_scalar_tower :
  is_scalar_tower S (module.End R M) (module.End R M) := ⟨smul_comp⟩

instance _root_.module.End.smul_comm_class [has_smul S R] [is_scalar_tower S R M] :
  smul_comm_class S (module.End R M) (module.End R M) :=
⟨λ s _ _, (comp_smul _ s _).symm⟩

instance _root_.module.End.smul_comm_class' [has_smul S R] [is_scalar_tower S R M] :
  smul_comm_class (module.End R M) S (module.End R M) :=
smul_comm_class.symm _ _ _

end

/-! ### Action by a module endomorphism. -/

/-- The tautological action by `module.End R M` (aka `M →ₗ[R] M`) on `M`.

This generalizes `function.End.apply_mul_action`. -/
instance apply_module : module (module.End R M) M :=
{ smul := ($),
  smul_zero := linear_map.map_zero,
  smul_add := linear_map.map_add,
  add_smul := linear_map.add_apply,
  zero_smul := (linear_map.zero_apply : ∀ m, (0 : M →ₗ[R] M) m = 0),
  one_smul := λ _, rfl,
  mul_smul := λ _ _ _, rfl }

@[simp] protected lemma smul_def (f : module.End R M) (a : M) : f • a = f a := rfl

/-- `linear_map.apply_module` is faithful. -/
instance apply_has_faithful_smul : has_faithful_smul (module.End R M) M :=
⟨λ _ _, linear_map.ext⟩

instance apply_smul_comm_class : smul_comm_class R (module.End R M) M :=
{ smul_comm := λ r e m, (e.map_smul r m).symm }

instance apply_smul_comm_class' : smul_comm_class (module.End R M) R M :=
{ smul_comm := linear_map.map_smul }

instance apply_is_scalar_tower {R M : Type*} [comm_semiring R] [add_comm_monoid M] [module R M] :
  is_scalar_tower R (module.End R M) M :=
⟨λ t f m, rfl⟩

end endomorphisms

end linear_map

/-! ### Actions as module endomorphisms -/

namespace distrib_mul_action

variables (R M) [semiring R] [add_comm_monoid M] [module R M]
variables [monoid S] [distrib_mul_action S M] [smul_comm_class S R M]

/-- Each element of the monoid defines a linear map.

This is a stronger version of `distrib_mul_action.to_add_monoid_hom`. -/
@[simps]
def to_linear_map (s : S) : M →ₗ[R] M :=
{ to_fun := has_smul.smul s,
  map_add' := smul_add s,
  map_smul' := λ a b, smul_comm _ _ _ }

/-- Each element of the monoid defines a module endomorphism.

This is a stronger version of `distrib_mul_action.to_add_monoid_End`. -/
@[simps]
def to_module_End : S →* module.End R M :=
{ to_fun := to_linear_map R M,
  map_one' := linear_map.ext $ one_smul _,
  map_mul' := λ a b, linear_map.ext $ mul_smul _ _ }

end distrib_mul_action

namespace module

variables (R M) [semiring R] [add_comm_monoid M] [module R M]
variables [semiring S] [module S M] [smul_comm_class S R M]

/-- Each element of the semiring defines a module endomorphism.

This is a stronger version of `distrib_mul_action.to_module_End`. -/
@[simps]
def to_module_End : S →+* module.End R M :=
{ to_fun := distrib_mul_action.to_linear_map R M,
  map_zero' := linear_map.ext $ zero_smul _,
  map_add' := λ f g, linear_map.ext $ add_smul _ _,
  ..distrib_mul_action.to_module_End R M }

/-- The canonical (semi)ring isomorphism from `Rᵐᵒᵖ` to `module.End R R` induced by the right
multiplication. -/
@[simps]
def module_End_self : Rᵐᵒᵖ ≃+* module.End R R :=
{ to_fun := distrib_mul_action.to_linear_map R R,
  inv_fun := λ f, mul_opposite.op (f 1),
  left_inv := mul_one,
  right_inv := λ f, linear_map.ext_ring $ one_mul _,
  ..module.to_module_End R R }

/-- The canonical (semi)ring isomorphism from `R` to `module.End Rᵐᵒᵖ R` induced by the left
multiplication. -/
@[simps]
def module_End_self_op : R ≃+* module.End Rᵐᵒᵖ R :=
{ to_fun := distrib_mul_action.to_linear_map _ _,
  inv_fun := λ f, f 1,
  left_inv := mul_one,
  right_inv := λ f, linear_map.ext_ring_op $ mul_one _,
  ..module.to_module_End _ _ }

lemma End.nat_cast_def (n : ℕ) [add_comm_monoid N₁] [module R N₁] :
  (↑n : module.End R N₁) = module.to_module_End R N₁ n := rfl

lemma End.int_cast_def (z : ℤ) [add_comm_group N₁] [module R N₁] :
  (↑z : module.End R N₁) = module.to_module_End R N₁ z := rfl

end module
