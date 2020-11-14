/*inicializa o tabuleiro com todas as posições vazias (estado inicial)*/
initial(Board):-
    Board = [[0,0,0],
            [0,0,0,0,0], 
         	[0,0,0,0,0,0,0],  
         	[0,0,0,0,0,0,0,0,0], 
         	[0,0,0,0,0,0,0,0,0],
            [0,0,0,0,0,0,0,0,0],
            [0,0,0,0,0,0,0],
            [0,0,0,0,0], 
            [0,0,0]],
            assert(playerPieces(blue,0)),
            assert(playerPieces(red,0)).

/*estado intermédio*/
intermediate_state(Board):-
    Board = [[0,0,0],
            [0,0,0,0,0], 
         	[1,0,0,1,2,0,0],  
         	[0,2,0,0,0,0,0,0,0], 
         	[0,0,2,0,0,0,0,0,0],
            [0,0,0,1,0,0,0,0,0],
            [1,0,0,0,2,0,0],
            [0,0,0,0,0], 
            [0,2,0]].

/*estado final)*/
final_state(Board):-
    Board = [[1,1,2],
            [1,2,2,1,2], 
         	[1,1,2,2,2,1,1],  
         	[1,2,2,2,1,1,1,1,2], 
         	[1,2,1,1,2,1,1,1,2],
            [1,2,2,2,2,1,1,2,1],
            [1,2,1,2,1,1,2],
            [2,2,2,1,2], 
            [2,2,1]].
    

display_game(Board, Player):-
        nl, initial(Board), dbDrawBoard(Board).

dbDrawBoard(Board) :-
    write('  A   B   C   D   E   F   G   H   I'),nl,
	dbDrawLine(Board, 1).

/*para cada linha chama as funcoes responsaveis por desenhar as divisoes das linhas e as próprias linhas*/
/*e no fim de cada linha desenha o número correspondente e incrementa o número da linha chamando-se novamente até todas*/
/*as linhas estarem desenhadas*/
dbDrawLine([X|Xs], Row) :-
    dbDrawHLine(Row),
    dbDrawCell(X),
    write(' '),
    write(Row),
    NextRow is Row + 1,
    nl,
    dbDrawLine(Xs, NextRow).

/*quando a ultíma linha é desenhada desenha uma última divisão do tabuleiro*/
dbDrawLine([],_) :-
    dbDrawLastHLine.

/*desenha as divisões do tabuleiro e de cada linha do tabuleiro*/
dbDrawHLine(Row) :-
    (Row==4; Row==6; Row==5) -> write('+---+---+---+---+---+---+---+---+---+'),nl;
    (Row==7) -> write('+---+---+---+---+---+---+---+---+---+'),nl,write('    ');
    (Row==3) -> write('    +---+---+---+---+---+---+---+    '), nl, write('    ');
    (Row==8) -> write('    +---+---+---+---+---+---+---+    '), nl, write('        ');
    (Row==2) -> write('        +---+---+---+---+---+        '), nl, write('        ');
    (Row==9) -> write('        +---+---+---+---+---+        '), nl, write('            ');
    (Row==1) -> write('            +---+---+---+            '), nl, write('            ').

dbDrawLastHLine:-
    write('            +---+---+---+').

/*desenha cada célula e a sua divisão, conteúdo muda dependendo se a casa estiver vazia ou com uma peça*/
dbDrawCell([X|Xs]) :-
    write('|'), 
    X==0 -> write('   '), dbDrawCell(Xs);
    X==1 -> write(' A '), dbDrawCell(Xs);
    X==2 -> write(' V '), dbDrawCell(Xs).

/*desenha a ultima divisão de coluna de cada linha*/
dbDrawCell([]) :-
    write('|').

