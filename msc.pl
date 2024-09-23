%----------pas asy
/*
event(s(p, q, m1)).
event(s(q, p, m2)).
event(r(p, q, m1)).
event(r(q, p, m2)).

process_rel(r(p,q,m1), s(q,p,m2)).
process_rel(r(q,p,m2), s(p,q,m1)).
*/
%----------asy, pas p2p.

event(s(p, q, m1)).
event(s(q, p, m2)).
event(s(p, q, m3)).
event(r(p, q, m1)).
event(r(q, p, m2)).
event(r(p, q, m3)).

process_rel(r(p,q,m1), s(q,p,m2)).
process_rel(s(q,p,m2), r(p,q,m3)).
process_rel(s(p,q,m3), s(p,q,m1)).
process_rel(s(p,q,m1), r(q,p,m2)).

%----------p2p, pas co.
/*
event(s(p, q, m1)).
event(s(q, r, m2)).
event(s(p, r, m3)).
event(r(p, q, m1)).
event(r(q, r, m2)).
event(r(p, r, m3)).

process_rel(s(_,_,m3), s(_,_,m1)).
process_rel(r(_,_,m1), s(_,_,m2)).
process_rel(r(_,_,m2), r(_,_,m3)).
*/
%----------co pas mb.
/*
event(s(p, q, m1)).
event(s(p, r, m2)).
event(s(p, s, m3)).
event(s(s, r, m4)).
event(s(s, q, m5)).
event(r(p, q, m1)).
event(r(p, r, m2)).
event(r(p, s, m3)).
event(r(s, r, m4)).
event(r(s, q, m5)).

process_rel(s(p,q,m1), s(p,r,m2)).
process_rel(s(p,r,m2), s(p,s,m3)).
process_rel(s(s,r,m4), s(s,q,m5)).
process_rel(r(s,q,m5), r(p,q,m1)).
process_rel(r(p,r,m2), r(s,r,m4)).
process_rel(s(s,q,m5), r(p,s,m3)).
*/
%----------mb pas 1-n
/*
event(s(p,q,m1)).
event(s(p,r,m2)).
event(r(p,r,m2)).
process_rel(s(p,q,m1), s(p,r,m2)).
*/
%----------1-n pas nn
/*
event(s(p,s,m1)).
event(s(p,q,m2)).
event(s(q,r,m3)).
event(s(s,r,m4)).
event(r(p,s,m1)).
event(r(p,q,m2)).
event(r(q,r,m3)).
event(r(s,r,m4)).

process_rel(s(p,s,m1), s(p,q,m2)).
process_rel(r(p,q,m2), s(q,r,m3)).
process_rel(r(q,r,m3), r(s,r,m4)).
process_rel(s(s,r,m4), r(p,s,m1)).
*/
%----------nn pas rsc
/*
event(s(p,r,m1)).
event(s(p,q,m2)).
event(s(r,q,m3)).
event(r(p,r,m1)).
event(r(p,q,m2)).
event(r(r,q,m3)).

process_rel(s(p,r,m1), s(p,q,m2)).
process_rel(r(p,q,m2), r(r,q,m3)).
process_rel(s(r,q,m3), r(p,r,m1)).
*/
%-----------rsc
/*
event(s(q,r,m2)).
event(s(r,q,m3)).
event(r(q,r,m2)).
event(r(r,q,m3)).

process_rel(s(q,r,m2), r(r,q,m3)).
process_rel(r(q,r,m2), s(r,q,m3)).
*/
/*
event(s(p,q,m1)).
event(s(p,q,m2)).
event(r(p,q,m1)).
process_rel(_,_) :- fail.
*/
/*
event(s(p,q,m)).
event(r(_,_,_)) :- fail.
process_rel(_,_) :- fail.
*/
/*
event(s(p,q,m1)).
event(s(p,q,m2)).
event(s(p,q,m3)).
event(s(p,q,m4)).
event(r(p,q,m1)).
event(r(p,q,m2)).
event(r(p,q,m3)).
event(r(p,q,m4)).

process_rel(s(p,q,m1),s(p,q,m2)).
process_rel(s(p,q,m2),s(p,q,m3)).
process_rel(s(p,q,m3),s(p,q,m4)).
process_rel(r(p,q,m1),r(p,q,m2)).
process_rel(r(p,q,m2),r(p,q,m3)).
process_rel(r(p,q,m3),r(p,q,m4)).
*/

member_check(E, [E|_]) :- !.
member_check(E, [H|T]) :- member_check(E,T), E\=H.

process_relation(X,Y) :- process_rel(X,Y).
process_relation(X,Z) :- process_rel(X,Y), process_relation(Y,Z).
match(s(X,Y,Z), r(X,Y,Z)) :- event(s(X,Y,Z)), event(r(X,Y,Z)).
rel2(X,Y) :- process_relation(X,Y).
rel2(X,Y) :- match(X,Y).

rel(X, Y) :- rel(X, Y, []).
rel(X, Y, A) :- rel2(X, Y), \+ member_check((X, Y), A).
rel(X, Y, A) :- rel2(X, Z), \+ member_check((X, Z), A), rel(Z, Y, [(X,Z)|A]).

%---ASY---
cycle :- rel(X,X).

asy :- \+cycle.

%---P2P---
cond_err_p2p(s(X,Y,M1), s(X,Y,M2)) :- match(s(X,Y,M1), R1), match(s(X,Y,M2), R2), process_relation(R2,R1), !.
cond_err_p2p(S1, S2) :- \+match(S1, _), match(S2, _), !.
cond_err_p2p(_,_) :- !, fail.

