/-
Copyright (c) 2020 Patrick Stevens. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Patrick Stevens, Bolton Bailey
-/
import data.nat.choose.factorization
import number_theory.primorial
import analysis.convex.specific_functions

/-!
# Bertrand's Postulate

This file contains a proof of Bertrand's postulate: That between any positive number and its
double there is a prime.

The proof follows the outline of the Erdős proof presented in "Proofs from THE BOOK": One considers
the prime factorization of `(2 * n).choose n`, and splits the constituent primes up into various
groups, then upper bounds the contribution of each group. This upper bounds the central binomial
coefficient, and if the postulate does not hold, this upper bound conflicts with a simple lower
bound for large enough `n`. This proves the result holds for large enough `n`, and for smaller `n`
an explicit list of primes is provided which covers the remaining cases.

As in the [Metamath implementation](carneiro2015arithmetic), we rely on some optimizations from
[Shigenori Tochiori](tochiori_bertrand). In particular we use the cleaner bound on the central
binomial coefficient given in `nat.four_pow_lt_mul_central_binom`.

## References

* [M. Aigner and G. M. Ziegler _Proofs from THE BOOK_][aigner1999proofs]
* [S. Tochiori, _Considering the Proof of “There is a Prime between n and 2n”_][tochiori_bertrand]
* [M. Carneiro, _Arithmetic in Metamath, Case Study: Bertrand's Postulate_][carneiro2015arithmetic]

## Tags

Bertrand, prime, binomial coefficients
-/

open_locale big_operators

section real

open real

namespace bertrand

/--
A reified version of the `bertrand.main_inequality` below.
This is not best possible: it actually holds for 464 ≤ x.
-/
lemma real_main_inequality {x : ℝ} (n_large : (512 : ℝ) ≤ x) :
  x * (2 * x) ^ (sqrt (2 * x)) * 4 ^ (2 * x / 3) ≤ 4 ^ x :=
begin
  let f : ℝ → ℝ := λ x, log x + sqrt (2 * x) * log (2 * x) - log 4 / 3 * x,
  have hf' : ∀ x, 0 < x → 0 < x * (2 * x) ^ sqrt (2 * x) / 4 ^ (x / 3) :=
  λ x h, div_pos (mul_pos h (rpow_pos_of_pos (mul_pos two_pos h) _)) (rpow_pos_of_pos four_pos _),
  have hf : ∀ x, 0 < x → f x = log (x * (2 * x) ^ sqrt (2 * x) / 4 ^ (x / 3)),
  { intros x h5,
    have h6 := mul_pos (zero_lt_two' ℝ) h5,
    have h7 := rpow_pos_of_pos h6 (sqrt (2 * x)),
    rw [log_div (mul_pos h5 h7).ne' (rpow_pos_of_pos four_pos _).ne', log_mul h5.ne' h7.ne',
      log_rpow h6, log_rpow zero_lt_four, ← mul_div_right_comm, ← mul_div, mul_comm x] },
  have h5 : 0 < x := lt_of_lt_of_le (by norm_num1) n_large,
  rw [← div_le_one (rpow_pos_of_pos four_pos x), ← div_div_eq_mul_div, ← rpow_sub four_pos,
      ← mul_div 2 x, mul_div_left_comm, ← mul_one_sub, (by norm_num1 : (1 : ℝ) - 2 / 3 = 1 / 3),
      mul_one_div, ← log_nonpos_iff (hf' x h5), ← hf x h5],
  have h : concave_on ℝ (set.Ioi 0.5) f,
  { refine ((strict_concave_on_log_Ioi.concave_on.subset (set.Ioi_subset_Ioi _)
      (convex_Ioi 0.5)).add ((strict_concave_on_sqrt_mul_log_Ioi.concave_on.comp_linear_map
      ((2 : ℝ) • linear_map.id)).subset
      (λ a ha, lt_of_eq_of_lt _ ((mul_lt_mul_left two_pos).mpr ha)) (convex_Ioi 0.5))).sub
      ((convex_on_id (convex_Ioi (0.5 : ℝ))).smul (div_nonneg (log_nonneg _) _)); norm_num1 },
  suffices : ∃ x1 x2, 0.5 < x1 ∧ x1 < x2 ∧ x2 ≤ x ∧ 0 ≤ f x1 ∧ f x2 ≤ 0,
  { obtain ⟨x1, x2, h1, h2, h0, h3, h4⟩ := this,
    exact (h.right_le_of_le_left'' h1 ((h1.trans h2).trans_le h0) h2 h0 (h4.trans h3)).trans h4 },
  refine ⟨18, 512, by norm_num1, by norm_num1, le_trans (by norm_num1) n_large, _, _⟩,
  { have : sqrt (2 * 18) = 6 :=
    (sqrt_eq_iff_mul_self_eq_of_pos (by norm_num1)).mpr (by norm_num1),
    rw [hf, log_nonneg_iff (hf' 18 _), this]; norm_num1 },
  { have : sqrt (2 * 512) = 32,
    { exact (sqrt_eq_iff_mul_self_eq_of_pos (by norm_num1)).mpr (by norm_num1) },
    rw [hf, log_nonpos_iff (hf' _ _), this, div_le_one (rpow_pos_of_pos four_pos _),
      ← rpow_le_rpow_iff _ (rpow_pos_of_pos four_pos _).le three_pos, ← rpow_mul]; norm_num1 },
end

end bertrand

end real

section nat

open nat

/--
The inequality which contradicts Bertrand's postulate, for large enough `n`.
-/
lemma bertrand_main_inequality {n : ℕ} (n_large : 512 ≤ n) :
  n * (2 * n) ^ sqrt (2 * n) * 4 ^ (2 * n / 3) ≤ 4 ^ n :=
begin
  rw ← @cast_le ℝ,
  simp only [cast_bit0, cast_add, cast_one, cast_mul, cast_pow, ← real.rpow_nat_cast],
  have n_pos : 0 < n := (dec_trivial : 0 < 512).trans_le n_large,
  have n2_pos : 1 ≤ 2 * n := mul_pos dec_trivial n_pos,
  refine trans (mul_le_mul _ _ _ _) (bertrand.real_main_inequality (by exact_mod_cast n_large)),
  { refine mul_le_mul_of_nonneg_left _ (nat.cast_nonneg _),
    refine real.rpow_le_rpow_of_exponent_le (by exact_mod_cast n2_pos) _,
    exact_mod_cast real.nat_sqrt_le_real_sqrt },
  { exact real.rpow_le_rpow_of_exponent_le (by norm_num1) (cast_div_le.trans (by norm_cast)) },
  { exact real.rpow_nonneg_of_nonneg (by norm_num1) _ },
  { refine mul_nonneg (nat.cast_nonneg _) _,
    exact real.rpow_nonneg_of_nonneg (mul_nonneg zero_le_two (nat.cast_nonneg _)) _, },
end

/--
A lemma that tells us that, in the case where Bertrand's postulate does not hold, the prime
factorization of the central binomial coefficent only has factors at most `2 * n / 3 + 1`.
-/
lemma central_binom_factorization_small (n : ℕ) (n_large : 2 < n)
  (no_prime: ¬∃ (p : ℕ), p.prime ∧ n < p ∧ p ≤ 2 * n) :
  central_binom n = ∏ p in finset.range (2 * n / 3 + 1), p ^ ((central_binom n).factorization p) :=
begin
  refine (eq.trans _ n.prod_pow_factorization_central_binom).symm,
  apply finset.prod_subset,
  { exact finset.range_subset.2 (add_le_add_right (nat.div_le_self _ _) _) },
  intros x hx h2x,
  rw [finset.mem_range, lt_succ_iff] at hx h2x,
  rw [not_le, div_lt_iff_lt_mul' three_pos, mul_comm x] at h2x,
  replace no_prime := not_exists.mp no_prime x,
  rw [←and_assoc, not_and', not_and_distrib, not_lt] at no_prime,
  cases no_prime hx with h h,
  { rw [factorization_eq_zero_of_non_prime n.central_binom h, pow_zero] },
  { rw [factorization_central_binom_of_two_mul_self_lt_three_mul n_large h h2x, pow_zero] },
end

/--
An upper bound on the central binomial coefficient used in the proof of Bertrand's postulate.
The bound splits the prime factors of `central_binom n` into those
1. At most `sqrt (2 * n)`, which contribute at most `2 * n` for each such prime.
2. Between `sqrt (2 * n)` and `2 * n / 3`, which contribute at most `4^(2 * n / 3)` in total.
3. Between `2 * n / 3` and `n`, which do not exist.
4. Between `n` and `2 * n`, which would not exist in the case where Bertrand's postulate is false.
5. Above `2 * n`, which do not exist.
-/
lemma central_binom_le_of_no_bertrand_prime (n : ℕ) (n_big : 2 < n)
  (no_prime : ¬∃ (p : ℕ), nat.prime p ∧ n < p ∧ p ≤ 2 * n) :
  central_binom n ≤ (2 * n) ^ sqrt (2 * n) * 4 ^ (2 * n / 3) :=
begin
  have n_pos : 0 < n := (nat.zero_le _).trans_lt n_big,
  have n2_pos : 1 ≤ 2 * n := mul_pos (zero_lt_two' ℕ) n_pos,
  let S := (finset.range (2 * n / 3 + 1)).filter nat.prime,
  let f := λ x, x ^ n.central_binom.factorization x,
  have : ∏ (x : ℕ) in S, f x = ∏ (x : ℕ) in finset.range (2 * n / 3 + 1), f x,
  { refine finset.prod_filter_of_ne (λ p hp h, _),
    contrapose! h, dsimp only [f],
    rw [factorization_eq_zero_of_non_prime n.central_binom h, pow_zero] },
  rw [central_binom_factorization_small n n_big no_prime, ← this,
    ← finset.prod_filter_mul_prod_filter_not S (≤ sqrt (2 * n))],
  apply mul_le_mul',
  { refine (finset.prod_le_prod'' (λ p hp, (_ : f p ≤ 2 * n))).trans _,
    { exact pow_factorization_choose_le (mul_pos two_pos n_pos) },
    have : (finset.Icc 1 (sqrt (2 * n))).card = sqrt (2 * n),
    { rw [card_Icc, nat.add_sub_cancel] },
    rw finset.prod_const,
    refine pow_le_pow n2_pos ((finset.card_le_of_subset (λ x hx, _)).trans this.le),
    obtain ⟨h1, h2⟩ := finset.mem_filter.1 hx,
    exact finset.mem_Icc.mpr ⟨(finset.mem_filter.1 h1).2.one_lt.le, h2⟩ },
  { refine le_trans _ (primorial_le_4_pow (2 * n / 3)),
    refine (finset.prod_le_prod' (λ p hp, (_ : f p ≤ p))).trans _,
    { obtain ⟨h1, h2⟩ := finset.mem_filter.1 hp,
      refine (pow_le_pow (finset.mem_filter.1 h1).2.one_lt.le _).trans (pow_one p).le,
      exact nat.factorization_choose_le_one (sqrt_lt'.mp $ not_le.1 h2) },
    refine finset.prod_le_prod_of_subset_of_one_le' (finset.filter_subset _ _) _,
    exact λ p hp _, (finset.mem_filter.1 hp).2.one_lt.le }
end

namespace nat

/--
Proves that Bertrand's postulate holds for all sufficiently large `n`.
-/
lemma exists_prime_lt_and_le_two_mul_eventually (n : ℕ) (n_big : 512 ≤ n) :
  ∃ (p : ℕ), p.prime ∧ n < p ∧ p ≤ 2 * n :=
begin
  -- Assume there is no prime in the range.
  by_contradiction no_prime,
  -- Then we have the above sub-exponential bound on the size of this central binomial coefficient.
  -- We now couple this bound with an exponential lower bound on the central binomial coefficient,
  -- yielding an inequality which we have seen is false for large enough n.
  have H1 : n * (2 * n) ^ sqrt (2 * n) * 4 ^ (2 * n / 3) ≤ 4 ^ n := bertrand_main_inequality n_big,
  have H2 : 4 ^ n < n * n.central_binom :=
    nat.four_pow_lt_mul_central_binom n (le_trans (by norm_num1) n_big),
  have H3 : n.central_binom ≤ (2 * n) ^ sqrt (2 * n) * 4 ^ (2 * n / 3) :=
    central_binom_le_of_no_bertrand_prime n (lt_of_lt_of_le (by norm_num1) n_big) no_prime,
  rw mul_assoc at H1, exact not_le.2 H2 ((mul_le_mul_left' H3 n).trans H1),
end

/--
Proves that Bertrand's postulate holds over all positive naturals less than n by identifying a
descending list of primes, each no more than twice the next, such that the list contains a witness
for each number ≤ n.
-/
lemma exists_prime_lt_and_le_two_mul_succ {n} (q)
  {p : ℕ} (prime_p : nat.prime p) (covering : p ≤ 2 * q)
  (H : n < q → ∃ (p : ℕ), p.prime ∧ n < p ∧ p ≤ 2 * n)
  (hn : n < p) : ∃ (p : ℕ), p.prime ∧ n < p ∧ p ≤ 2 * n :=
begin
  by_cases p ≤ 2 * n, { exact ⟨p, prime_p, hn, h⟩ },
  exact H (lt_of_mul_lt_mul_left' (lt_of_lt_of_le (not_le.1 h) covering))
end

/--
**Bertrand's Postulate**: For any positive natural number, there is a prime which is greater than
it, but no more than twice as large.
-/
theorem exists_prime_lt_and_le_two_mul (n : ℕ) (hn0 : n ≠ 0) :
  ∃ p, nat.prime p ∧ n < p ∧ p ≤ 2 * n :=
begin
  -- Split into cases whether `n` is large or small
  cases lt_or_le 511 n,
  -- If `n` is large, apply the lemma derived from the inequalities on the central binomial
  -- coefficient.
  { exact exists_prime_lt_and_le_two_mul_eventually n h, },
  replace h : n < 521 := h.trans_lt (by norm_num1),
  revert h,
  -- For small `n`, supply a list of primes to cover the initial cases.
  ([317, 163, 83, 43, 23, 13, 7, 5, 3, 2].mmap' $ λ n,
    `[refine exists_prime_lt_and_le_two_mul_succ %%(reflect n) (by norm_num1) (by norm_num1) _]),
  exact λ h2, ⟨2, prime_two, h2, nat.mul_le_mul_left 2 (nat.pos_of_ne_zero hn0)⟩,
end

alias nat.exists_prime_lt_and_le_two_mul ← bertrand

end nat

end nat
