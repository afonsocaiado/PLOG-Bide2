:-use_module(library(clpfd)).
:-use_module(library(lists)).

problema_modelo(Pedidos, TempoEntreCasas, TempoPadariaCasas):-
    Pedidos = [10, 50, 47, 33, 65], 
    TempoEntreCasas = [[0, 3, 15, 10, 5], [3, 0, 12, 25, 8], [15, 12, 0, 5, 9], [10, 25, 5, 0, 10],[5, 8, 9, 10, 0]],
    TempoPadariaCasas = [10, 5, 10, 15, 8].

problema_modelo6(Pedidos, TempoEntreCasas, TempoPadariaCasas):-
    Pedidos = [10, 50, 47, 33, 65,88], 
    TempoEntreCasas = [[0, 3, 15, 10, 5,5], [3, 0, 12, 25, 8,10], [15, 12, 0, 5, 9,16], [10, 25, 5, 0, 10,12],[5, 8, 9, 10, 0,3],[5,10,16,12,3,0]],
    TempoPadariaCasas = [10, 5, 10, 15, 8, 11].

problema_modelo10(Pedidos, TempoEntreCasas, TempoPadariaCasas):-
    Pedidos = [10, 50, 47, 33, 65, 88, 90, 40, 77, 100], 
    TempoEntreCasas = [[0, 3, 15, 10, 5, 5,5,18,11,3], [3, 0, 12, 25, 8,10,10,5,30,25], [15, 12, 0, 5, 9,16,15,14,10,19], [10, 25, 5, 0, 10,12,20,4,13,12],[5, 8, 9, 10, 0,3,15,10,2,21],[5,10,16,12,3,0,20,22,8,9],[5,10,15,20,15,20,0,11,19,15],[18,5,14,4,10,22,11,0,15,10],[11,30,10,13,2,8,19,15,0,10],[3,25,19,12,21,9,15,10,10,0]],
    TempoPadariaCasas = [10, 5, 10, 15, 8, 11, 20, 11, 18, 22, 6].

padeiro:-
    problema_modelo(Pedidos, TempoEntreCasas, TempoPadariaCasas),
    problem(Pedidos, TempoEntreCasas, TempoPadariaCasas).

problem(HorarioPreferido, TempoEntreCasas, TempoPadariaCasas):-
    
    printProblem(HorarioPreferido, TempoEntreCasas, TempoPadariaCasas),

    getLengths(HorarioPreferido, Caminho, MomentoEntrega, NumeroCasas),

    declareVars(Caminho, MomentoEntrega, NumeroCasas),

    restrictDistinctValues(Caminho, MomentoEntrega),

    restrictApenasUmaPassagemPorCasa(Caminho, TempoPadariaCasas, MomentoEntrega),

    restrictTempoEntreCasas(TempoEntreCasas, ListaTemposViagem, HorarioPreferido, MomentoEntrega, Atraso, NumeroCasas, Caminho),

    restrictionTempoFinal(NumeroCasas, Caminho, TempoPadariaCasas, MomentoEntrega, TempoTotal),

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

restrictApenasUmaPassagemPorCasa(Caminho,TempoPadariaCasas,MomentoEntrega):-
    element(1, Caminho, IDPrimeiraCasa),
    element(IDPrimeiraCasa, TempoPadariaCasas, TempoPadariaPrimeira),
    element(1, MomentoEntrega, TempoPadariaPrimeira)
.

restrictTempoEntreCasas(TempoEntreCasas,ListaTemposViagem,HorarioPreferido, MomentoEntrega, Atraso, NumeroCasas, Caminho):-
    append(TempoEntreCasas, ListaTemposViagem),
    calcularTempos(HorarioPreferido, ListaTemposViagem, Caminho, MomentoEntrega, Atraso, NumeroCasas)
.

restrictionTempoFinal(NumeroCasas,Caminho,TempoPadariaCasas,MomentoEntrega,TempoTotal):-
    element(NumeroCasas, Caminho, IDUltimaCasa),
    element(IDUltimaCasa, TempoPadariaCasas, TempoTotal)
.

calcularAtraso(TempoEntregaPreferido, TempoDaEntrega, TempoDaEntrega, Atraso):-
    Atraso is 0,
    TempoDaEntrega #>= TempoEntregaPreferido - 40,
    TempoDaEntrega #=< TempoEntregaPreferido - 10.
calcularAtraso(TempoEntregaPreferido, TempoDaEntrega, TempoDaEntrega, Atraso):-
    GetToHouseTime #> TempoEntregaPreferido - 10,
    Atraso #= TempoDaEntrega - TempoEntregaPreferido.
calcularAtraso(TempoEntregaPreferido, TempoCasa, _, Atraso):-
    Atraso is 0,
    TimeAtHouse #= TempoEntregaPreferido - 10.

calcularTempos(HorarioPreferido, ListaTemposViagem, [CasaAnterior, Casa], [TempoCasaAnterior, TempoCasa], Atraso, NumeroCasas):-
    Pos #= Casa + NumeroCasas * (CasaAnterior - 1),
    element(Pos, ListaTemposViagem, TempoEntreCasas),
    TempoDaEntrega #= TempoEntreCasas + (TempoCasaAnterior + 5),
    element(Casa, HorarioPreferido, TempoEntregaPreferido),

    calcularAtraso(TempoEntregaPreferido, TempoCasa, TempoDaEntrega, Atraso)
.
calcularTempos(HorarioPreferido, ListaTemposViagem, [CasaAnterior, Casa|RestoCasas], [TempoCasaAnterior, TempoCasa | RestoTemposCasas], Atraso, NumeroCasas):- 
    
    Pos #= Casa + NumeroCasas * (CasaAnterior - 1),
    element(Pos, ListaTemposViagem, TempoEntreCasas),
    TempoDaEntrega #= TempoEntreCasas + (TempoCasaAnterior + 5),
    element(Casa, HorarioPreferido, TempoEntregaPreferido),

    calcularAtraso(TempoEntregaPreferido, TempoCasa, TempoDaEntrega, AtrasoAtual),

    Atraso #= AtrasoAtual + NovoAtraso,

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