err_p2p :- event(s(X,Y,M1)), event(s(X,Y,M2)), M1\=M2, process_relation(s(X,Y,M1), s(X,Y,M2)), cond_err_p2p(s(X,Y,M1),s(X,Y,M2)).

p2p :- asy,\+err_p2p.

%---CO---

cond_err_co(s(X,Y,M1), s(Z,Y,M2)) :- match(s(X,Y,M1), R1), match(s(Z,Y,M2), R2), process_relation(R2,R1), !.
cond_err_co(S1, S2) :- \+match(S1, _), match(S2, _), !.
cond_err_co(_,_) :- !, fail.

err_co :- event(s(X,Y,M1)), event(s(Z,Y,M2)), M1\=M2, rel(s(X,Y,M1), s(Z,Y,M2)), cond_err_co(s(X,Y,M1),s(Z,Y,M2)).

co :- asy,\+err_co.

%---MB---

mb_rel(s(X,Y,M1),s(Z,Y,M2)) :- match(s(X,Y,M1),_), \+match(s(Z,Y,M2),_), M1\=M2.
mb_rel(s(X,Y,M1),s(Z,Y,M2)) :- match(s(X,Y,M1), R1), match(s(Z,Y,M2), R2), M1\=M2, process_relation(R1, R2).

mb_order2(X,Y) :- rel2(X,Y).
mb_order2(X,Y) :- mb_rel(X,Y).
mb_order(X, Y) :- mb_order(X, Y, []).
mb_order(X, Y, A) :- mb_order2(X, Y), \+ member_check((X, Y), A).
mb_order(X, Y, A) :- mb_order2(X, Z), \+ member_check((X, Z), A), mb_order(Z, Y, [(X,Z)|A]).

err_mb :- mb_order(X,X).

mb :- asy, \+err_mb.

%---1-N---

onen_rel(s(X,Y,M1),s(X,Z,M2)) :- match(s(X,Y,M1),_), \+match(s(X,Z,M2),_).
onen_rel(r(X,Y,M1),r(X,Z,M2)) :- match(S1, r(X,Y,M1)), match(S2, r(X,Z,M2)), process_relation(S1, S2).

onen_order2(X,Y) :- rel2(X,Y).
onen_order2(X,Y) :- onen_rel(X,Y).
onen_order(X, Y) :- onen_order(X, Y, []).
onen_order(X, Y, A) :- onen_order2(X, Y), \+member_check((X, Y), A).
onen_order(X, Y, A) :- onen_order2(X, Z), \+member_check((X, Z), A), onen_order(Z, Y, [(X,Z)|A]).


err_onen :- onen_order(X,X).

onen :- asy, \+err_onen.

%---N-N---

onen_mb_order2(X,Y) :- rel2(X,Y).
onen_mb_order2(X,Y) :- mb_rel(X,Y).
onen_mb_order2(X,Y) :- onen_rel(X,Y).
onen_mb_order(X, Y) :- onen_mb_order(X, Y, []).
onen_mb_order(X, Y, A) :- onen_mb_order2(X, Y), \+member_check((X, Y), A).
onen_mb_order(X, Y, A) :- onen_mb_order2(X, Z), \+member_check((X, Z), A), onen_mb_order(Z, Y, [(X,Z)|A]).

nn_rel2(X,Y) :- onen_mb_order2(X,Y).

nn_rel2(r(X,Y,M1), r(Z,N,M2)) :- match(S1, r(X,Y,M1)), match(S2, r(Z,N,M2)), M1\=M2, onen_mb_order(S1, S2), \+onen_mb_order(r(X,Y,M1),r(Z,N,M2)).

nn_rel2(s(X,Y,M1), s(Z,N,M2)) :- match(s(X,Y,M1), R1), match(s(Z,N,M2), R2), M1\=M2, onen_mb_order(R1, R2), \+onen_mb_order(s(X,Y,M1),s(Z,N,M2)).

nn_rel2(s(X,Y,M1),s(Z,N,M2)) :- match(s(X,Y,M1),_), \+match(s(Z,N,M2),_), M1\=M2, \+onen_mb_order(s(X,Y,M1),s(Z,N,M2)).
nn_rel2(r(X,Y,M1),s(Z,N,M2)) :- match(_,r(X,Y,M1)), \+match(s(Z,N,M2),_), M1\=M2, \+onen_mb_order(r(X,Y,M1),s(Z,N,M2)).


nn_rel(X, Y) :- nn_rel(X, Y, []).
nn_rel(X, Y, A) :- nn_rel2(X, Y), \+ member_check((X, Y), A).
nn_rel(X, Y, A) :- nn_rel2(X, Z), \+ member_check((X, Z), A), nn_rel(Z, Y, [(X,Z)|A]).

err_nn :- nn_rel(X,X).

nn :- asy, \+err_nn.

%---RSC---

crown_rel(s(X,Y,M1), s(Z,N,M2)) :- match(s(Z,N,M2), R2), rel(s(X,Y,M1), R2).

crown_rel_transitive(X, Y) :- crown_rel_transitive(X, Y, []).
crown_rel_transitive(X, Y, A) :- crown_rel(X, Y), \+ member_check((X, Y), A).
crown_rel_transitive(X, Y, A) :- crown_rel(X, Z), \+ member_check((X, Z), A), crown_rel_transitive(Z, Y, [(X,Z)|A]).

crown :- crown_rel_transitive(X,X).

unmatch(s(X,Y,M)) :- event(s(X,Y,M)), \+match(s(X,Y,M),_), !.
unmatch(_) :- fail.

rsc :- \+crown, \+unmatch(_).