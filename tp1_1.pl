/*state(Board,Player,Score) a modificar conforme criterios de discussao*/
/*ideia- mudar o board para um termo de listas para cada linha i.e. tab(1//[0,0,0], 2//[0,0,0,0,0].....)*/
/* fazer um predicado para retornar o valor de cada casa para se utilizar durante o jogo*/
/*guardar o número de peças que cada jogador tem guardadas a espera de jogar(com o bide)*/
/*usar operações como factos i.e.:- place(casa, jogador)  bide(jogador,Npecas)*/
:-use_module(library(lists)).
player(red).
player(blue).
other_player(red, blue).
other_player(blue, red).
playerValue(blue,1).
playerValue(red,2).
/*score positivo jogador 1 esta a ganhar e negativo o jogador 2 esta a ganhar*/
%game_state(Board, Player, Score).

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
            [0,0,0]].

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
    

/*----------------------- Board Drawing Predicates ----------------------*/

display_game(Board, Score):-
        nl, dbDrawBoard(Board).

dbDrawBoard(Board) :-
    write('  1   2   3   4   5   6   7   8   9'),nl,
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

/*draws each line division of the board*/
dbDrawHLine(Row) :-
    (Row==4; Row==6; Row==5) -> write('+---+---+---+---+---+---+---+---+---+'),nl;
    (Row==7) -> write('+---+---+---+---+---+---+---+---+---+'),nl,write('    ');
    (Row==3) -> write('    +---+---+---+---+---+---+---+    '), nl, write('    ');
    (Row==8) -> write('    +---+---+---+---+---+---+---+    '), nl, write('        ');
    (Row==2) -> write('        +---+---+---+---+---+        '), nl, write('        ');
    (Row==9) -> write('        +---+---+---+---+---+        '), nl, write('            ');
    (Row==1) -> write('            +---+---+---+            '), nl, write('            ').

dbDrawLastHLine:-
    write('            +---+---+---+\n').

/*draws each cell and its division, content of the cell changes if the cell has a piece in it*/
dbDrawCell([X|Xs]) :-
    write('|'), 
    X==0 -> write('   '), dbDrawCell(Xs);
    X==1 -> write(' B '), dbDrawCell(Xs);
    X==2 -> write(' R '), dbDrawCell(Xs).

/*draws the last column division for each line*/
dbDrawCell([]) :-
    write('|').


/*-------------------------- Basic Game Mechanisms --------------------------------*/
    
game(Side, Board1, Score):-
        other_player(Side, OtherSide),
        display_game(Board1,Score),
        %can_move(OtherSide, Board1),
        player_input_move_type(Side, Board1, Board2),
        write('\n'), write(Side), write(' moving:\n'),
        display_game(Board2,Score),
        %can_move(OtherSide, Board2),
        %smart_move(OtherSide, Board2, Board3),
        player_input_move_type(OtherSide, Board2, Board3),
        write('\n'), write(OtherSide), write(' moving:\n'),
        display_game(Board3,Score),
        game(Side, Board3,Score).


play:- 
    player_select_side(Player),
    initial(Board),
    game(Player, Board, 0).


/* -----------player input --------------*/

/*reads the side the player wants to be on (red or blue) and validates input*/
player_select_side(Player) :-
    write('Select your side (red/blue): '),
    read(Player_Side),
    (
        (player(Player_Side), Player = Player_Side, !);
        (write('Invalid side, please type \'red.\' or \'blue.\'\n'), player_select_side(Player))
    ).

/*reads the type of move the player wanta to execute and validates it*/
player_input_move_type(Side, Board1, Board2):-
        write('Do you want to play, bide, or release? (p / b / r)'),
        read(MoveType),
        (MoveType = 'p' -> player_input_move(Side, Board1, Board2), !);
        (MoveType = 'b' -> player_bide, !);
        (MoveType = 'r' -> player_release, !);
        (MoveType \= 'p', MoveType \= 'b', MoveType \= 'r') -> (write('Invalid character, please type \'p.\' or \'b.\' or \'r\' \n')), player_input_move_type(Side, Board1, Board2).

/*reads the position the player wants to place a piece on and calls fucntions to validate if the position is legal*/
player_input_move(Side, Board, NewBoard):- 
    write('Choose where to move: (X-Y)'),
    read(X-Y),
    (
        valid_move(X,Y,Board);
        (write('Invalid position. Retry: '), player_input_move(Side, Board, NewBoard))
    ), 
    place_piece(Side,Board,NewBoard,X,Y).

/*----------------------------- Movement Validations ---------------------------------*/

/*checks if a movement selected by a player is valid*/
valid_move(X,Y,Board):-
        inside_board(X,Y),
        pos_is_empty(Board,X,Y,0).

/*checks if the position chosen is inside the board*/
inside_board(X,Y):-
        ((X==1; X==9), (Y>3,Y<7));
        ((X==2; X==8), (Y>2,Y<8));
        ((X==3; X==7), (Y>1,Y<9));
        ((X>3; X<7), (Y>0,Y<10)).

/*checks if the position chosen is empty*/
pos_is_empty(Board,X,Y,E) :-
    X1 is X-1,
    (
        (X<4; X>6) -> Y1 is Y - 4;
        (X>3, X<7) -> Y1 is Y-1
    ),
    nth0(X1,Board,Rs),
    nth0(Y1,Rs,E).

/*------------------------------ Movement Execution -------------------------*/

/*places a piece on the board in the chosen tile*/
place_piece(Side,Board,NewBoard,X,Y):-
    playerValue(Side,Value),
    nth1(X,Board,Rs),
    (
        (X<4; X>6) -> Y1 is Y - 4;
        (X>3, X<7) -> Y1 is Y-1
    ),
    replace_element_in_list(Rs,Y1,Value,NewList),
    X1 is X-1,
    replace_list_in_board(Board, X1, NewList, NewBoard).

/*replaces an element in a list given the index and the new value*/
replace_element_in_list([_|T],0,Value,[Value|T]).
replace_element_in_list([H|T],Y,Value,[H|NL]) :-
    Y > 0, NY is Y-1, replace_element_in_list(T,NY,Value,NL).

/*replaces a list(row) on the board given the index(column) and the new list(row)*/
replace_list_in_board([_|T],0,Value,[Value|T]).
replace_list_in_board([H|T],X,Value,[H|NB]) :-
    X > 0, NX is X-1, replace_list_in_board(T,NX,Value,NB).