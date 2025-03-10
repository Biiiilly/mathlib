/-
Copyright (c) 2021 Yaël Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies
-/
import data.set.image

/-!
# Monovariance of functions

Two functions *vary together* if a strict change in the first implies a change in the second.

This is in some sense a way to say that two functions `f : ι → α`, `g : ι → β` are "monotone
together", without actually having an order on `ι`.

This condition comes up in the rearrangement inequality. See `algebra.order.rearrangement`.

## Main declarations

* `monovary f g`: `f` monovaries with `g`. If `g i < g j`, then `f i ≤ f j`.
* `antivary f g`: `f` antivaries with `g`. If `g i < g j`, then `f j ≤ f i`.
* `monovary_on f g s`: `f` monovaries with `g` on `s`.
* `monovary_on f g s`: `f` antivaries with `g` on `s`.
-/

open function set

variables {ι ι' α β γ : Type*}

section preorder
variables [preorder α] [preorder β] [preorder γ] {f : ι → α} {f' : α → γ} {g : ι → β} {g' : β → γ}
  {s t : set ι}

/--  `f` monovaries with `g` if `g i < g j` implies `f i ≤ f j`. -/
def monovary (f : ι → α) (g : ι → β) : Prop := ∀ ⦃i j⦄, g i < g j → f i ≤ f j

/--  `f` antivaries with `g` if `g i < g j` implies `f j ≤ f i`. -/
def antivary (f : ι → α) (g : ι → β) : Prop := ∀ ⦃i j⦄, g i < g j → f j ≤ f i

/--  `f` monovaries with `g` on `s` if `g i < g j` implies `f i ≤ f j` for all `i, j ∈ s`. -/
def monovary_on (f : ι → α) (g : ι → β) (s : set ι) : Prop :=
∀ ⦃i⦄ (hi : i ∈ s) ⦃j⦄ (hj : j ∈ s), g i < g j → f i ≤ f j

/--  `f` antivaries with `g` on `s` if `g i < g j` implies `f j ≤ f i` for all `i, j ∈ s`. -/
def antivary_on (f : ι → α) (g : ι → β) (s : set ι) : Prop :=
∀ ⦃i⦄ (hi : i ∈ s) ⦃j⦄ (hj : j ∈ s), g i < g j → f j ≤ f i

protected lemma monovary.monovary_on (h : monovary f g) (s : set ι) : monovary_on f g s :=
λ i _ j _ hij, h hij

protected lemma antivary.antivary_on (h : antivary f g) (s : set ι) : antivary_on f g s :=
λ i _ j _ hij, h hij

@[simp] lemma monovary_on.empty : monovary_on f g ∅ := λ i, false.elim
@[simp] lemma antivary_on.empty : antivary_on f g ∅ := λ i, false.elim

@[simp] lemma monovary_on_univ : monovary_on f g univ ↔ monovary f g :=
⟨λ h i j, h trivial trivial, λ h i _ j _ hij, h hij⟩

@[simp] lemma antivary_on_univ : antivary_on f g univ ↔ antivary f g :=
⟨λ h i j, h trivial trivial, λ h i _ j _ hij, h hij⟩

protected lemma monovary_on.subset (hst : s ⊆ t) (h : monovary_on f g t) : monovary_on f g s :=
λ i hi j hj, h (hst hi) (hst hj)

protected lemma antivary_on.subset (hst : s ⊆ t) (h : antivary_on f g t) : antivary_on f g s :=
λ i hi j hj, h (hst hi) (hst hj)

lemma monovary_const_left (g : ι → β) (a : α) : monovary (const ι a) g := λ i j _, le_rfl
lemma antivary_const_left (g : ι → β) (a : α) : antivary (const ι a) g := λ i j _, le_rfl
lemma monovary_const_right (f : ι → α) (b : β) : monovary f (const ι b) := λ i j h, (h.ne rfl).elim
lemma antivary_const_right (f : ι → α) (b : β) : antivary f (const ι b) := λ i j h, (h.ne rfl).elim

lemma monovary_self (f : ι → α) : monovary f f := λ i j, le_of_lt
lemma monovary_on_self (f : ι → α) (s : set ι) : monovary_on f f s := λ i _ j _, le_of_lt

protected lemma subsingleton.monovary [subsingleton ι] (f : ι → α) (g : ι → β) : monovary f g :=
λ i j h, (ne_of_apply_ne _ h.ne $ subsingleton.elim _ _).elim

protected lemma subsingleton.antivary [subsingleton ι] (f : ι → α) (g : ι → β) : antivary f g :=
λ i j h, (ne_of_apply_ne _ h.ne $ subsingleton.elim _ _).elim

protected lemma subsingleton.monovary_on [subsingleton ι] (f : ι → α) (g : ι → β) (s : set ι) :
  monovary_on f g s :=
λ i _ j _ h, (ne_of_apply_ne _ h.ne $ subsingleton.elim _ _).elim

protected lemma subsingleton.antivary_on [subsingleton ι] (f : ι → α) (g : ι → β) (s : set ι) :
  antivary_on f g s :=
λ i _ j _ h, (ne_of_apply_ne _ h.ne $ subsingleton.elim _ _).elim

lemma monovary_on_const_left (g : ι → β) (a : α) (s : set ι) : monovary_on (const ι a) g s :=
λ i _ j _ _, le_rfl

lemma antivary_on_const_left (g : ι → β) (a : α) (s : set ι) : antivary_on (const ι a) g s :=
λ i _ j _ _, le_rfl

lemma monovary_on_const_right (f : ι → α) (b : β) (s : set ι) : monovary_on f (const ι b) s :=
λ i _ j _ h, (h.ne rfl).elim

lemma antivary_on_const_right (f : ι → α) (b : β) (s : set ι) : antivary_on f (const ι b) s :=
λ i _ j _ h, (h.ne rfl).elim

lemma monovary.comp_right (h : monovary f g) (k : ι' → ι) : monovary (f ∘ k) (g ∘ k) :=
λ i j hij, h hij

lemma antivary.comp_right (h : antivary f g) (k : ι' → ι) : antivary (f ∘ k) (g ∘ k) :=
λ i j hij, h hij

lemma monovary_on.comp_right (h : monovary_on f g s) (k : ι' → ι) :
  monovary_on (f ∘ k) (g ∘ k) (k ⁻¹' s) :=
λ i hi j hj, h hi hj

lemma antivary_on.comp_right (h : antivary_on f g s) (k : ι' → ι) :
  antivary_on (f ∘ k) (g ∘ k) (k ⁻¹' s) :=
λ i hi j hj, h hi hj

lemma monovary.comp_monotone_left (h : monovary f g) (hf : monotone f') : monovary (f' ∘ f) g :=
λ i j hij, hf $ h hij

lemma monovary.comp_antitone_left (h : monovary f g) (hf : antitone f') : antivary (f' ∘ f) g :=
λ i j hij, hf $ h hij

lemma antivary.comp_monotone_left (h : antivary f g) (hf : monotone f') : antivary (f' ∘ f) g :=
λ i j hij, hf $ h hij

lemma antivary.comp_antitone_left (h : antivary f g) (hf : antitone f') : monovary (f' ∘ f) g :=
λ i j hij, hf $ h hij

lemma monovary_on.comp_monotone_on_left (h : monovary_on f g s) (hf : monotone f') :
  monovary_on (f' ∘ f) g s :=
λ i hi j hj hij, hf $ h hi hj hij

lemma monovary_on.comp_antitone_on_left (h : monovary_on f g s) (hf : antitone f') :
  antivary_on (f' ∘ f) g s :=
λ i hi j hj hij, hf $ h hi hj hij

lemma antivary_on.comp_monotone_on_left (h : antivary_on f g s) (hf : monotone f') :
  antivary_on (f' ∘ f) g s :=
λ i hi j hj hij, hf $ h hi hj hij

lemma antivary_on.comp_antitone_on_left (h : antivary_on f g s) (hf : antitone f') :
  monovary_on (f' ∘ f) g s :=
λ i hi j hj hij, hf $ h hi hj hij

section order_dual
open order_dual

lemma monovary.dual : monovary f g → monovary (to_dual ∘ f) (to_dual ∘ g) := swap
lemma antivary.dual : antivary f g → antivary (to_dual ∘ f) (to_dual ∘ g) := swap
lemma monovary.dual_left : monovary f g → antivary (to_dual ∘ f) g := id
lemma antivary.dual_left : antivary f g → monovary (to_dual ∘ f) g := id
lemma monovary.dual_right : monovary f g → antivary f (to_dual ∘ g) := swap
lemma antivary.dual_right : antivary f g → monovary f (to_dual ∘ g) := swap

lemma monovary_on.dual : monovary_on f g s → monovary_on (to_dual ∘ f) (to_dual ∘ g) s := swap₂
lemma antivary_on.dual : antivary_on f g s → antivary_on (to_dual ∘ f) (to_dual ∘ g) s := swap₂
lemma monovary_on.dual_left : monovary_on f g s → antivary_on (to_dual ∘ f) g s := id
lemma antivary_on.dual_left : antivary_on f g s → monovary_on (to_dual ∘ f) g s := id
lemma monovary_on.dual_right : monovary_on f g s → antivary_on f (to_dual ∘ g) s := swap₂
lemma antivary_on.dual_right : antivary_on f g s → monovary_on f (to_dual ∘ g) s := swap₂

@[simp] lemma monovary_to_dual_left : monovary (to_dual ∘ f) g ↔ antivary f g := iff.rfl
@[simp] lemma monovary_to_dual_right : monovary f (to_dual ∘ g) ↔ antivary f g := forall_swap
@[simp] lemma antivary_to_dual_left : antivary (to_dual ∘ f) g ↔ monovary f g := iff.rfl
@[simp] lemma antivary_to_dual_right : antivary f (to_dual ∘ g) ↔ monovary f g := forall_swap

@[simp] lemma monovary_on_to_dual_left : monovary_on (to_dual ∘ f) g s ↔ antivary_on f g s :=
iff.rfl
@[simp] lemma monovary_on_to_dual_right : monovary_on f (to_dual ∘ g) s ↔ antivary_on f g s :=
forall₂_swap
@[simp] lemma antivary_on_to_dual_left : antivary_on (to_dual ∘ f) g s ↔ monovary_on f g s :=
iff.rfl
@[simp] lemma antivary_on_to_dual_right : antivary_on f (to_dual ∘ g) s ↔ monovary_on f g s :=
forall₂_swap

end order_dual

section partial_order
variables [partial_order ι]

@[simp] lemma monovary_id_iff : monovary f id ↔ monotone f := monotone_iff_forall_lt.symm
@[simp] lemma antivary_id_iff : antivary f id ↔ antitone f := antitone_iff_forall_lt.symm

@[simp] lemma monovary_on_id_iff : monovary_on f id s ↔ monotone_on f s :=
monotone_on_iff_forall_lt.symm

@[simp] lemma antivary_on_id_iff : antivary_on f id s ↔ antitone_on f s :=
antitone_on_iff_forall_lt.symm

end partial_order

variables [linear_order ι]

protected lemma monotone.monovary (hf : monotone f) (hg : monotone g) : monovary f g :=
λ i j hij, hf (hg.reflect_lt hij).le

protected lemma monotone.antivary (hf : monotone f) (hg : antitone g) : antivary f g :=
(hf.monovary hg.dual_right).dual_right

protected lemma antitone.monovary (hf : antitone f) (hg : antitone g) : monovary f g :=
(hf.dual_right.antivary hg).dual_left

protected lemma antitone.antivary (hf : antitone f) (hg : monotone g) : antivary f g :=
(hf.monovary hg.dual_right).dual_right

protected lemma monotone_on.monovary_on (hf : monotone_on f s) (hg : monotone_on g s) :
  monovary_on f g s :=
λ i hi j hj hij, hf hi hj (hg.reflect_lt hi hj hij).le

protected lemma monotone_on.antivary_on (hf : monotone_on f s) (hg : antitone_on g s) :
  antivary_on f g s :=
(hf.monovary_on hg.dual_right).dual_right

protected lemma antitone_on.monovary_on (hf : antitone_on f s) (hg : antitone_on g s) :
  monovary_on f g s :=
(hf.dual_right.antivary_on hg).dual_left

protected lemma antitone_on.antivary_on (hf : antitone_on f s) (hg : monotone_on g s) :
  antivary_on f g s :=
(hf.monovary_on hg.dual_right).dual_right

end preorder

section linear_order
variables [preorder α] [linear_order β] [preorder γ] {f : ι → α} {f' : α → γ} {g : ι → β}
  {g' : β → γ} {s : set ι}

lemma monovary_on.comp_monotone_on_right (h : monovary_on f g s) (hg : monotone_on g' (g '' s)) :
  monovary_on f (g' ∘ g) s :=
λ i hi j hj hij, h hi hj $ hg.reflect_lt (mem_image_of_mem _ hi) (mem_image_of_mem _ hj) hij

lemma monovary_on.comp_antitone_on_right (h : monovary_on f g s) (hg : antitone_on g' (g '' s)) :
  antivary_on f (g' ∘ g) s :=
λ i hi j hj hij, h hj hi $ hg.reflect_lt (mem_image_of_mem _ hi) (mem_image_of_mem _ hj) hij

lemma antivary_on.comp_monotone_on_right (h : antivary_on f g s) (hg : monotone_on g' (g '' s)) :
  antivary_on f (g' ∘ g) s :=
λ i hi j hj hij, h hi hj $ hg.reflect_lt (mem_image_of_mem _ hi) (mem_image_of_mem _ hj) hij

lemma antivary_on.comp_antitone_on_right (h : antivary_on f g s) (hg : antitone_on g' (g '' s)) :
  monovary_on f (g' ∘ g) s :=
λ i hi j hj hij, h hj hi $ hg.reflect_lt (mem_image_of_mem _ hi) (mem_image_of_mem _ hj) hij

protected lemma monovary.symm (h : monovary f g) : monovary g f :=
λ i j hf, le_of_not_lt $ λ hg, hf.not_le $ h hg

protected lemma antivary.symm (h : antivary f g) : antivary g f :=
λ i j hf, le_of_not_lt $ λ hg, hf.not_le $ h hg

protected lemma monovary_on.symm (h : monovary_on f g s) : monovary_on g f s :=
λ i hi j hj hf, le_of_not_lt $ λ hg, hf.not_le $ h hj hi hg

protected lemma antivary_on.symm (h : antivary_on f g s) : antivary_on g f s :=
λ i hi j hj hf, le_of_not_lt $ λ hg, hf.not_le $ h hi hj hg

end linear_order

section linear_order
variables [linear_order α] [linear_order β] {f : ι → α} {g : ι → β} {s : set ι}

protected lemma monovary_comm : monovary f g ↔ monovary g f := ⟨monovary.symm, monovary.symm⟩
protected lemma antivary_comm : antivary f g ↔ antivary g f := ⟨antivary.symm, antivary.symm⟩

protected lemma monovary_on_comm : monovary_on f g s ↔ monovary_on g f s :=
⟨monovary_on.symm, monovary_on.symm⟩

protected lemma antivary_on_comm : antivary_on f g s ↔ antivary_on g f s :=
⟨antivary_on.symm, antivary_on.symm⟩

end linear_order
