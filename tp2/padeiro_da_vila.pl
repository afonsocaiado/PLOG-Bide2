:-use_module(library(clpfd)).
:-use_module(library(lists)).

problema_modelo(Pedidos, TempoEntreCasas, TempoPadariaCasas):-
    Pedidos = [10, 50, 47, 33], 
    TempoEntreCasas = [[0, 3, 15, 10], [3, 0, 12, 25], [15, 12, 0, 5], [10, 25, 5, 0]],
    TempoPadariaCasas = [10, 5, 10, 15].

padeiro:-
    problema_modelo(Pedidos, TempoEntreCasas, TempoPadariaCasas),
    problem(Pedidos, TempoEntreCasas, TempoPadariaCasas).

problem(HorarioPreferido, TempoEntreCasas, TempoPadariaCasas):-
    
    printProblem(HorarioPreferido, TempoEntreCasas, TempoPadariaCasas),

    getLengths(HorarioPreferido, Caminho, MomentoEntrega, NumeroCasas),

    declareVars(Caminho, MomentoEntrega, NumeroCasas),

    restrictDistinctValues(Caminho, MomentoEntrega),

    restriction2(Caminho, TempoPadariaCasas, MomentoEntrega),

    restriction3(TempoEntreCasas, ListaTemposViagem, HorarioPreferido, MomentoEntrega, Atraso, NumeroCasas, Caminho),

    restriction4(NumeroCasas, Caminho, TempoPadariaCasas, MomentoEntrega, TempoTotal),

    calculoDeTempoParaMinimizacao(TempoTotal, Atraso, Score),

    labeling([minimize(Score)], Caminho),

    printSolution(Caminho, MomentoEntrega, Atraso, Score)
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
    domain(MomentoEntrega, 1, 1440)
.

restrictDistinctValues(Caminho,MomentoEntrega):-
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
    calcularTempos(HorarioPreferido, ListaTemposViagem, Caminho, MomentoEntrega, Atraso, NumeroCasas)
.

restriction4(NumeroCasas,Caminho,TempoPadariaCasas,MomentoEntrega,TempoTotal):-
    element(NumeroCasas, Caminho, IDUltimaCasa),
    element(IDUltimaCasa, TempoPadariaCasas, TempoUltimaPadaria),
    element(NumeroCasas, MomentoEntrega, UltimoMomento),
    TempoTotal #= UltimoMomento + TempoUltimaPadaria
.

calcularTempos(HorarioPreferido, ListaTemposViagem, [CasaAnterior, Casa], [TempoCasaAnterior, TempoCasa], Atraso, NumeroCasas):-
    Pos #= Casa + NumeroCasas * (CasaAnterior - 1),
    element(Pos, ListaTemposViagem, TempoEntreCasas),
    TempoCasa #= TempoEntreCasas + (TempoCasaAnterior + 5),
    element(Casa, HorarioPreferido, TempoEntrega),
    AtrasoCalculo #= 40 - TempoCasa - TempoEntrega,
    AtrasoCalculo #< 0,
    Atraso #= AtrasoCalculo * -1
    %convertDelay(AtrasoCalculo, Atraso)
.

calcularTempos(HorarioPreferido, ListaTemposViagem, [CasaAnterior, Casa|RestoCasas], [TempoCasaAnterior, TempoCasa | RestoTemposCasas], Atraso, NumeroCasas):- 
    
    Pos #= Casa + NumeroCasas * (CasaAnterior - 1),
    element(Pos, ListaTemposViagem, TempoEntreCasas),
    TempoCasa #= TempoEntreCasas + (TempoCasaAnterior + 5),
    element(Casa, HorarioPreferido, TempoEntrega),
    AtrasoCalculo #= 40 - TempoCasa - TempoEntrega,
    AtrasoCalculo #< 0,
    AtrasoAbs #= AtrasoCalculo * -1,
    %convertDelay(AtrasoCalculo, AtrasoAbs),
    Atraso #= AtrasoAbs + NovoAtraso,

    calcularTempos(HorarioPreferido, ListaTemposViagem, [Casa|RestoCasas], [TempoCasa | RestoTemposCasas], NovoAtraso, NumeroCasas)
.

calculoDeTempoParaMinimizacao(TempoTotal, Atraso, Valor):-
    Valor #= TempoTotal + Atraso
.


%printSolution([], []).
printSolution(Caminho, MomentoEntrega, Atraso, Score):-
    nl,
    write('Caminho: '),
    write(Caminho),
    nl,
    write('Momento de Entrega: '),
    write(MomentoEntrega),
    nl,
    write('Atraso: '), 
    write(Atraso),
    nl,
    write('Score: '),
    write(Score).
