Require Export UniMath.Foundations.Sequences.
Require Export UniMath.Foundations.Algebra.Monoids_and_Groups.
Require Export UniMath.Foundations.FunctionalExtensionality.
Unset Automatic Introduction.

Lemma stnsum_dni {n i} (f:stn(S n)->nat) : stnsum f = stnsum (f ∘ dni n i) + f i.
Proof.
  intros.

Abort.
  
Lemma stnsum_lt {n} (f g:stn n->nat) : (∀ i, f i ≤ g i) -> (∃ i, f i < g i) -> stnsum f < stnsum g.
Proof.

Abort.

(** general associativity for monoids *)

Open Scope multmonoid.

(* demonstrate that the Coq parser is left-associative with "*" *)
Goal ∀ (M:monoid) (x y z:M), x*y*z = (x*y)*z. Proof. reflexivity. Defined.
Goal ∀ (M:monoid) (x y z:M), x*y*z = x*(y*z). Proof. apply assocax. Defined.

(* demonstrate that the Coq parser is left-associative with "+" *)
Open Scope addmonoid.
Goal ∀ (M:monoid) (x y z:M), x+y+z = (x+y)+z. Proof. reflexivity. Defined.
Goal ∀ (M:monoid) (x y z:M), x+y+z = x+(y+z). Proof. apply assocax. Defined.
Close Scope addmonoid.

(* we define iterated products in the same way now, with left associativity: *)
Definition sequenceProduct {M:monoid} : Sequence M -> M.
Proof.
  intros ? [n x].
  induction n as [|n sequenceProduct].     
  { exact 1. }
  { exact (sequenceProduct (pr2 (drop (S n,,x) (negpathssx0 _))) * x (lastelement _)). }
Defined.

Definition doubleProduct {M:monoid} : Sequence (Sequence M) -> M.
Proof.
  intros ? [n x].
  induction n as [|n doubleProduct].     
  { exact 1. }
  { exact ((doubleProduct (x ∘ dni_lastelement) * sequenceProduct (x (lastelement _)))). }
Defined.

(* verify that our associativity matches that of the parser, with an extra "1" *)
Local Notation "●" := (idpath _).
Goal ∀ (M:monoid) (f:stn 3 -> M), sequenceProduct(3,,f) = 1 * f(O,,●) * f(S O,,●) * f(S(S O),,●).
Proof. reflexivity. Defined.

Goal ∀ (M:monoid) (f:stn 3 -> Sequence M),
       doubleProduct(3,,f) =
          1 * sequenceProduct (f(O,,●))
            * sequenceProduct (f(S O,,●))
            * sequenceProduct (f(S(S O),,●)).
Proof. reflexivity. Defined.

(* some rewriting rules *)

Definition sequenceProductStep {M:monoid} {n} (x:stn (S n) -> M) :
  sequenceProduct (S n,,x) = sequenceProduct (n,,x ∘ dni_lastelement) * x (lastelement _).
Proof. intros. reflexivity. Defined.

Local Definition sequenceProduct_append {M:monoid} (x:Sequence M) (m:M) :
  sequenceProduct (append x m) = sequenceProduct x * m.
Proof. intros ? [n x] ?. unfold append. rewrite sequenceProductStep.
       unfold funcomp, lastelement.
       Local Opaque sequenceProduct. simpl. Transparent sequenceProduct.
       induction (natlehchoice4 n n (natgthsnn n)) as [p|p].
       { contradicts (isirreflnatlth n) p. }
       { change ((n,, natgthsnn n):stn (S n)) with (lastelement n).
         rewrite append_fun_compute_2.
         apply (maponpaths (λ a, a * m)).
         apply (maponpaths (λ x, sequenceProduct (n,,x))).
         apply funextfun; intros [i b]; simpl.
         now rewrite append_fun_compute_1. }
Defined.

Local Definition doubleProductStep {M:monoid} {n} (x:stn (S n) -> Sequence M) :
  doubleProduct (S n,,x) = doubleProduct (n,,x ∘ dni_lastelement) * sequenceProduct (x (lastelement _)).
Proof. intros. reflexivity. Defined.

(* The general associativity theorem. *)

Theorem associativityOfProducts {M:monoid} (x:Sequence (Sequence M)) :
  sequenceProduct (flatten x) = doubleProduct x.
Proof.
  (* this proof comes from the Associativity theorem, Bourbaki, Algebra, § 1.3, Theorem 1, page 4. *)
  intros ? [n x].
  induction n as [|n IHn].
  { reflexivity. }
  { rewrite flattenStep, doubleProductStep.
    generalize (x (lastelement _)) as z.
    generalize (x ∘ dni_lastelement) as y.
    intros y [m z].
    induction m as [|m IHm].
    { change (sequenceProduct (0,, z)) with (unel M). rewrite runax.
      change (concatenate (flatten (n,, y)) (0,, z)) with (flatten (n,, y)).
      exact (IHn y). }
    { rewrite sequenceProductStep, concatenateStep.
      generalize (z (lastelement m)) as w; generalize (z ∘ dni _ (lastelement _)) as v; intros.
      rewrite <- assocax.
      rewrite sequenceProduct_append.
      apply (maponpaths (λ u, u*w)).
      apply IHm. } }
Defined.

