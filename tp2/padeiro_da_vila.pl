:-use_module(library(clpfd)).
:-use_module(library(lists)).

solve:-
    padeiro_da_vila([85, 98, 60, 70], [[0, 3, 14, 1], [15, 0, 10, 25], [14, 10, 0, 3], [1, 25, 3, 0]], [10, 5, 20, 15])
.

padeiro_da_vila(TempoPreferidoCadaCasa,TempoEntreCasas,TempoPadariaCasas):-
    length(TempoPreferidoCadaCasa,NumeroCasas),
    length(Rota, NumeroCasas),
    length(MomentoEntrega,NumeroCasas),
    
    domain(Rota,1,NumeroCasas),
    domain(MomentoEntrega,1,100000),
.