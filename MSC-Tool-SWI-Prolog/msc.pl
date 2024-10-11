
process_rel(X,Z) :- process_rel(X,Y), process_rel(Y,Z).

match(s(X,Y,Z), r(X,Y,Z)) :- event(s(X,Y,Z)), event(r(X,Y,Z)).

rel2(X,Y) :- process_rel(X,Y).
rel2(X,Y) :- match(X,Y).

rel(X, Z) :- rel2(X, Y), rel2(Y, Z).

rel(X, Y, [(X,Y)]) :- rel2(X, Y).
rel(X, Z, [(X,Z)|A]) :- rel(X, Y, A), rel2(Y, Z), \+memberchk((X, Z), A).

%---ASY---

asy(A) :- rel(X,X,A).

%---P2P---
cond_err_pp(s(X,Y,M1), s(X,Y,M2)) :- match(s(X,Y,M1), R1), match(s(X,Y,M2), R2), process_rel(R2,R1), !.
cond_err_pp(S1, S2) :- \+match(S1, _), match(S2, _), !.

err_pp(M1, M2) :- event(s(X,Y,M1)), event(s(X,Y,M2)), M1\=M2, process_rel(s(X,Y,M1), s(X,Y,M2)), cond_err_pp(s(X,Y,M1),s(X,Y,M2)).

pp([M1, M2]) :- err_pp(M1, M2).

%---CO---

cond_err_co(s(X,Y,M1), s(Z,Y,M2)) :- match(s(X,Y,M1), R1), match(s(Z,Y,M2), R2), process_rel(R2,R1), !.
cond_err_co(S1, S2) :- \+match(S1, _), match(S2, _), !.

err_co(M1,M2) :- event(s(X,Y,M1)), event(s(Z,Y,M2)), M1\=M2, rel(s(X,Y,M1), s(Z,Y,M2)), cond_err_co(s(X,Y,M1),s(Z,Y,M2)).

co([M1,M2]) :- err_co(M1,M2).

%---MB---

mb_rel(s(X,Y,M1),s(Z,Y,M2)) :- match(s(X,Y,M1),_), \+match(s(Z,Y,M2),_), M1\=M2.
mb_rel(s(X,Y,M1),s(Z,Y,M2)) :- match(s(X,Y,M1), R1), match(s(Z,Y,M2), R2), M1\=M2, process_rel(R1, R2).


mb_order2(X,Y) :- rel2(X,Y).
mb_order2(X,Y) :- mb_rel(X,Y).

mb_order(X, Y, [(X,Y)]) :- mb_order2(X, Y).
mb_order(X, Z, [(X,Z)|A]) :- mb_order(X, Y, A), mb_order2(Y, Z), \+memberchk((X, Z), A).

mb(A) :- mb_order(X,X, A).

%---1-N---

onen_rel(s(X,Y,M1),s(X,Z,M2)) :- match(s(X,Y,M1),_), \+match(s(X,Z,M2),_).
onen_rel(r(X,Y,M1),r(X,Z,M2)) :- match(S1, r(X,Y,M1)), match(S2, r(X,Z,M2)), process_rel(S1, S2).

onen_order2(X,Y) :- rel2(X,Y).
onen_order2(X,Y) :- onen_rel(X,Y).

onen_order(X, Y, [(X,Y)]) :- onen_order2(X, Y).
onen_order(X, Z, [(X,Z)|A]) :- onen_order(X, Y, A), onen_order2(Y, Z), \+memberchk((X, Z), A).


onen(A) :- onen_order(X, X, A).

%---N-N---

onen_mb_order2(X,Y) :- rel2(X,Y).
onen_mb_order2(X,Y) :- mb_rel(X,Y).
onen_mb_order2(X,Y) :- onen_rel(X,Y).

onen_mb_order(X, Z) :- onen_mb_order2(X, Y), onen_mb_order2(Y, Z).

nn_rel2(X,Y) :- onen_mb_order2(X,Y).

nn_rel2(r(X,Y,M1), r(Z,N,M2)) :- match(S1, r(X,Y,M1)), match(S2, r(Z,N,M2)), M1\=M2, onen_mb_order(S1, S2), \+onen_mb_order(r(X,Y,M1),r(Z,N,M2)).

nn_rel2(s(X,Y,M1), s(Z,N,M2)) :- match(s(X,Y,M1), R1), match(s(Z,N,M2), R2), M1\=M2, onen_mb_order(R1, R2), \+onen_mb_order(s(X,Y,M1),s(Z,N,M2)).

nn_rel2(s(X,Y,M1),s(Z,N,M2)) :- match(s(X,Y,M1),_), \+match(s(Z,N,M2),_), M1\=M2, \+onen_mb_order(s(X,Y,M1),s(Z,N,M2)).
nn_rel2(r(X,Y,M1),s(Z,N,M2)) :- match(_,r(X,Y,M1)), \+match(s(Z,N,M2),_), M1\=M2, \+onen_mb_order(r(X,Y,M1),s(Z,N,M2)).


nn_rel(X, Y, [(X,Y)]) :- nn_rel2(X, Y).
nn_rel(X, Z, [(X,Z)|A]) :- nn_rel(X, Y, A), nn_rel2(Y, Z), \+memberchk((X, Z), A).

nn(A) :- nn_rel(X, X, A).

%---RSC---

crown_rel(s(X,Y,M1), s(Z,N,M2)) :- event(s(X,Y,M1)), match(s(Z,N,M2), R2), M1\=M2, rel(s(X,Y,M1), R2).

crown_rel_transitive(X, Y, [(X,Y)]) :- crown_rel(X, Y).
crown_rel_transitive(X, Z, [(X,Z)|A]) :- crown_rel_transitive(X, Y, A), crown_rel(Y, Z), \+memberchk((X, Z), A).


unmatch(s(X,Y,M)) :- event(s(X,Y,M)), \+match(s(X,Y,M),_), !.

rsc(A) :- crown_rel_transitive(X, X, A).
rsc(A) :- unmatch(A).