:-use_module(library(clpfd)).
:-use_module(library(lists)).

padeiro:-
    problem([10, 50, 47, 33], [[0, 3, 15, 10], [3, 0, 12, 25], [15, 12, 0, 5], [10, 25, 5, 0]], [10, 5, 10, 15]).

problem(HorarioPreferido, TempoEntreCasas, TempoPadariaCasas):-
    
    printProblem(HorarioPreferido, TempoEntreCasas, TempoPadariaCasas),

    getLengths(HorarioPreferido, Caminho, MomentoEntrega, NumeroCasas),

    declareVars(Caminho, MomentoEntrega, NumeroCasas),

    restriction1(Caminho, MomentoEntrega),

    restriction2(Caminho, TempoPadariaCasas, MomentoEntrega),

    restriction3(TempoEntreCasas, ListaTemposViagem, HorarioPreferido, MomentoEntrega, Atraso, NumeroCasas, Caminho),

    restriction4(NumeroCasas, Caminho, TempoPadariaCasas, MomentoEntrega, TempoTotal),

    evaluateRoute(TempoTotal, Atraso, Score),

    labeling([minimize(Score)], Caminho),

    printSolution(Caminho, MomentoEntrega)
.


printProblem(HorarioPreferido, TempoEntreCasas, TempoPadariaCasas):-
    write('HorarioPreferido = '),
    write(HorarioPreferido),
    write('\n'),
    write('TempoEntreCasas = '),
    write(TempoEntreCasas),
    write('\n'),
    write('TempoPadariaCasas = '),
    write(TempoPadariaCasas),
    write('\n')
.

getLengths(HorarioPreferido,Caminho,MomentoEntrega,NumeroCasas):-
    
    length(HorarioPreferido, NumeroCasas),

    length(Caminho, NumeroCasas),
    length(MomentoEntrega, NumeroCasas)
.

declareVars(Caminho,MomentoEntrega,NumeroCasas):-

    domain(Caminho, 1, NumeroCasas),
    domain(MomentoEntrega, 1, 100000)
.

restriction1(Caminho,MomentoEntrega):-
    all_distinct(Caminho),
    all_distinct(MomentoEntrega)
.

restriction2(Caminho,TempoPadariaCasas,MomentoEntrega):-
    element(1, Caminho, IDPrimeiraCasa),
    element(IDPrimeiraCasa, TempoPadariaCasas, TempoPadariaPrimeira),
    element(1, MomentoEntrega, TempoPadariaPrimeira)
.

restriction3(TempoEntreCasas,ListaTemposViagem,HorarioPreferido, MomentoEntrega, Atraso, NumeroCasas, Caminho):-
    append(TempoEntreCasas, ListaTemposViagem),
    getRouteTime(Caminho, ListaTemposViagem, HorarioPreferido, MomentoEntrega, Atraso, NumeroCasas)
.

restriction4(NumeroCasas,Caminho,TempoPadariaCasas,MomentoEntrega,TempoTotal):-
    element(NumeroCasas, Caminho, IDUltimaCasa),
    element(IDUltimaCasa, TempoPadariaCasas, TempoUltimaPadaria),
    element(NumeroCasas, MomentoEntrega, UltimoMomento),
    TempoTotal #= UltimoMomento + TempoUltimaPadaria
.

getRouteTime([CasaAnterior, Casa], ListaTemposViagem, HorarioPreferido, [TempoCasaAnterior, TempoCasa], Atraso, NumeroCasas):-
    Position #= (CasaAnterior - 1) * NumeroCasas + Casa,
    element(Position, ListaTemposViagem, TempoEntreCasas),
    TempoCasa #= (TempoCasaAnterior + 5) + TempoEntreCasas,

    
    element(Casa, HorarioPreferido, TempoEntrega),
    AtrasoSign #= TempoCasa - TempoEntrega - 40,
    convertDelay(AtrasoSign, Atraso)
.

getRouteTime([CasaAnterior, Casa|Rest], ListaTemposViagem, HorarioPreferido, [TempoCasaAnterior, TempoCasa | RestTime], Atraso, NumeroCasas):- 
    
    Position #= (CasaAnterior - 1) * NumeroCasas + Casa,
    element(Position, ListaTemposViagem, TempoEntreCasas),
    TempoCasa #= TempoEntreCasas + (TempoCasaAnterior + 5),

    % Get Delay
    element(Casa, HorarioPreferido, TempoEntrega),
    AtrasoSign #= TempoCasa - TempoEntrega - 40,
    convertDelay(AtrasoSign, AtrasoUnsign),
    Atraso #= AtrasoUnsign + NewDelay,

    getRouteTime([Casa|Rest], ListaTemposViagem, HorarioPreferido, [TempoCasa | RestTime], NewDelay, NumeroCasas)
.

evaluateRoute(TempoTotal, Atraso, Score):-
    Score #= TempoTotal + Atraso
.

convertDelay(AtrasoSign, AtrasoUnsign):-
    AtrasoSign #< 0,
    AtrasoUnsign #= AtrasoSign * -1
.

convertDelay(AtrasoSign, AtrasoSign).

printSolution([], []).
printSolution(Caminho, MomentoEntrega):-
    write('\n  Caminho  \n'),
    displayRoute(Caminho),
    displayHeader,
    displayTableContent(Caminho, MomentoEntrega)
.

displayHeader:-
    nl,
    write('House  Instants'),
    nl
.

displayRoute([House|[]]):-
    write(House),
    nl
.

displayRoute([House|Rest]):- 
    write(House),
    write(' ---> '),
    displayRoute(Rest)
.

displayTableContent([],[]).
displayTableContent([House|Rest], [TempoTotal|RestTime]):-
    write('   '),
    write(House),
    write(' --> '),
    write(TempoTotal),
    nl,
    displayTableContent(Rest, RestTime)
.