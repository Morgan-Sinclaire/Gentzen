Require Import Omega.
Require Import Arith.
Require Import Lia.

Notation "b1 && b2" := (andb b1 b2).
Notation "b1 || b2" := (orb b1 b2).

(* Basic properties of natural numbers *)
(* *)
Notation beq_nat := Nat.eqb.

Theorem beq_nat_refl : forall (n : nat), true = beq_nat n n.
Proof.
intros n.
induction n as [| n IH].
- reflexivity.
- simpl. apply IH.
Qed.

Fixpoint bgeq_nat (n m : nat) : bool :=
  match (n, m) with
    (0, 0) => true
  | (S n', 0) => true
  | (0, S m') => false
  | (S n', S m') => bgeq_nat n' m'
  end.

Theorem succ_geq : forall (n : nat), bgeq_nat (S n) n = true.
Proof.
intros. induction n.
- simpl. reflexivity.
- rewrite <- IHn. auto.
Qed.

Definition lt_nat (n m : nat) : bool := (bgeq_nat m n) && negb (beq_nat n m).

Lemma lt_nat_irrefl : forall (n : nat), lt_nat n n = false.
Proof.
intros.
induction n.
- auto.
- rewrite <- IHn. auto.
Qed.

Theorem succ_beq : forall (n : nat), beq_nat n (S n) = false.
Proof.
intros. induction n.
- auto.
- rewrite <- IHn. auto.
Qed.


Definition nat_lt_aux' (n : nat) :=
  forall (m : nat), n < m -> lt_nat n m = true.

Lemma nat_lt_aux : forall (n : nat), nat_lt_aux' n.
Proof.
intros.
induction n.
- unfold nat_lt_aux'. intros. destruct m.
  + inversion H.
  + auto.
- unfold nat_lt_aux'. intros. destruct m.
  + inversion H.
  + unfold nat_lt_aux' in IHn.
    assert (n < m). { omega. }
    specialize IHn with m. apply IHn in H0.
    simpl. 
    inversion H. unfold lt_nat. rewrite (succ_geq (S n)). simpl.
    rewrite (succ_beq n). auto.
    unfold lt_nat. simpl.
    unfold lt_nat in H0. apply H0.
Qed.

Definition nat_eq_beq' (n : nat) :=
  forall (m : nat), beq_nat n m = true -> n = m.

Lemma nat_eq_beq : forall (n : nat), nat_eq_beq' n.
Proof.
intros.
induction n.
- unfold nat_eq_beq'. intros. destruct m.
  + auto.
  + inversion H.
- unfold nat_eq_beq'. intros. destruct m.
  + inversion H.
  + simpl in H. unfold nat_eq_beq' in IHn. specialize IHn with m.
    apply IHn in H. rewrite H. auto.
Qed.


Definition nat_trans (n : nat) := forall (m p : nat),
  lt_nat n m = true -> lt_nat m p = true -> lt_nat n p = true.

Lemma lt_nat_trans : forall (n : nat), nat_trans n.
Proof.
intros.
induction n.
- unfold nat_trans. intros. destruct p.
  + destruct m. 
    * inversion H.
    * inversion H0.
  + auto.
- unfold nat_trans. intros. destruct p.
  + destruct m.
    * inversion H.
    * inversion H0.
  + destruct m.
    * inversion H.
    * unfold nat_trans in IHn. specialize IHn with m p.
      assert (lt_nat n p = true).
      { apply IHn.
        { rewrite <- H. auto. }
        { rewrite <- H0. auto. } }
      rewrite <- H1. auto.
Qed.


Lemma lt_nat_asymm : forall (n m : nat),
  lt_nat n m = true -> ~(lt_nat m n = true).
Proof.
intros. unfold not. intros.
pose proof (lt_nat_trans n).
unfold nat_trans in H1.
specialize H1 with m n.
assert (lt_nat n n = true). { apply H1. apply H. apply H0. }
rewrite (lt_nat_irrefl n) in H2.
inversion H2.
Qed.

Lemma mult_right_incr_aux_aux : forall (n m p : nat),
  n < m -> n + p * (S n) < m + p * (S m).
Proof.
intros.
induction p.
- lia.
- lia.
Qed.

Theorem minus_n_0 : forall (n : nat), n - 0 = n.
Proof. intros. omega. Qed.

Theorem plus_n_0 : forall n:nat,
  n + 0 = n.
Proof.
intros n.
induction n as [| n' IH].
- reflexivity.
- simpl.
  rewrite IH.
  reflexivity.
Qed.

Theorem plus_n_1 : forall n:nat,
  n + 1 = S n.
Proof.
intros n.
induction n as [| n' IH].
- reflexivity.
- simpl.
  rewrite IH.
  reflexivity.
Qed.

Theorem plus_n_Sm : forall n m : nat,
  S (n + m) = n + (S m).
Proof.
intros m n.
induction m as [| m' IH].
- reflexivity.
- simpl.
  rewrite IH.
  reflexivity.
Qed.

Theorem plus_comm : forall n m : nat,
  n + m = m + n.
Proof.
intros m n.
induction m as [| m' IH].
- simpl.
  rewrite <- plus_n_O.
  reflexivity.
- induction n as [| n' IHn].
  + simpl.
    rewrite <- plus_n_O.
    reflexivity.
  + simpl.
    rewrite IH.
    simpl.
    rewrite plus_n_Sm.
    reflexivity.
Qed.

Theorem plus_assoc : forall n m p : nat,
  n + (m + p) = (n + m) + p.
Proof.
intros n m p.
induction n as [| n IHn].
- simpl.
  reflexivity.
- simpl.
  rewrite IHn.
  reflexivity.
Qed.

Theorem mult_0_r : forall n:nat,
  n * 0 = 0.
Proof.
intros n.
induction n as [| n' IH].
- reflexivity.
- simpl.
  rewrite IH.
  reflexivity.
Qed.

Lemma mult_1_r : forall (n : nat), n * 1 = n.
Proof.
intros n.
induction n as [| n' IH].
- reflexivity.
- simpl. rewrite IH. reflexivity.
Qed.

(* Definition of PA formulas *)
(* *)
Inductive term : Type :=
    zero : term
  | succ : term -> term
  | plus : term -> term -> term
  | times : term -> term -> term
  | f_var : nat -> term
  | b_var : nat -> term.

Inductive atomic_formula : Type :=
    equ : term -> term -> atomic_formula.

Inductive formula : Type :=
    atom : atomic_formula -> formula
  | neg : formula -> formula
  | lor : formula -> formula -> formula
  | univ : nat -> formula -> formula.


(* Count number of connectives and quantifiers appearing in a formula *)
(* *)
Fixpoint num_conn (a : formula) : nat :=
  match a with
  | atom a' => 0
  | neg a' => 1 + (num_conn a')
  | lor a1 a2 => 1 + (num_conn a1) + (num_conn a2)
  | univ n a' => 1 + (num_conn a')
  end.

(* Check syntactic equality of formulas *)
(* *)
Fixpoint eq_term (s t : term) : bool :=
  match (s, t) with
  | (zero, zero) => true
  | (succ s', succ t') => eq_term s' t'
  | (plus s1 s2, plus t1 t2) => (eq_term s1 t1) && (eq_term s2 t2)
  | (times s1 s2, times t1 t2) => (eq_term s1 t1) && (eq_term s2 t2)
  | (f_var m, f_var n) => beq_nat m n
  | (b_var m, b_var n) => beq_nat m n
  | (_,_) => false
end.

Compute eq_term zero zero.
Compute eq_term (succ zero) (succ zero).

Fixpoint eq_atom (a b : atomic_formula) : bool :=
  match (a, b) with
    (equ s1 s2, equ t1 t2) => (eq_term s1 t1) && (eq_term s2 t2)
  end.

Compute eq_atom (equ zero (succ zero)) (equ zero (succ zero)).

Fixpoint eq_f (a b : formula) : bool :=
  match (a, b) with
  | (atom a', atom b') => eq_atom a' b'
  | (neg a', neg b') => eq_f a' b'
  | (lor a1 a2, lor b1 b2) => (eq_f a1 b1) && (eq_f a2 b2)
  | (univ m a', univ n b') => (beq_nat m n) && (eq_f a' b')
  | (_, _) => false
  end.

Compute eq_f (atom (equ zero (succ zero))) (atom (equ zero (succ zero))).

Theorem eq_term_refl : forall (t : term), true = eq_term t t.
Proof.
intros t.
induction t.
- reflexivity.
- simpl. apply IHt.
- simpl. rewrite <- IHt1. apply IHt2.
- simpl. rewrite <- IHt1. apply IHt2.
- simpl. apply beq_nat_refl.
- simpl. apply beq_nat_refl.
Qed.

Theorem eq_atom_refl : forall (a : atomic_formula), true = eq_atom a a.
Proof.
intros a.
destruct a as [t1 t2].
unfold eq_atom.
rewrite <- eq_term_refl.
apply eq_term_refl.
Qed.

Theorem eq_f_refl : forall (a : formula), true = eq_f a a.
Proof.
intros a.
induction a as [a | a IH | a1 IH1 a2 IH2 | n a IH].
- unfold eq_f. apply eq_atom_refl.
- simpl. apply IH.
- simpl. rewrite <- IH1. apply IH2.
- simpl. rewrite <- beq_nat_refl. apply IH.
Qed.


(* Given some term t, returns t+1 if the formula is closed, 0 otherwise *)
(* *)
Fixpoint eval (t : term) : nat :=
  match t with
    zero => S O
  | succ t_1 =>
      (match (eval t_1) with
        O => O
      | S n => S (S n)
      end)
  | plus t_1 t_2 =>
      (match (eval t_1, eval t_2) with
        (O, O) => O
      | (S n, O) => O
      | (O, S m) => O
      | (S n, S m) => S (n + m)
      end)
  | times t_1 t_2 =>
      (match (eval t_1, eval t_2) with
        (O, O) => O
      | (S n, O) => O
      | (O, S m) => O
      | (S n, S m) => S (n * m)
      end)
  | f_var n => O
  | b_var n => O
  end.

Compute eval zero.
Compute eval (f_var O).
Compute eval (succ zero).
Compute eval (succ (f_var O)).
Compute eval (plus (succ zero) (f_var O)).

Inductive ternary : Type :=
    correct : ternary
  | incorrect : ternary
  | undefined : ternary.

Fixpoint represent (n : nat) : term :=
  match n with
    O => zero
  | S n' => succ (represent n')
  end.

Compute represent 0.
Compute represent 1.
Compute represent 2.
Compute represent 5.


(* Given some atomic formula a, returns whether the statement is correct,
incorrect, or undefined (i.e. not closed) *)
Definition correctness (a : atomic_formula) : ternary :=
  match a with
    equ t_1 t_2 =>
      (match (eval t_1, eval t_2) with
        (O, O) => undefined
      | (S n, O) => undefined
      | (O, S m) => undefined
      | (S n, S m) =>
          (match (beq_nat (eval t_1) (eval t_2)) with
            true => correct
          | false => incorrect
          end)
      end)
  end.

Compute correctness (equ zero zero).
Compute correctness (equ zero (succ zero)).
Compute correctness (equ (plus (succ zero) (succ zero)) (succ (succ zero))).
Compute correctness (equ zero (f_var O)).


Definition correct_a (a : atomic_formula) : bool :=
match (correctness a) with
| correct => true
| _ => false
end.

Definition incorrect_a (a : atomic_formula) : bool :=
match (correctness a) with
| incorrect => true
| _ => false
end.



(* Basic properties of lists and lists of nats *)
(* *)

Inductive list (X:Type) : Type :=
  | nil : list X
  | constr : X -> list X -> list X.

Arguments nil {X}.
Arguments constr {X} _ _.
Notation "x :: l" := (constr x l)
                     (at level 60, right associativity).
Notation "[ ]" := nil.
Notation "[ x , .. , y ]" := (constr x .. (constr y nil) ..).

Fixpoint length {X : Type} (l : list X) : nat :=
  match l with
    nil => O
  | n :: l' => S (length l')
  end.

Fixpoint concat {X : Type} (l_1 l_2 : list X) : list X :=
  match l_1 with
    nil => l_2
  | n :: l_1' => n :: (concat l_1' l_2)
  end.

Fixpoint beq_list {X : Type} (l1 l2 : list X) : bool :=
  match l1,l2 with
    [],[] => true
  | m :: l1',[] => false
  | [], n :: l2' => false
  | m :: l1', n :: l2' => beq_list l1' l2'
  end.

Fixpoint remove (n : nat) (l : list nat) : list nat :=
  match l with
    nil => nil
  | m :: l' => (match (beq_nat n m) with
                  true => remove n l'
                | false => m :: (remove n l')
                end)
  end.

Fixpoint member (n : nat) (l : list nat) : bool :=
  match l with
    nil => false
  | m :: l' => (match (beq_nat n m) with
                  true => true
                | false => member n l'
                end)
  end.

Fixpoint remove_dups (l : list nat) : list nat :=
  match l with
    [] => []
  | n :: l' => n :: (remove n (remove_dups l'))
  end.




(* Free variable lists *)
(* *)
Fixpoint free_list_t (t : term) : list nat :=
  match t with
    zero => nil
  | succ t_1 => free_list_t t_1
  | plus t_1 t_2 => concat (free_list_t t_1) (free_list_t t_2)
  | times t_1 t_2 => concat (free_list_t t_1) (free_list_t t_2)
  | f_var n => nil
  | b_var n => [n]
  end.

Definition free_list_a (a : atomic_formula) : list nat :=
  match a with
    equ t_1 t_2 => concat (free_list_t t_1) (free_list_t t_2)
  end.

Fixpoint free_list (f : formula) : list nat :=
  match f with
    atom a => free_list_a a
  | neg f_1 => free_list f_1
  | lor f_1 f_2 => concat (free_list f_1) (free_list f_2)
  | univ n f_1 => remove n (free_list f_1)
  end.

Compute remove 1 [1,2,3].
Compute free_list_a (equ(b_var 1)(b_var 2)).

Definition closed_t (t : term) : bool :=
  match (free_list_t t) with
  | nil => true
  | n :: l => false
  end.

Definition closed_a (a : atomic_formula) : bool :=
  match (free_list_a a) with
  | nil => true
  | n :: l => false
  end.

Definition closed (f : formula) : bool :=
  match (free_list f) with
  | nil => true
  | n :: l => false
  end.

Inductive sentence : Type :=
  sent : forall (f : formula), formula -> (free_list f = []) -> sentence.

Check sentence.
Check sent.

Fixpoint closed_term_list_t (t : term) : list term :=
  match (t, closed_t t)  with
  | (zero, _) => [t]
  | (succ t', true) => t :: closed_term_list_t t'
  | (succ t', false) => closed_term_list_t t'
  | (plus t1 t2, true) => t :: (concat (closed_term_list_t t1)
                                      (closed_term_list_t t2))
  | (plus t1 t2, false) => (concat (closed_term_list_t t1)
                                  (closed_term_list_t t2))
  | (times t1 t2, true) => t :: (concat (closed_term_list_t t1)
                                      (closed_term_list_t t2))
  | (times t1 t2, false) => (concat (closed_term_list_t t1)
                                  (closed_term_list_t t2))
  | (_, _) => nil
  end.

Compute closed_term_list_t (plus (b_var 3) zero).
Compute closed_term_list_t (succ (succ zero)).
Compute closed_term_list_t (plus (times zero (succ (succ zero))) zero).

Definition closed_term_list_a (a : atomic_formula) : list term :=
  match a with
  | equ t1 t2 => concat (closed_term_list_t t1) (closed_term_list_t t2)
  end.

Fixpoint closed_term_list (a : formula) : list term :=
  match a with
  | atom a' => closed_term_list_a a'
  | neg a' => closed_term_list a'
  | lor a1 a2 => concat (closed_term_list a1) (closed_term_list a2)
  | univ n a' => closed_term_list a'
  end.




(* Defining substitution of a term t for all free occurrences of a
   variable x_n in a formula f *)
(* *)
Fixpoint substitution_t (f : term) (n : nat) (t : term) : term :=
  match f with
    zero => f
  | succ f_1 => succ (substitution_t f_1 n t)
  | plus f_1 f_2 => plus (substitution_t f_1 n t) (substitution_t f_2 n t)
  | times f_1 f_2 => times (substitution_t f_1 n t) (substitution_t f_2 n t)
  | f_var m =>
      (match (beq_nat m n) with
        true => t
      | false => f
      end)
  | b_var m =>
      (match (beq_nat m n) with
        true => t
      | false => f
      end)
  end.

Definition substitution_a (f : atomic_formula) (n : nat) (t : term)
  : atomic_formula :=
  match f with
    equ t_1 t_2 => equ (substitution_t t_1 n t) (substitution_t t_2 n t)
  end.

Fixpoint substitution (f : formula) (n : nat) (t : term) : formula :=
  match f with
    atom a => atom (substitution_a a n t)
  | neg f_1 => neg (substitution f_1 n t)
  | lor f_1 f_2 => lor (substitution f_1 n t) (substitution f_2 n t)
  | univ m f_1 => 
      (match (beq_nat m n) with
        true => f
      | false => univ m (substitution f_1 n t)
      end)
  end.

(* Given a list of closed terms and a variable x_n in formula a, check if any
of those terms can be substituted for x_n to obtain the formula b *)
Fixpoint transformable_with_list (a b : formula) (n : nat) (l : list term)
          : bool :=
  match l with
  | nil => false
  | t :: l' => if (eq_f (substitution a n t) b)
              then true
              else transformable_with_list a b n l'
  end.

(* Determine if some formula a can be transformed into formula b by an
appropriate substitution of some closed term for all instances of x_n in a *)
Definition transformable (a b : formula) (n : nat) : bool :=
  transformable_with_list a b n (closed_term_list b).

Compute transformable (atom (equ zero (f_var 9)))
                      (atom (equ zero (succ zero))) 9.
Compute transformable (atom (equ zero (f_var 9)))
                      (atom (equ (succ zero) (succ zero))) 9.

(* Define inductively what it means for a term t to be free for a variable x_n
in a formula f; namely, that no free occurrence of x_n in f is in the scope of
some (univ m), where x_m is a variable in t. *)
(* *)
Fixpoint free_for (t : term) (n : nat) (f : formula) : bool :=
  match f with
    atom a => true
  | neg f_1 => free_for t n f_1
  | lor f_1 f_2 => (free_for t n f_1) && (free_for t n f_2)
  | univ m f_1 =>
      if member m (free_list_t t)
      then negb (member n (free_list f_1))
      else free_for t n f_1
  end.

Compute free_for zero 0 (univ 1 (atom (equ (b_var 0) (b_var 0)))).
Compute free_for (b_var 1) 0 (univ 1 (atom (equ (b_var 0) (b_var 0)))).


(* Logical axioms of FOL *)
(* *)
Definition implies (a b : formula) : formula :=
  lor (neg a) b.

Definition land (a b : formula) : formula :=
  neg (lor (neg a) (neg b)).

Definition exis (n : nat) (f : formula) :=
  neg (univ n (neg f)).


Definition logical_axiom_1 (a b : formula) : formula :=
  implies a (implies b a).

Definition logical_axiom_2 (a b c : formula) : formula :=
  implies (implies a (implies b c)) (implies (implies a b) (implies b c)).

Definition logical_axiom_3 (a b : formula) : formula :=
  implies (implies (neg b) (neg a)) (implies (implies (neg b) a) b).

Definition logical_axiom_4 (a : formula) (n : nat) (t : term) : formula :=
  if free_for t n a
  then implies (univ n a) (substitution a n t)
  else atom (equ zero zero).

Compute logical_axiom_4 (atom (equ (b_var 0) (b_var 0))) 0 zero.
Compute logical_axiom_4 (atom (equ zero zero)) 0 zero.
Compute logical_axiom_4 (atom (equ (b_var 1) (b_var 1))) 0 zero.
Compute logical_axiom_4 (atom (equ (b_var 0) (b_var 0))) 0 zero.
Compute logical_axiom_4 (exis 1 (atom (equ (b_var 1) (plus (b_var 0) (succ zero)))))
                        1 (succ (b_var 1)).


Definition logical_axiom_5 (a b : formula) (n : nat) : formula :=
  if negb (member n (free_list a))
  then implies (univ n (implies a b)) (implies a (univ n b))
  else atom (equ zero zero).

Compute logical_axiom_5 (atom (equ zero zero)) (atom (equ zero zero)) 0.
Compute logical_axiom_5 (atom (equ (b_var 1) zero)) (atom (equ zero zero)) 1.

Definition logical_axiom_6 (a : formula) (x y : nat) : formula :=
  if (member y (free_list a)) && (negb (member x (free_list a)))
  then implies a (univ x (substitution a y (b_var x)))
  else atom (equ zero zero).

Compute logical_axiom_6 (atom (equ (b_var 1) (b_var 1))) 0 1.
Compute logical_axiom_6 (univ 1 (atom (equ (b_var 1) (b_var 1)))) 0 1.
Compute logical_axiom_6 (atom (equ (b_var 1) (b_var 0))) 0 1.
Compute logical_axiom_6 (atom (equ (b_var 0) zero)) 0 1.
Compute logical_axiom_6 (atom (equ (b_var 1) zero)) 0 1.



(* Axioms of Peano Arithmetic (PA) *)
(* *)
Definition peano_axiom_1 (x y z : nat) : formula :=
  univ x (univ y (univ z (
    implies (land (atom (equ (b_var x) (b_var y)))
                  (atom (equ (b_var y) (b_var z))))
            (atom (equ (b_var x) (b_var z)))))).

Definition peano_axiom_2 (x y : nat) : formula :=
  univ x (univ y (
    implies (atom (equ (b_var x) (b_var y)))
            (atom (equ (succ (b_var x)) (succ (b_var y)))))).

Definition peano_axiom_3 (x : nat) : formula :=
  univ x (neg (atom (equ (succ (b_var x)) zero))).

Definition peano_axiom_4 (x y : nat) : formula :=
  univ x (univ y (
    implies (atom (equ (succ (b_var x)) (succ (b_var y))))
            (atom (equ (b_var x) (b_var y))))).

Definition peano_axiom_5 (x : nat) : formula :=
  univ x (atom (equ (plus (b_var x) zero) (b_var x))).

Definition peano_axiom_6 (x y : nat) : formula :=
  univ x (univ y (
    atom (equ (plus (b_var x) (succ (b_var y)))
                    (succ (plus (b_var x) (b_var y)))))).

Definition peano_axiom_7 (x : nat) : formula :=
  univ x (atom (equ (times (b_var x) zero) zero)).

Definition peano_axiom_8 (x y : nat) : formula :=
  univ x (univ y (
    atom (equ (times (b_var x) (succ (b_var y)))
              (plus (times (b_var x) (b_var y)) (b_var x))))).

Definition peano_axiom_9 (f : formula) (x : nat) : formula :=
  if member x (free_list f)
  then implies (land (substitution f x zero)
                     (univ x (implies f (substitution f x (succ (b_var x))))))
               (univ x f)
  else atom (equ zero zero).






Theorem nat_semiconnex : forall (m n : nat), m < n \/ n < m \/ m = n.
Proof.
intros. omega.
Qed.

Lemma nat_transitive : forall (n n' n'' : nat), n < n' -> n' < n'' -> n < n''.
Proof.
intros. omega.
Qed.

(* Defining ordinals *)
(* *)

(** cons a n b represents  omega^a *(S n)  + b *)

Inductive ord : Set :=
  Zero : ord
| cons : ord -> nat -> ord -> ord.

(* A total strict order on ord *)

Inductive ord_lt : ord -> ord -> Prop :=
|  zero_lt : forall a n b, Zero < cons a n b
|  head_lt :
    forall a a' n n' b b', a < a' ->
                           cons a n b < cons a' n' b'
|  coeff_lt : forall a n n' b b', (n < n')%nat ->
                                 cons a n b < cons a n' b'
|  tail_lt : forall a n b b', b < b' ->
                             cons a n b < cons a n b'
where "o < o'" := (ord_lt o o') : cantor_scope.

Open Scope cantor_scope.

Definition leq (alpha beta : ord) := alpha = beta \/ alpha < beta.
Notation "alpha <= beta" := (leq alpha beta) : cantor_scope.

Definition semiconnex (alpha : ord) :=
  forall (beta : ord), alpha < beta \/ beta < alpha \/ alpha = beta.


Theorem ordinal_semiconnex : forall (alpha : ord), semiconnex alpha.
Proof.
intros alpha.
induction alpha.
- unfold semiconnex.
  induction beta.
  + right. right. reflexivity.
  + left. apply zero_lt.
- unfold semiconnex.
  unfold semiconnex in IHalpha1.
  unfold semiconnex in IHalpha2.
  induction beta.
  + right. left. apply zero_lt.
  + destruct (IHalpha1 beta1).
    * left. apply head_lt. apply H.
    * destruct H.
      { right. left. apply head_lt. apply H. }
      { destruct (nat_semiconnex n n0).
        { left. rewrite H. apply coeff_lt. apply H0. }
        { destruct H0.
          { right. left. rewrite H. apply coeff_lt. apply H0. }
          { destruct (IHalpha2 beta2).
            { left. rewrite H. rewrite H0. apply tail_lt. apply H1. }
            { destruct H1.
              { right. left. rewrite H. rewrite H0. apply tail_lt. apply H1. }
              { right. right. rewrite H. rewrite H0. rewrite H1. auto. }}}}}
Qed.

Lemma ord_semiconnex : forall (alpha beta : ord),
  alpha < beta \/ beta < alpha \/ alpha = beta.
Proof.
intros.
pose proof (ordinal_semiconnex alpha).
unfold semiconnex in H.
specialize H with beta.
apply H.
Qed.


Definition transitive (alpha : ord) := forall (beta gamma : ord),
  (beta < gamma -> alpha < beta -> alpha < gamma).


Lemma cons_lt_aux : forall (a a' b b' : ord) (n n' : nat),
  cons a n b < cons a' n' b' ->
  (a < a' \/ (a = a' /\ lt n n') \/ (a = a' /\ n = n' /\ b < b')).
Proof.
intros.
inversion H.
- left. apply H1.
- right. left. split.
  + auto.
  + apply H1.
- right. right. split.
  + auto.
  + split.
    * auto.
    * apply H1.
Qed.


Theorem ordinal_transitivity : forall (alpha : ord), transitive alpha.
Proof.
intros.
induction alpha as [| a IHa n b IHb].
- unfold transitive.
  intros.
  destruct gamma as [| a'' n'' b''].
  + inversion H.
  + apply zero_lt.
- unfold transitive.
  intros.
  destruct beta as [| a' n' b'].
  + inversion H0.
  + destruct gamma as [| a'' n'' b''].
    * inversion H.
    * apply cons_lt_aux in H0. apply cons_lt_aux in H.
      { destruct H0. 
        { destruct H.
          { unfold transitive in IHa. specialize IHa with a' a''.
          apply head_lt. apply IHa. apply H. apply H0. }
        { destruct H.
          { unfold transitive in IHa. specialize IHa with a' a''.
            apply head_lt. destruct H. rewrite H in H0. apply H0. }
          { apply head_lt. unfold transitive in IHa. specialize IHa with a' a''.
            destruct H. rewrite <- H. apply H0. } } }
        destruct H0.
        { destruct H0. rewrite H0. destruct H.
          { apply head_lt. apply H. }
          { destruct H.
            { destruct H. rewrite <- H. apply coeff_lt.
              pose proof (nat_transitive n n' n''). apply H3. apply H1. apply H2. }
            { destruct H. destruct H2. rewrite H. rewrite <- H2.
              apply coeff_lt. apply H1. } } }
            destruct H. destruct H0. rewrite H0. apply head_lt. apply H.
            destruct H. destruct H. destruct H0. destruct H2.
            rewrite H0. rewrite H. rewrite H2. apply coeff_lt. apply H1.

            destruct H. destruct H. destruct H0. destruct H0.
            rewrite H. rewrite H0. destruct H1. rewrite H1.
            apply tail_lt. unfold transitive in IHb. specialize IHb with b' b''.
            apply IHb. apply H3. apply H2. }
Qed.


Theorem ord_transitive : forall (alpha beta gamma : ord),
  alpha < beta -> beta < gamma -> alpha < gamma.
Proof.
intros.
pose proof (ordinal_transitivity alpha).
unfold transitive in H1.
specialize H1 with beta gamma.
apply H1.
apply H0.
apply H.
Qed.











(* The predicate "to be in normal form" *)

(* The real Cantor normal form needs the exponents of omega to be
   in strict decreasing order *)


Inductive nf : ord -> Prop :=
| zero_nf : nf Zero
| single_nf : forall a n, nf a ->  nf (cons a n Zero)
| cons_nf : forall a n a' n' b, a' < a ->
                             nf a ->
                             nf (cons a' n' b)->
                             nf (cons a n (cons a' n' b)).
Hint Resolve zero_nf single_nf cons_nf : ord.

Definition e0 : Type := {a : ord | nf a}.

Check cons Zero O (cons Zero O Zero).

Theorem Zero_nf : nf Zero.
Proof. apply zero_nf. Qed.

Check exist nf Zero Zero_nf.
Check exist.
Check exist nf.

Definition lt_e0 (alpha beta : e0) : Prop :=
  match (alpha, beta) with
  | (exist _ alpha' _, exist _ beta' _) => alpha' < beta'
  end.

Definition leq_e0 (alpha beta : e0) : Prop := lt_e0 alpha beta \/ alpha = beta.
Definition gt_e0 (alpha beta : e0) : Prop := lt_e0 beta alpha.
Definition geq_e0 (alpha beta : e0) : Prop := leq_e0 beta alpha.

Definition nat_ord (n : nat) : ord :=
  match n with
  | O => Zero
  | S n' => cons Zero n' Zero
  end.


(* defining boolean equality and less than, assuming normal form. *)
(* *)
Fixpoint ord_eqb (alpha : ord) (beta : ord) : bool :=
match (alpha, beta) with
| (Zero, Zero) => true
| (_, Zero) => false
| (Zero, _) => false
| (cons a n b, cons a' n' b') =>
    (match (ord_eqb a a') with
    | false => false
    | true =>
        (match (beq_nat n n') with
        | false => false
        | true => ord_eqb b b'
        end)
    end)
end.




Fixpoint ord_ltb (alpha : ord) (beta : ord) : bool :=
match alpha, beta with
| Zero, Zero => false
| _, Zero => false
| Zero, _ => true
| cons a n b, cons a' n' b' =>
    (match (ord_ltb a a', ord_eqb a a') with
    | (true, _) => true
    | (_, false) => false
    | (_, true) =>
        (match (lt_nat n n', lt_nat n' n) with
        | (true, _) => true
        | (_, true) => false
        | (_, _) => ord_ltb b b'
        end)
    end)
end.

Lemma ord_eqb_refl : forall (alpha : ord), ord_eqb alpha alpha = true.
Proof.
intros.
induction alpha.
- auto.
- simpl. rewrite IHalpha1. rewrite <- beq_nat_refl. rewrite IHalpha2. auto.
Qed.

Definition ord_semiconnex_bool_aux' (alpha : ord) :=
  forall (beta : ord), alpha < beta -> ord_ltb alpha beta = true.

Lemma ord_semiconnex_bool_aux :
  forall (alpha : ord), ord_semiconnex_bool_aux' alpha.
Proof.
intros.
induction alpha.
- unfold ord_semiconnex_bool_aux'.
  intros.
  destruct beta.
  + inversion H.
  + simpl. auto.
- unfold ord_semiconnex_bool_aux'.
  intros.
  destruct beta.
  + inversion H.
  + inversion H.
    * unfold ord_semiconnex_bool_aux' in IHalpha1. simpl.
      specialize IHalpha1 with beta1.
      apply IHalpha1 in H1.
      rewrite H1. auto.
    * simpl. case (ord_ltb beta1 beta1). auto. simpl.
      assert (ord_eqb beta1 beta1 = true). { apply (ord_eqb_refl beta1). }
      rewrite H7.
      assert (lt_nat n n0 = true). { apply (nat_lt_aux n). apply H1. }
      rewrite H8. auto.
    * unfold ord_semiconnex_bool_aux' in IHalpha2. simpl.
      specialize IHalpha2 with beta2.
      case (ord_ltb beta1 beta1). auto.
      assert (ord_eqb beta1 beta1 = true). { apply (ord_eqb_refl beta1). }
      rewrite H7.
      case (lt_nat n0 n0). auto.
      apply IHalpha2. apply H1.
Qed.

Lemma ord_lt_ltb : forall (alpha beta : ord),
  alpha < beta -> ord_ltb alpha beta = true.
Proof.
intros.
apply ord_semiconnex_bool_aux.
apply H.
Qed.

Lemma ltb_trans_aux : forall (a a' b b' : ord) (n n' : nat),
  ord_ltb (cons a n b) (cons a' n' b') = true ->
  (ord_ltb a a' = true \/ (ord_eqb a a' = true /\ lt_nat n n' = true) \/
  (ord_eqb a a' = true /\ n = n' /\ ord_ltb b b' = true)).
Proof.
intros.
inversion H.
case_eq (ord_ltb a a').
- auto.
- intros. rewrite H0 in H1. case_eq (ord_eqb a a').
  + intros. right. rewrite H2 in H1. case_eq (lt_nat n n').
    * intros. rewrite H3 in H1. auto.
    * intros. rewrite H3 in H1. case_eq (lt_nat n' n).
      { intros. rewrite H4 in H1. inversion H1. }
      { intros. rewrite H4 in H1. right. split. rewrite H1. auto. split.
        { pose proof (nat_semiconnex n n'). destruct H5.
          { pose proof (nat_lt_aux n). unfold nat_lt_aux' in H6.
            specialize H6 with n'. apply H6 in H5. rewrite H5 in H3.
            inversion H3. }
          { destruct H5.
            { pose proof (nat_lt_aux n'). unfold nat_lt_aux' in H6.
              specialize H6 with n. apply H6 in H5. rewrite H5 in H4.
              inversion H4. }
            { apply H5. } } }
        { auto. } }
  + intros. left. auto.
Qed.

Definition ord_eq_eqb' (alpha : ord) := forall (beta : ord),
  ord_eqb alpha beta = true -> alpha = beta.

Lemma ord_eq_eqb : forall (alpha : ord), ord_eq_eqb' alpha.
Proof.
intros.
induction alpha.
- unfold ord_eq_eqb'. intros. destruct beta.
  + auto.
  + inversion H.
- unfold ord_eq_eqb'. intros. destruct beta.
  + inversion H.
  + inversion H.
    * case_eq (ord_eqb alpha1 beta1).
      { intros. unfold ord_eq_eqb' in IHalpha1. specialize IHalpha1 with beta1.
        assert (alpha1 = beta1). { apply IHalpha1. apply H0. } rewrite H2.
        case_eq (beq_nat n n0).
        { intros. assert (n = n0). { apply (nat_eq_beq n n0 H3). } rewrite H4.
          case_eq (ord_eqb alpha2 beta2).
          { intros. assert (alpha2 = beta2). { apply IHalpha2. apply H5. }
            rewrite H6. auto. }
          { intros. rewrite H0 in H1. rewrite H3 in H1. rewrite H5 in H1.
            inversion H1. } }
        { intros. rewrite H0 in H1. rewrite H3 in H1. inversion H1. } }
      { intros. rewrite H0 in H1. inversion H1. }
Qed.


Definition ltb_trans (alpha : ord) := forall (beta gamma : ord),
  ord_ltb beta gamma = true -> ord_ltb alpha beta = true ->
  ord_ltb alpha gamma = true.



Lemma ord_ltb_trans : forall (alpha : ord), ltb_trans alpha.
Proof.
intros.
induction alpha as [| a IHa n b IHb].
- unfold ltb_trans.
  intros.
  destruct gamma as [| a'' n'' b''].
  + destruct beta as [| a' n' b'].
    * inversion H.
    * inversion H.
  + auto.
- unfold ltb_trans.
  intros.
  destruct beta as [| a' n' b'].
  + inversion H0.
  + destruct gamma as [| a'' n'' b''].
    * inversion H.
    * destruct (ltb_trans_aux a a' b b' n n' H0).
      { destruct (ltb_trans_aux a' a'' b' b'' n' n'' H).
        { unfold ltb_trans in IHa. specialize IHa with a' a''.
          assert (ord_ltb a a'' = true). { apply IHa. apply H2. apply H1. }
          simpl. rewrite H3. auto. }
        { destruct H2. destruct H2. assert (a' = a'').
          { apply (ord_eq_eqb a' a''). apply H2. }
          { simpl. rewrite <- H4. rewrite H1. auto. }
          { destruct H2. destruct H3. assert (a' = a'').
            { apply (ord_eq_eqb a' a''). apply H2. }
            simpl. rewrite <- H5. rewrite H1. auto. } } }
      { destruct H1. destruct H1.
        assert (a = a'). { apply (ord_eq_eqb a a'). apply H1. }
        { destruct (ltb_trans_aux a' a'' b' b'' n' n'' H).
          { rewrite H3. simpl. rewrite H4. auto. }
          { destruct H4. destruct H4.
            { assert (a' = a''). { apply (ord_eq_eqb a' a''). apply H4. }
              simpl. case (ord_ltb a a''). auto.
              rewrite H3. rewrite H6. rewrite (ord_eqb_refl a'').
              assert (lt_nat n n'' = true).
              { apply (lt_nat_trans n n' n'' H2 H5). }
              rewrite H7. auto. }
            { destruct H4. destruct H5. simpl. case (ord_ltb a a''). auto.
              assert (a' = a''). { apply (ord_eq_eqb a' a''). apply H4. }
              rewrite H3. rewrite H7. rewrite (ord_eqb_refl a'').
              rewrite <- H5. rewrite H2. auto. } } }
      { destruct H1. destruct H2.
        destruct (ltb_trans_aux a' a'' b' b'' n' n'' H).
        assert (a = a'). { apply (ord_eq_eqb a a'). apply H1. }
        { simpl. rewrite H5. rewrite H4. auto. }
        { destruct H4. destruct H4.
          assert (a = a'). { apply (ord_eq_eqb a a'). apply H1. }
          assert (a' = a''). { apply (ord_eq_eqb a' a''). apply H4. }
          { simpl. case (ord_ltb a a''). auto. rewrite H6. rewrite H7.
            rewrite (ord_eqb_refl a''). rewrite H2. rewrite H5. auto. }
          { destruct H4. destruct H5. simpl. case (ord_ltb a a''). auto.
            assert (a = a'). { apply (ord_eq_eqb a a'). apply H1. }
            assert (a' = a''). { apply (ord_eq_eqb a' a''). apply H4. }
            rewrite H7. rewrite H8. rewrite (ord_eqb_refl a'').
            case (lt_nat n n''). auto. rewrite H2. rewrite H5.
            rewrite (lt_nat_irrefl n''). unfold ltb_trans in IHb.
            specialize IHb with b' b''. apply IHb. apply H6. apply H3. } } } }
Qed.




Lemma ord_ltb_irrefl : forall (alpha : ord), ord_ltb alpha alpha = false.
Proof.
intros.
induction alpha.
- auto.
- simpl.
  rewrite IHalpha1.
  rewrite (ord_eqb_refl alpha1).
  rewrite (lt_nat_irrefl n).
  rewrite IHalpha2.
  auto.
Qed.


Lemma ltb_asymm : forall (alpha beta : ord),
  ord_ltb alpha beta = true -> ~(ord_ltb beta alpha = true).
Proof.
intros. unfold not. intros.
pose proof (ord_ltb_trans alpha).
unfold ltb_trans in H1.
specialize H1 with beta alpha.
assert (ord_ltb alpha alpha = true). { apply H1. apply H0. apply H. }
rewrite (ord_ltb_irrefl alpha) in H2.
inversion H2.
Qed.


Lemma ord_ltb_lt : forall (alpha beta : ord),
  ord_ltb alpha beta = true -> alpha < beta.
Proof.
intros.
pose proof (ordinal_semiconnex alpha).
unfold semiconnex in H0.
specialize H0 with beta.
destruct H0.
- apply H0.
- destruct H0.
  + apply ord_lt_ltb in H0. apply (ltb_asymm alpha beta) in H. contradiction.
  + rewrite H0 in H. rewrite (ord_ltb_irrefl beta) in H. inversion H.
Qed.


Lemma ord_semiconnex_bool : forall (alpha beta : ord),
  ord_ltb alpha beta = true \/ ord_ltb beta alpha = true \/
  ord_eqb alpha beta = true.
Proof.
intros.
pose proof (ordinal_semiconnex alpha).
unfold semiconnex in H.
specialize H with beta.
inversion H.
- left. apply ord_lt_ltb. apply H0.
- inversion H0.
  + right. left. apply ord_semiconnex_bool_aux. apply H1.
  + right. right. rewrite H1. apply ord_eqb_refl.
Qed.




(* ord_succ, ord_add, and ord_mult will all assume normal form *)
(* *)
Fixpoint ord_succ (alpha : ord) : ord :=
  match alpha with
  | Zero => nat_ord 1
  | cons Zero n b => cons Zero (S n) b
  | cons a n b => cons a n (ord_succ b)
  end.

Fixpoint ord_add (alpha : ord) (beta : ord) : ord :=
match alpha, beta with
| _, Zero => alpha
| Zero, _ => beta
| cons a n b, cons a' n' b' =>
    (match (ord_ltb a a') with
    | true => beta
    | false =>
      (match (ord_eqb a a') with
      | true => cons a' (n + n' + 1) b'
      | false => cons a n (ord_add b beta)
      end)
    end)
end.

(*
Fixpoint ord_mult_by_n (alpha : ord) (m : nat) : ord :=
match alpha with
| Zero => Zero
| cons Zero n b => nat_ord ((n + 1) * m)
| cons a n b => 
    (match m with
    | 0 => Zero
    | S m' => cons a ((n + 1) * (S m') - 1) b
    end)
end.
*)

Fixpoint ord_mult (alpha : ord) (beta : ord) : ord :=
match alpha, beta with
| _, Zero => Zero
| Zero, _ => Zero
| cons a n b, cons Zero n' b' => cons a ((S n) * (S n') - 1) (ord_mult alpha b')
| cons a n b, cons a' n' b' => cons (ord_add a a') n' (ord_mult alpha b')
end.

(* Here we show that addition and multiplication for ordinal numbers
agrees with the usual definitions for natural numbers *)
(* *)
Lemma ord_add_zero : forall (alpha : ord), ord_add alpha Zero = alpha.
Proof.
intros alpha.
destruct alpha.
- simpl. reflexivity.
- simpl. reflexivity.
Qed.

Lemma ord_add_nat : forall (n m : nat),
  nat_ord (n + m) = ord_add (nat_ord n) (nat_ord m).
Proof.
intros n m.
induction m as [| m' IH].
- rewrite ord_add_zero.
  rewrite plus_n_0.
  reflexivity.
- induction n as [| n' IHn].
  + simpl.
    reflexivity.
  + simpl.
    rewrite <- (plus_n_1 m').
    rewrite plus_assoc.
    reflexivity.
Qed.

Lemma nat_ord_0 : nat_ord 0 = Zero.
Proof. simpl. reflexivity. Qed.

Lemma ord_mult_succ : forall (n m : nat),
  ord_mult (nat_ord n) (ord_succ (nat_ord m)) = nat_ord (n * (S m)).
Proof.
intros n m.
induction n as [| n' IH].
- simpl.
  destruct m.
  + simpl. reflexivity.
  + simpl. reflexivity.
- simpl.
  destruct m.
  + simpl.
    rewrite mult_1_r.
    rewrite minus_n_0.
    auto.
  + simpl.
    assert ((n' + 1) * S (m + 1) = S (S (m + n' * S (S m)))) as aux. { ring. }
    auto.
Qed.

Lemma ord_succ_nat : forall (n : nat),
  nat_ord (S n) = ord_succ (nat_ord n).
Proof.
intros n.
induction n.
- simpl. reflexivity.
- simpl. reflexivity.
Qed.

Lemma ord_mult_nat : forall (n m : nat),
  nat_ord (n * m) = ord_mult (nat_ord n) (nat_ord m).
Proof.
intros n m.
induction m as [| m' IH].
- rewrite nat_ord_0.
  rewrite mult_0_r.
  rewrite nat_ord_0.
  destruct n.
  + simpl. reflexivity.
  + simpl. reflexivity.
- rewrite ord_succ_nat.
  rewrite ord_mult_succ.
  reflexivity.
Qed.

(* Some miscellaneous lemmas about ordinals *)
(* *)
Lemma nf_scalar : forall (a b : ord) (n n' : nat),
  nf (cons a n b) -> nf (cons a n' b).
Proof.
intros a b n n' H.
inversion H.
- apply single_nf. apply H1.
- apply cons_nf.
  + apply H3.
  + apply H4.
  + apply H5.
Qed.

Lemma nf_hered_third : forall (a b : ord) (n : nat),
  nf (cons a n b) -> nf b.
Proof.
intros a b n H.
destruct b as [Zero | a' n' b'].
- apply Zero_nf.
- destruct b' as [Zero | a'' n'' b''].
  + apply single_nf. inversion H. inversion H7. apply H9.
  + inversion H. apply H7.
Qed.

Lemma nf_hered_first : forall (a b : ord) (n : nat),
  nf (cons a n b) -> nf a.
Proof.
intros a b n H.
destruct b as [Zero | a' n' b'].
- inversion H. apply H1.
- inversion H. apply H6.
Qed.

Lemma lt_irrefl : forall (alpha : ord), ~ (alpha < alpha).
Proof.
intros alpha H.
induction alpha as [Zero | a IHa n b IHb].
- inversion H.
- inversion H.
  + apply IHa. apply H1.
  + omega.
  + apply IHb. apply H1.
Qed.

Lemma zero_minimal : forall (alpha : ord), ~ (alpha < Zero).
intros alpha.
destruct alpha as [Zero | a n b].
- apply lt_irrefl.
- intros H. inversion H.
Qed.

Lemma nf_cons_decr' : forall (a a' b b' : ord) (n n' : nat),
  nf (cons a n (cons a' n' b')) -> cons a' n' b' < cons a n b.
Proof.
intros a a' b b' n n' H.
inversion H.
apply head_lt.
apply H3.
Qed.

Lemma nf_cons_decr : forall (a b : ord) (n : nat),
  nf (cons a n b) -> b < cons a n Zero.
Proof.
intros.
inversion H.
- apply zero_lt.
- apply head_lt.
  apply H3.
Qed.

Lemma cons_monot : forall (a b : ord) (n : nat),
  cons a 0 Zero <= cons a n b.
Proof.
intros a b n.
destruct n.
- destruct b as [Zero | a'' n'' b''].
  + unfold leq. left. reflexivity.
  + unfold leq. right. apply tail_lt. apply zero_lt.
- unfold leq. right. apply coeff_lt. omega.
Qed.

(* lt is a strict total order *)
(* *)
Lemma lt_strict : forall (alpha beta : ord),
  alpha < beta -> ~ (alpha = beta).
Proof.
intros alpha beta H_a H_b.
destruct alpha as [Zero | a n b].
- rewrite <- H_b in H_a. inversion H_a.
- rewrite H_b in H_a. apply lt_irrefl in H_a. inversion H_a.
Qed.

Lemma lt_trans : forall (alpha beta gamma : ord),
  alpha < beta -> beta < gamma -> alpha < gamma.
Admitted.


Lemma omega_exp_incr : forall (a : ord), a < cons a 0 Zero.
Proof.
intros a.
induction a as [Zero | a' IHa' n' b' IHb'].
- apply zero_lt.
- apply head_lt.
  assert (cons a' 0 Zero <= cons a' n' b').
  { apply cons_monot. }
  inversion H.
  + rewrite <- H0. apply IHa'.
  + apply (lt_trans a' (cons a' 0 Zero) (cons a' n' b') IHa' H0).
Qed.

Lemma omega_exp_incr' : forall (a b : ord) (n : nat), a < cons a n b.
Proof.
intros a b n.
pose proof (omega_exp_incr a).
pose proof (cons_monot a b n).
destruct H0.
- rewrite H0 in H. apply H.
- apply (lt_trans a (cons a 0 Zero) (cons a n b) H H0).
Qed.

Lemma lt_asymm : forall (alpha beta : ord),
  alpha < beta -> (~(beta < alpha) /\ ~(alpha = beta)).
Proof.
intros alpha beta H.
split.
- intros H0.
  pose proof (lt_trans alpha beta alpha H H0).
  apply (lt_irrefl alpha H1).
- intros H0.
  rewrite H0 in H.
  apply (lt_irrefl beta H).
Qed.



Lemma nf_add_one : forall (alpha : ord),
  nf alpha -> ord_succ alpha = ord_add alpha (cons Zero 0 Zero).
Proof.
intros alpha nf_alpha.
induction alpha as [Zero | a IHa n b IHb].
- simpl. reflexivity.
- destruct a as [Zero | a' n' b'].
  + simpl. assert (S n = n + 0 + 1). { omega. } rewrite H.
    assert (b = Zero).
    { inversion nf_alpha. reflexivity. inversion H3. }
    rewrite H0. reflexivity.
  + simpl. rewrite IHb. reflexivity. inversion nf_alpha.
    * apply Zero_nf.
    * apply H4.
Qed.



(* Carry over the ordinal arithmetic results to the e0 type *)
(* *)

Definition e0_ord (alpha : e0) : ord :=
match alpha with
| exist _ alpha' pf => alpha'
end.

Lemma nf_nat : forall (n : nat), nf (nat_ord n).
Proof.
induction n.
- unfold nat_ord.
  apply Zero_nf.
- unfold nat_ord.
  apply single_nf.
  apply Zero_nf.
Qed.

Definition nat_e0 (n : nat) : e0 := exist nf (nat_ord n) (nf_nat n).

Definition e0_eq (alpha : e0) (beta : e0) : bool :=
  ord_eqb (e0_ord alpha) (e0_ord beta).

Definition e0_lt (alpha : e0) (beta : e0) : bool :=
  ord_ltb (e0_ord alpha) (e0_ord beta).

Lemma nf_succ : forall (alpha : ord), nf alpha -> nf (ord_succ alpha).
Proof.
intros alpha H.
induction alpha as [Zero | a IHa n b IHb].
- simpl. apply single_nf. apply Zero_nf.
- destruct b as [Zero | a' n' b'].
  + destruct a as [Zero | a' n' b'].
    * simpl. apply single_nf. apply Zero_nf.
    * inversion H. simpl. apply cons_nf.
        { apply zero_lt. }
        { apply H1. }
        { apply single_nf. apply Zero_nf. }
  + destruct a as [Zero | a'' n'' b''].
    * simpl. inversion H. inversion H3.
    * assert (ord_succ (cons (cons a'' n'' b'') n (cons a' n' b')) = 
                    (cons (cons a'' n'' b'') n (ord_succ (cons a' n' b')))).
      { simpl. reflexivity. }
      rewrite H0.
      destruct a' as [Zero | a''' n''' b'''].
      { simpl. apply cons_nf.
        { apply zero_lt. }
        { inversion H. apply H7. }
        { inversion H. inversion H8.
          { apply single_nf. apply Zero_nf. }
          rewrite <- H11 in H8.
          inversion H8.
          inversion H12. }
      }
      { assert (nf (ord_succ (cons (cons a''' n''' b''') n' b'))).
        { apply IHb. inversion H. apply H8. }
          apply cons_nf.
        { inversion H. apply H5. }
        { inversion H. apply H8. }
        { apply H1. }
      }
Qed.

Lemma ord_add_aux : forall (a a' a'' b b' b'' : ord) (n n' n'' : nat),
  cons a n b = ord_add (cons a' n' b') (cons a'' n'' b'') -> (a = a' \/ a = a'').
Proof.
intros a a' a'' b b' b'' n n' n''.
simpl.
case (ord_ltb a' a'').
- intros H. inversion H. right. auto.
- case (ord_eqb a' a'').
  + intros H. inversion H. right. auto.
  + intros H. inversion H. left. auto.
Qed.

Definition normal_add (alpha : ord) :=
  forall (beta : ord), nf alpha -> nf beta -> nf (ord_add alpha beta).


Lemma nf_add' : forall (alpha : ord), normal_add alpha.
Proof.
intros.
induction alpha.
- unfold normal_add.
  intros.
  simpl.
  destruct beta.
  + simpl. apply zero_nf.
  + apply H0.
- unfold normal_add.
  intros.
  simpl.
  destruct beta.
  + apply H.
  + remember (ord_ltb alpha1 beta1) as c1.
    case c1 as [T | F].
    * apply H0.
    * remember (ord_eqb alpha1 beta1) as c2.
      case c2 as [T | F].
      { apply (nf_scalar beta1 beta2 n0 (n + n0 + 1)). apply H0. }
      { assert (ord_ltb beta1 alpha1 = true).
        { pose proof (ord_semiconnex_bool alpha1 beta1). destruct H1.
          { rewrite H1 in Heqc1. inversion Heqc1. }
          { destruct H1. 
            { apply H1. }
            { rewrite <- Heqc2 in H1. inversion H1. } } }
        remember (ord_add alpha2 (cons beta1 n0 beta2)) as A.
        destruct A.
        { apply single_nf. inversion H. apply H3. apply H6. }
        { apply cons_nf.
          { destruct alpha2 as [| a'' n'' b''].
            { simpl in HeqA. assert (A1 = beta1). { inversion HeqA. auto. }
              rewrite H2. apply (ord_ltb_lt _ _ H1). }
            { destruct (ordinal_semiconnex a'' beta1).
              { apply (ord_add_aux A1 a'' beta1 A2 b'' beta2 n1 n'' n0) in HeqA.
                destruct HeqA.
                { rewrite H3. inversion H. apply H7. }
                { rewrite H3. apply (ord_ltb_lt _ _ H1). } }
              { apply (ord_add_aux A1 a'' beta1 A2 b'' beta2 n1 n'' n0) in HeqA.
                destruct HeqA.
                { rewrite H3. inversion H. apply H7. }
                { rewrite H3. apply (ord_ltb_lt _ _ H1). } } } }
          { inversion H. apply H3. apply H6. }
          { rewrite HeqA. unfold normal_add in IHalpha2.
            specialize IHalpha2 with (cons beta1 n0 beta2). apply IHalpha2.
            inversion H. apply Zero_nf. apply H7. apply H0. } } }
Qed.


Lemma nf_add : forall (alpha beta : ord),
  nf alpha -> nf beta -> nf (ord_add alpha beta).
Proof.
intros.
pose proof (nf_add' alpha).
unfold normal_add in H1.
specialize H1 with beta.
apply H1. apply H. apply H0.
Qed.






(* Defining ordinal lists to represent normal form ordinals *)
(* *)

Definition ord_list_exmp : list ord :=
  [cons (cons Zero 6 Zero) 2 Zero,
    cons (cons Zero 0 Zero) 0 (cons Zero 0 Zero),
    cons Zero 4 Zero,
    cons Zero 1 Zero,
    Zero].

Check ord_list_exmp.

Definition ord_exmp : ord :=
  cons (cons (cons Zero 6 Zero) 2 Zero) 0 (
    cons (cons (cons Zero 0 Zero) 0 (cons Zero 0 Zero)) 2 (
    cons (cons Zero 4 Zero) 3 (
    cons (cons Zero 1 Zero) 0 (
    cons Zero 2 Zero)))).

Fixpoint ord_exp_list (alpha : ord) : list ord :=
match alpha with
| Zero => []
| cons a n b => a :: (ord_exp_list b)
end.

Compute ord_exp_list ord_exmp.

Fixpoint sorted_desc (X : Type) (l : list X) (R : X -> X -> bool) : bool :=
match l with
| [] => true
| x :: l' =>
  (match l' with
  | [] => true
  | y :: l'' => R y x && sorted_desc X l' R
  end)
end.

Definition sorted_ord (l : list ord) : bool := sorted_desc _ l ord_ltb.

Compute sorted_ord ord_list_exmp.

Fixpoint nf_list (l : list ord) : Prop :=
match l with
| [] => True
| a :: l' => nf a /\ nf_list l'
end.

Fixpoint exp_list_to_ord (l : list ord) : ord :=
match l with
| [] => Zero
| a :: l' => cons a 0 (exp_list_to_ord l')
end.

Fixpoint lists_to_ord (l_a : list ord) (l_n : list nat) : ord :=
match l_a, l_n with
| [], _ => Zero
| _, [] => Zero   (* we assume the lists are of equal size *)
| a :: l_a', n :: l_n' => cons a (n - 1) (lists_to_ord l_a' l_n')
end. (* n-1 to undo taking the successor *)

Compute (true, 5).

Fixpoint ord_coeff_list (alpha : ord) : list nat :=
match alpha with
| Zero => []
| cons a n b => S n :: (ord_coeff_list b) (* return n+1  for cons a n b *)
end.

Definition ord_to_lists (alpha : ord) : (list ord) * (list nat) :=
  (ord_exp_list alpha, ord_coeff_list alpha).



Check (ord_to_lists ord_exmp).
Compute (lists_to_ord (fst (ord_to_lists ord_exmp)) (snd (ord_to_lists ord_exmp))).

Fixpoint list_mult_by_m (l : list nat) (m : nat) : list nat :=
match l with
| [] => []
| n :: l' => n*m :: (list_mult_by_m l' m)
end.

Compute ord_exmp.


Lemma nf_to_nf_list : forall (alpha : ord), nf alpha -> nf_list (ord_exp_list alpha).
Proof.
intros.
induction alpha as [| a IHa n b IHb].
- simpl. auto.
- simpl. split.
  + apply (nf_hered_first a b n H).
  + apply IHb. apply (nf_hered_third a b n H).
Qed.

Lemma sorted_ord_hered_aux' :
  forall (X : Type) (l : list X) (x : X) (R : X -> X -> bool),
  sorted_desc X (x :: l) R = true -> sorted_desc X l R = true.
Proof.
intros.
simpl in H.
case_eq l.
- auto.
- intros. rewrite <- H0. rewrite H0 in H. case_eq (R x0 x).
  + intros. rewrite H1 in H. rewrite <- H0 in H. simpl in H. apply H.
  + intros. rewrite H1 in H. simpl in H. inversion H.
Qed.

Lemma sorted_ord_hered_aux : forall (l : list ord) (a : ord),
  sorted_ord (a :: l) = true -> sorted_ord l = true.
Proof.
intros.
pose proof (sorted_ord_hered_aux' ord l a ord_ltb H).
apply H0.
Qed.


Lemma sorted_ord_hered : forall (a a' b' : ord) (n n' : nat),
  sorted_ord (ord_exp_list (cons a n (cons a' n' b'))) = true ->
  sorted_ord (ord_exp_list (cons a' n' b')) = true.
Proof.
intros.
assert (ord_exp_list (cons a n (cons a' n' b')) =
        a :: ord_exp_list (cons a' n' b')).
{ auto. }
rewrite H0 in H. apply (sorted_ord_hered_aux _ a). apply H.
Qed.



Lemma list_sorted_nf : forall (alpha : ord),
  sorted_ord (ord_exp_list alpha) = true -> nf_list (ord_exp_list alpha)
  -> nf alpha.
Proof.
intros.
induction alpha as [| a IHa n b IHb].
- apply Zero_nf.
- destruct b as [| a' n' b'].
  + apply single_nf. inversion H0. apply H1.
  + apply cons_nf.
    * inversion H. unfold sorted_ord in H2. simpl in H2.
      assert (ord_ltb a' a = true).
      { case_eq (ord_ltb a' a).
        { auto. }
        { intros. rewrite H1 in H2. simpl in H2. inversion H2. } }
      apply ord_ltb_lt. apply H1.
    * inversion H0. apply H1.
    * apply IHb.
      { apply (sorted_ord_hered a a' b' n n' H). }
      { inversion H0. apply H2. }
Qed.

(*
Lemma list_nf_sorted_aux'' :
  forall (X : Type) (l l' : list X) (x x' : X) (R : X -> X -> bool),
  l = x :: x' :: l' -> sorted_desc X l R = true -> R x' x = true.
Proof.
intros.
induction l.
- inversion H.
- apply IHl.
  + 

Lemma list_nf_sorted_aux' :
  forall (X : Type) (l : list X) (x x' : X) (R : X -> X -> bool),
  R x' x = true -> sorted_desc X (x' :: l) R = true ->
  sorted_desc X (x :: x' :: l) R = true.
Proof.
intros.
induction l.
- simpl. rewrite H. auto.
- simpl. rewrite H. case_eq l.
  + intros. admit.
  + intros. rewrite <- H1. 





Lemma list_nf_sorted_aux : forall (l : list ord) (a a' : ord),
  a' < a -> sorted_ord (a' :: l) = true -> sorted_ord (a :: a' :: l) = true.
Proof.
intros.
induction l.
- unfold sorted_ord. unfold sorted_desc.
  assert (ord_ltb a' a = true). { apply (ord_lt_ltb). apply H. }
  rewrite H1. auto.
- unfold sorted_ord. unfold sorted_desc. case_eq l.
  + intros. admit.
  + intros. 

Lemma list_nf_sorted : forall (alpha : ord),
  nf alpha -> sorted_ord (ord_exp_list alpha) = true.
Proof.
intros.
induction alpha as [| a IHa n b IHb].
- auto.
- destruct b as [| a' n' b'].
  + auto.
  + simpl.
    assert (ord_exp_list (cons a' n' b') = a' :: ord_exp_list b').
    { auto. }
    rewrite <- H0. simpl. apply (sorted_ord_hered_aux).






 unfold sorted_ord. unfold sorted_desc. case_eq (ord_exp_list b).
  + auto.
  + intros. 


Definition ord_mult_by_m (alpha : ord) (m : nat) :=
  lists_to_ord (ord_exp_list alpha)
               (list_mult_by_m (ord_coeff_list alpha) m).

Compute ord_exmp.
Compute (ord_coeff_list ord_exmp).
Compute (ord_mult_by_m ord_exmp 100).

Definition xxx (l_a : list ord) := forall (l_n : list nat),
  length l_a = length l_n -> ord_exp_list (lists_to_ord l_a l_n) = l_a.

Lemma xx : forall (l_a : list ord), xxx l_a.
Proof.
intros.
induction l_a.
- unfold xxx. auto.
- unfold xxx. intros. case_eq l_n.
  + intros. rewrite H0 in H. simpl in H. inversion H.
  + intros. unfold xxx in IHl_a. specialize IHl_a with l.
    rewrite H0 in H. simpl in H.
    assert (length l_a = length l). { auto. }
    apply IHl_a in H1. simpl. rewrite H1. auto.
Qed.

Lemma x' : forall (l_a : list ord) (l_n : list nat),
  length l_a = length l_n -> ord_exp_list (lists_to_ord l_a l_n) = l_a.
Proof.
intros.
apply xx. apply H.
Qed.

Lemma x'' : forall (alpha : ord) (m : nat),
  length (ord_exp_list alpha) = length (ord_coeff_list alpha).
Proof.
intros.
induction alpha as [| a IHa n b IHb].
- auto.
- simpl. rewrite IHb. auto.
Qed.


Lemma x''' : forall (alpha : ord) (m : nat),
  length (ord_exp_list (ord_mult_by_m alpha m)) = length (ord_exp_list alpha).
Proof.
intros.
induction alpha as [| a IHa n b IHb].
- auto.
- simpl.
  pose proof (x' (ord_exp_list b) (list_mult_by_m (ord_coeff_list b) m)).
  assert (length (ord_exp_list b) = length (list_mult_by_m (ord_coeff_list b) m)).
  { admit. }
  apply H in H0.
  rewrite H0. auto.
Admitted.



Lemma x : forall (alpha : ord) (m : nat),
  ord_exp_list (ord_mult_by_m alpha m) = ord_exp_list alpha.
Proof.
intros.
induction alpha as [| a IHa n b IHb].
- auto.
- simpl. rewrite (x' (ord_exp_list b)).
  + auto.
  + rewrite <- IHb. rewrite x'''.
    assert (length (ord_exp_list b) = length (ord_coeff_list b)). { admit. }
    assert (length (ord_coeff_list b) =
            length (list_mult_by_m (ord_coeff_list b) m)). { admit. }
Admitted.




Lemma nf_mult_by_m : forall (alpha : ord) (m : nat),
  nf alpha -> nf (ord_mult_by_m alpha m).
Proof.
intros.
induction alpha as [| a IHa n b IHb].
- simpl. apply Zero_nf.
- apply list_sorted_nf.
  + rewrite x.  simpl. rewrite <- x.

unfold ord_mult_by_m. unfold ord_mult_by_m in IHa.















Lemma x : forall (b : ord), nf b -> forall (m : nat), nf (ord_mult_by_n b m) /\
  (exists (a' b' : ord) (n' : nat), b = cons a' n' b' ->
  ord_mult_by_n b m = cons a' ((n' + 1) * m - 1) (ord_mult_by_n b' m)).
Proof.
intros.
induction b as [| a' IHa' n' b' IHb'].
- split.
  + simpl. apply Zero_nf.
  + simpl. inversion H0.
- split.
  + simpl. case_eq b1.
    * intros. apply nf_nat.
    * intros. assert (nf b2). { admit. }
      apply IHb2 in H1. destruct H1. assert (b2 = cons a' n' b'). { admit. }
      apply H2 in H3. rewrite H3. rewrite <- H0. 




Require Import Lia.

Lemma nf_mult_by_n_aux : forall (a b : ord) (n m : nat),
  nf (cons a n b) -> lt_nat 0 m = true ->
  ord_mult_by_n (cons a n b) m = cons a ((n + 1) * m - 1) (ord_mult_by_n b m).
Proof.
intros.
simpl.
destruct a as [| a' IHa' n' b' IHb'].
- inversion H.
  + simpl. unfold nat_ord. destruct m.
    * inversion H0.
    * case_eq ((n + 1) * S m).
      { intros. assert (lt_nat 0 ((n + 1) * S m) = true).
        { admit. }
        rewrite H5 in H6. rewrite (lt_nat_irrefl 0) in H6. inversion H6. }
      { intros. simpl. assert (n1 = n1 - 0). { omega. } rewrite <- H6. auto. }
  + admit.
- auto.
Admitted.

Definition nf_multy' (alpha : ord) := forall (n : nat),
  nf alpha -> nf (ord_mult_by_n alpha n).

Lemma nf_multy : forall (alpha : ord), nf_multy' alpha.
Proof.
intros.
induction alpha.
- unfold nf_multy'. intros. simpl. apply Zero_nf.
- unfold nf_multy'. intros. simpl.
  destruct alpha2 as [| a'' n'' b''].
  + destruct alpha1 as [| a' n' b']. admit. admit.
  + destruct alpha1 as [| a' n' b'].
    * apply nf_nat.
    * rewrite (nf_mult_by_n_aux a'' b'' n'' n0).
      { 


Definition thing (alpha : ord) := forall (a b : ord) (n m : nat),
  alpha = cons a n b -> nf (ord_mult_by_n alpha n).


leading_exponent

  
  + apply nf_nat.
  + 

unfold nf_multy' in IHalpha1.



Lemma nf_mult_by_n : forall (alpha : ord) (m : nat),
  nf alpha -> nf (ord_mult_by_n alpha m).
Proof.
intros.
destruct alpha as [| a n b].
- simpl. apply zero_nf.
- induction b as [| a'' IHa'' n'' b'' IHb''].
  + simpl. destruct a as [| a' n' b'].
    * apply nf_nat.
    * apply single_nf. inversion H. apply H1.
  + simpl. destruct b as [| a'' n'' b''].
    * simpl. apply single_nf. inversion H. apply H1.
    * simpl.




Lemma nf_mult_by_n_aux : forall (a b : ord) (n m : nat), nf (cons a n b) ->
  nf (cons a n (ord_mult_by_n b m)).
Proof.
intros.
induction a as [| a' IHa' n' b' IHb'].
- destruct b as [| a'' n'' b''].
  + simpl. apply H.
  + inversion H. inversion H3.
- destruct b as [| a'' n'' b''].
  + simpl. apply H.
  + 



Lemma nf_mult_by_n_aux : forall (a b : ord) (n m : nat), nf (cons a n b) ->
  ord_mult_by_n (cons a n b) m = cons a ((n + 1) * m - 1) b.
Proof.
admit.
Admitted.

Lemma nf_mult_by_n : forall (alpha : ord) (m : nat),
  nf alpha -> nf (ord_mult_by_n alpha m).
Proof.
intros.
destruct alpha as [| a n b].
- simpl. apply zero_nf.
- destruct a as [| a' n' b'].
  + simpl. apply nf_nat.
  + simpl. destruct b as [| a'' n'' b''].
    * simpl. apply single_nf. inversion H. apply H1.
    * simpl.


 rewrite nf_mult_by_n_aux. apply (nf_scalar _ _ n ((n + 1) * m - 1)).





 as [| a'' n'' b''].
      { apply single_nf. inversion H. apply H1. apply H4. }
      { apply cons_nf.
        { inversion n''. apply zero_lt. apply head_lt. inversion n''. admit. }
        { inversion H. apply H1. apply H4. }
        { 







Lemma nf_mult_by_n : forall (alpha : ord) (m : nat),
  nf alpha -> nf (ord_mult_by_n alpha m).
Proof.
intros.
induction alpha.
- simpl. apply zero_nf.
- simpl. case_eq alpha1.
  + intros. apply nf_nat.
  + case_eq m.
    * intros. apply Zero_nf.
    * intros. rewrite <- H1. apply cons_nf.



destruct alpha1 as [| a' n' b'].
  + apply nf_nat.
  + case m.
    * intros. apply zero_nf.
    * intros. induction (ord_mult_by_n alpha2 (S n0)) as [| a'' n'' b''].
      { apply single_nf. inversion H. apply H1. apply H4. }
      { apply cons_nf.
        { inversion n''. apply zero_lt. apply head_lt. inversion n''. }
        { inversion H. apply H1. apply H4. }
        { 


*)


Lemma nf_multy_aux : forall (a a' b b' : ord) (n n' : nat),
  Zero < a' ->
  ord_mult (cons a n b) (cons a' n' b') =
  cons (ord_add a a') n' (ord_mult (cons a n b) b').
Proof.
intros.
simpl.
case_eq a'.
- intros. rewrite H0 in H. inversion H.
- intros. auto.
Qed.

(*
Lemma nf_multy_aux' : forall (a b b' : ord) (n n' : nat),
  ord_mult (cons a n b) (cons Zero n' b') =
  ord_mult_by_n (cons a n b) (n' + 1).
Proof.
auto.
Qed.
*)









Definition add_right_incr' (alpha : ord) := forall (beta gamma : ord),
  beta < gamma -> ord_add alpha beta < ord_add alpha gamma.

Lemma add_right_incr_aux : forall (alpha : ord), add_right_incr' alpha.
Proof.
intros.
induction alpha as [| a IHa n b IHb].
- unfold add_right_incr'. intros. simpl. destruct beta as [| a' n' b'].
  + destruct gamma as [| a'' n'' b''].
    * inversion H.
    * auto.
  + destruct gamma as [| a'' n'' b''].
    * inversion H.
    * auto.
- unfold add_right_incr'. intros. simpl. destruct beta as [| a' n' b'].
  + destruct gamma as [| a'' n'' b''].
    * inversion H.
    * auto. pose proof (ord_semiconnex_bool a a'').
      destruct H0.
      { rewrite H0. apply head_lt. apply ord_ltb_lt. apply H0. }
      { destruct H0.
        { apply (ltb_asymm a'' a) in H0. unfold not in H0. admit. }
      { admit. } }
  + destruct gamma as [| a'' n'' b''].
    * inversion H.
    * admit.
Admitted.




Lemma add_right_incr : forall (alpha beta gamma : ord),
  beta < gamma -> ord_add alpha beta < ord_add alpha gamma.
Proof.
intros.
Admitted.

Lemma add_right_incr_corr : forall (alpha beta1 beta2 : ord) (n_beta : nat),
  alpha < ord_add alpha (cons beta1 n_beta beta2).
Proof.
intros.
pose proof (add_right_incr alpha Zero (cons beta1 n_beta beta2)).
pose proof (zero_lt beta1 n_beta beta2).
apply H in H0.
rewrite (ord_add_zero alpha) in H0.
apply H0.
Qed.





Definition mult_right_nice (gamma : ord) := 
  gamma = Zero \/ forall (alpha beta : ord),
  alpha < beta -> ord_mult gamma alpha < ord_mult gamma beta.


Definition mult_right_nice2 (alpha gamma : ord) := 
  gamma = Zero \/ forall (beta : ord),
  alpha < beta -> ord_mult gamma alpha < ord_mult gamma beta.





Lemma mult_right_incr_aux : forall (gamma : ord), mult_right_nice gamma.
Proof.
intros.
induction gamma as [| gamma1 IHgamma1 n_gamma gamma2 IHgamma2].
- unfold mult_right_nice. left. auto.
- assert (forall (alpha : ord), mult_right_nice2 alpha
              (cons gamma1 n_gamma gamma2)).
  { intros. induction alpha as [| alpha1 IHalpha1 n_alpha alpha2 IHalpha2].
    { unfold mult_right_nice2. right. intros.
      destruct beta as [| beta1 n_beta beta2].
      { inversion H. }
      { destruct beta1.
        { simpl. destruct gamma1.
          { unfold nat_ord. apply zero_lt. }
          { apply zero_lt. } }
        { simpl. apply zero_lt. } } }
    { unfold mult_right_nice2. right. intros.
      destruct beta as [| beta1 n_beta beta2].
      { inversion H. }
      { destruct alpha1.
        { destruct beta1.
          { inversion H.
            { inversion H1. }
            { simpl. apply coeff_lt.
              rewrite minus_n_0. rewrite minus_n_0.
              apply mult_right_incr_aux_aux. apply H1. }
            { simpl. apply tail_lt. unfold mult_right_nice2 in IHalpha2.
              destruct IHalpha2.
              { inversion H6. }
              { apply H6. apply H1. } } }
          { simpl. apply head_lt. apply add_right_incr_corr. } }
        { destruct beta1.
          { inversion H. inversion H1. }
          { rewrite nf_multy_aux. rewrite nf_multy_aux.
            { inversion H.
              { apply head_lt. apply add_right_incr. apply H1. }
              { apply coeff_lt. apply H1. }
              { apply tail_lt. unfold mult_right_nice2 in IHalpha2.
                inversion IHalpha2.
                { inversion H9. }
                { apply (H9 beta2). apply H1. } } }
            { apply zero_lt. }
            { apply zero_lt. } } } } } }
  unfold mult_right_nice. right. intros alpha. unfold mult_right_nice2 in H.
  specialize H with alpha. destruct H. inversion H. apply H.
Admitted.

















Lemma mult_right_incr_aux : forall (beta : ord), mult_right_incr' beta.
Proof.
intros.
induction beta as [| a' IHa' n' b' IHb'].
- unfold mult_right_incr'. intros. destruct gamma as [| a'' n'' b''].
  + auto.
  + simpl. case a''.
    * case a.
      { unfold nat_ord. case_eq ((n + 1) * (n'' + 1)).
        { intros. admit. }
        { intros. apply zero_lt. } }
      { intros. apply zero_lt. }
    * intros. apply zero_lt.
- unfold mult_right_incr'. intros.
  induction gamma as [| a'' IHa'' n'' b'' IHb''].
  + inversion H.
  + unfold mult_right_incr' in IHa'. unfold mult_right_incr' in IHb'.
    simpl. case_eq a'.
    * case_eq a.
      { case_eq a''.
        { intros. rewrite H2 in H. rewrite H0 in H. inversion H.
          { inversion H4. }
          { admit. }
          { admit. } }
        { admit. } }
      { admit. }
    * admit.
Admitted.



Lemma mult_right_incr : forall (a b beta gamma : ord) (n : nat),
  beta < gamma -> ord_mult (cons a n b) beta < ord_mult (cons a n b) gamma.
Proof.
intros.
pose proof (mult_right_incr_aux beta).
unfold mult_right_incr' in H0.
apply H0.
apply H.
Qed.








Definition nf_multy' (alpha : ord) := forall (beta : ord),
  nf alpha -> nf beta -> nf (ord_mult alpha beta).


Lemma nf_multy : forall (alpha : ord), nf_multy' alpha.
Proof.
intros.
induction alpha as [| a IHa n b IHb].
- unfold nf_multy'. intros. destruct beta as [| a' n' b'].
  + auto.
  + auto.
- unfold nf_multy'. intros. induction beta as [| a' IHa' n' b' IHb'].
  + auto.
  + assert (nf (cons (ord_add a a') n' (ord_mult (cons a n b) b'))).
    { assert (nf (ord_add a a')).
      { apply nf_add.
        { inversion H. apply H2. apply H5. }
        { inversion H0. apply H2. apply H5. } }
    { assert (ord_mult (cons a n b) b' < ord_mult (cons a n b) (cons a' n' Zero)).
      { apply mult_right_incr. apply nf_cons_decr. apply H0. }
      case_eq (ord_mult (cons a n b) b').
      { intros. apply single_nf. apply H1. }
      { intros a'' n'' b'' H3. apply cons_nf.
        { assert (ord_mult (cons a n b) (cons a' n' Zero) =
                  cons (ord_add a a') n' (ord_mult (cons a n b) Zero)).
          { apply nf_multy_aux. }
          rewrite H4 in H2. destruct b' as [| a''' n''' b'''].
          { simpl in H3. inversion H3. }
          { assert (ord_mult (cons a n b) (cons a''' n''' b''') =
            cons (ord_add a a''') n''' (ord_mult (cons a n b) b''')).
            { apply nf_multy_aux. }
            rewrite H5 in H3. inversion H3.
            assert (a''' < a').
            { inversion H0. apply H12. }
            apply add_right_incr. apply H6. } }
      { apply nf_add.
        apply (nf_hered_first a b n H).
        apply (nf_hered_first a' b' n' H0). }
      { rewrite <- H3. apply IHb'. apply (nf_hered_third a' b' n' H0). } } } }
    assert (ord_mult (cons a n b) (cons a' n' b') =
            cons (ord_add a a') n' (ord_mult (cons a n b) b')).
    { apply nf_multy_aux. }
    rewrite H2. apply H1.
Qed.






Lemma nf_mult : forall (alpha beta : ord),
  nf alpha -> nf beta -> nf (ord_mult alpha beta).
Proof.
intros.
pose proof (nf_multy alpha).
unfold nf_multy' in H1.
specialize H1 with beta.
apply H1.
apply H.
apply H0.
Qed.









Definition e0_pf (alpha : e0) : (nf (e0_ord alpha)) :=
match alpha with
| exist _ alpha' pf => pf
end.

Definition e0_succ (alpha : e0) : e0 :=
  exist nf (ord_succ (e0_ord alpha)) (nf_succ (e0_ord alpha) (e0_pf alpha)).

Definition e0_add (alpha beta : e0) : e0 :=
  exist nf (ord_add (e0_ord alpha) (e0_ord beta))
    (nf_add (e0_ord alpha) (e0_ord beta) (e0_pf alpha) (e0_pf beta)).

Definition e0_mult_by_n (alpha : e0) (m : nat) : e0 :=
  exist nf (ord_mult_by_n (e0_ord alpha) m)
    (nf_mult_by_n (e0_ord alpha) m (e0_pf alpha)).

Definition e0_mult (alpha beta : e0) : e0 :=
  exist nf (ord_mult (e0_ord alpha) (e0_ord beta))
    (nf_mult (e0_ord alpha) (e0_ord beta) (e0_pf alpha) (e0_pf beta)).



(* Determine if a formula c follows from some premises based on the
inference rules *)
Fixpoint exchange (c p : formula) : bool :=
  match (c, p) with
  | (lor (lor (lor c b) a) d, lor (lor (lor c' a') b') d') =>
        (eq_f a a') && (eq_f b b') && (eq_f c c') && (eq_f d d')
  | (_,_) => false
end.

Fixpoint contraction (c p : formula) : bool :=
  match (c, p) with
  | (lor a d, lor (lor a' a'') d') =>
        (eq_f a a') && (eq_f a' a'') && (eq_f d d')
  | (_,_) => false
end.

Fixpoint weakening (c p : formula) : bool :=
  match (c, p) with
  | (lor a d, d') => eq_f d d'
  | (_,_) => false
end.

Fixpoint negation (c p : formula) : bool :=
  match (c, p) with
  | (lor (neg (neg a)) d, lor a' d') => (eq_f a a') && (eq_f d d')
  | (_,_) => false
end.

Fixpoint quantification (c p : formula) : bool :=
  match (c, p) with
  | (lor (neg (univ n a)) d, lor (neg a') d') =>
        (eq_f a a') && (eq_f d d') && (transformable a a' n)
  | (_,_) => false
end.

Fixpoint demorgan (c p1 p2 : formula) : bool :=
  match (c, p1, p2) with
  | (lor (neg (lor a b)) d, lor (neg a') d', lor (neg b') d'') =>
      (eq_f a a') && (eq_f b b') && (eq_f d d') && (eq_f d' d'')
  | (_,_,_) => false
end.

(* we define the degree of a cut; if this returns 0 its not a cut *)
Fixpoint cut_degree (c p1 p2 : formula) : nat :=
  match (c, p1, p2) with
  | (lor c d, lor c' a, lor (neg a') d') =>
      (match (eq_f a a' && eq_f c c' && eq_f d d') with
      | true => 1 + (num_conn a)
      | false => 0
      end)
  | (_, _, _) => 0
end.



(*
Defining proof-trees, which are decorated with ordinals as well as formulas.
This allows us to define the infinite-induction rule.
*)
(* *)
Inductive ptree : Type :=
| node : formula -> nat -> e0 -> ptree
| one_prem : formula -> nat -> e0 -> ptree -> ptree
| two_prem : formula -> nat -> e0 -> ptree -> ptree -> ptree
| inf_prem : formula -> nat -> e0 -> (nat -> ptree) -> ptree.

Fixpoint tree_form (t : ptree) : formula :=
match t with
| node f deg alpha => f
| one_prem f deg alpha t' => f
| two_prem f deg alpha t1 t2 => f
| inf_prem f deg alpha g => f
end.

Fixpoint tree_degree (t : ptree) : nat :=
match t with
| node f deg alpha => deg
| one_prem f deg alpha t' => deg
| two_prem f deg alpha t1 t2 => deg
| inf_prem f deg alpha g => deg
end.

Fixpoint tree_ord (t : ptree) : e0 :=
match t with
| node f deg alpha => alpha
| one_prem f deg alpha t' => alpha
| two_prem f deg alpha t1 t2 => alpha
| inf_prem f deg alpha g => alpha
end.


Fixpoint infinite_induction (f : formula) (g : nat -> ptree) : Prop :=
  match f with
  | lor (univ n a) d => forall (m : nat),
          true = transformable_with_list
                  (lor a d) (tree_form (g m)) n [represent m]
  | _ => False
end.


(* Determine if a given ptree is a valid proof tree, with or without
the cut and infinite induction rules. This involves verifying that:
1) Any parent-child pair matches an inference rule
2) The number of connectives in a cut formula is no bigger than the bound b
3) The bound of the subtree(s) are no larger than the bound b
4) The subtree(s) are valid *)
(* *)
Definition node_valid (f : formula) : Prop :=
  match f with
  | atom a => true = correct_a a
  | neg a => (match a with
             | atom a' => true = incorrect_a a'
             | _ => False
              end)
  | _ => False
    end.

Definition one_prem_valid (f : formula) (deg : nat) (alpha : e0)
                          (t' : ptree) : Prop :=

  ((true = (exchange f (tree_form t') || contraction f (tree_form t'))
          /\ alpha = tree_ord t')
  \/
  (true = (weakening f (tree_form t') || negation f (tree_form t')
              || quantification f (tree_form t'))
          /\ gt_e0 alpha (tree_ord t')))

/\ deg >= tree_degree t'.


Definition two_prem_valid (f : formula) (deg : nat) (alpha : e0)
                          (t1 t2 : ptree) : Prop :=

  (true = demorgan f (tree_form t1) (tree_form t2)
  \/ 0 < cut_degree f (tree_form t1) (tree_form t2) < deg)

/\ deg >= tree_degree t1
/\ deg >= tree_degree t2
/\ gt_e0 alpha (tree_ord t1)
/\ gt_e0 alpha (tree_ord t2).


Definition inf_prem_valid (f : formula) (deg : nat) (alpha : e0)
                          (g : nat -> ptree) : Prop :=

infinite_induction f g
/\ forall (n : nat), deg >= tree_degree (g 5)
/\ forall (n : nat), gt_e0 alpha (tree_ord (g n)).


Fixpoint valid (t : ptree) : Prop :=
  match t with
  | node f deg alpha => node_valid f

  | one_prem f deg alpha t' => one_prem_valid f deg alpha t' /\ valid t'

  | two_prem f deg alpha t1 t2 =>
      two_prem_valid f deg alpha t1 t2 /\ valid t1 /\ valid t2

  | inf_prem f deg alpha g =>
      inf_prem_valid f deg alpha g /\ forall (n : nat), valid (g n)
  end.


Definition x : e0 := exist nf Zero Zero_nf.
Definition f_exmp : formula := (atom (equ zero zero)).
Definition t_exmp_0 : ptree := node f_exmp 0 x.

Theorem a : exists (T : ptree), T = node f_exmp 0 x.
Proof.
pose (witness := t_exmp_0).
refine (ex_intro _ witness _).
unfold witness.
unfold t_exmp_0.
reflexivity.
Qed.


(* Axiom of induction up to epsilon_0 *)
(* *)
(*
Axiom stuff 

Axiom transfinite_induction_e0        :=
*)






(* Exercise 1 *)
(* *)



(* Lemma 1 *)
(* *)
Definition nat_e0 (n : nat) : e0 :=



Lemma nat_e0 : forall (n : nat)


Theorem lemma_1 : forall (A : formula) (n : nat), n = (num_conn A) ->
    exists (t : ptree), (tree_form T = (lor (neg A lor A)))
                    /\  (leq_e0 (tree_ord T) 









