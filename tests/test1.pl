#!/usr/bin/pl -q -G64m -L64m -t main -f none -s
%#!/usr/bin/pl -q -G64m -L64m -f none -s
%%  Top of logica.pl
% teste

/*
% Some simple test agents.
%
% To define an agent within the navigate.pl scenario, define:
%   init_agent
%   restart_agent
%   run_agent
%
% Currently set up to solve the wumpus world in Figure 6.2 of Russell and
% Norvig.  You can enforce generation of this world by changing the
% initialize(random,Percept) to initialize(fig62,Percept) in the
% navigate(Actions,Score,Time) procedure in file navigate.pl and then run
% navigate(Actions,Score,Time).
*/

// cpp comment

/*
 * initialize([Stench,Breeze,Glitter,Bump,Scream])
 * initialize([Fedor,Vento,Brilho,Trombada,Grito])
 * initialize([F,V,B,T,G])
 * goforward
 * turnright
 * turnleft
 * grab
 * climb
 * shoot
 */

:- load_files([wumpus1]).
:- module([file/2]).

init_agent.

restart_agent :- init_agent.

run_agent(Percepcao, Acao) :-
  cabeca_dura(Percepcao, Acao).

cabeca_dura(_,goforward).

/** \brief main
*/
main :- goal.

/** \brief cor is det
*/
cor(vermelho).
cor(azul).
cor(roxo).
cor(marrom).
cor(cinza).

goal :-
    resposta([cor(A), cor(B), cor(C), cor(D), cor(E)], RESP),
    RESP=[branco, branco, branco, branco, branco].

senha([vermelho, azul, roxo, marrom, cinza]).

resposta([A1, B1, C1, D1, E1], [A2, B2, C2, D2, E2]) :-
    senha([S1, S2, S3, S4, S5]),
    % comment inside conjunction
    contabranco([A1, B1, C1, D1, E1], [S1, S2, S3, S4, S5], RESPB),
    /* another comment inside conjunction */
    contapreto([A1, B1, C1, D1, E1], [S1, S2, S3, S4, S5], RESPP),
    append(RESPB, RESPP , Mtemp),
    Mtemp=[A2, B2, C2, D2, E2].


contabranco([A1 | Resto1], [S1 | Resto2], RESPB) :- contabranco(Resto1, Resto2, RESPB1), A1=S1.
#         append(Temp, [branco], RESPB),
