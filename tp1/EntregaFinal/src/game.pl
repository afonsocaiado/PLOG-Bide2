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
:- dynamic playerPieces/2.

/*score positivo jogador 1 esta a ganhar e negativo o jogador 2 esta a ganhar*/
%game_state(Board, Player, Score).
 
/*--------------------- Miscellaneous Functions ------------------------*/
value_of_y_based_on_x(X,Y,Y1):-
        (X==1; X==9) -> Y1 is Y - 4;
        (X==2; X==8) -> Y1 is Y - 3;
        (X==3; X==7) -> Y1 is Y - 2;
        (X>3; X<7) -> Y1 is Y - 1.

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
        %display_game(Board3,Score),
        game(Side, Board3, Score).


play:- 
    player_select_side(Player),
    initial(Board),
    game(Player, Board, 0).


/* -----------player input --------------*/

/*reads the side the player wants to be on (red or blue) and validates input*/
player_select_side(Player) :-
    write('\nSelect your side (red/blue): '),
    read(Player_Side),
    (
        (player(Player_Side), Player = Player_Side, !);
        (write('\nInvalid side, please type \'red.\' or \'blue.\'\n'), player_select_side(Player))
    ).

/*reads the type of move the player wants to execute and validates it*/
player_input_move_type(Side, Board1, Board2):-
        playerPieces(Side,Pieces),
        Pieces1 is Pieces + 1,
        write('\nYou have '), write(Pieces1), write(' pieces..\n'),
        write('\nDo you want to play, bide, or release? (p / b / r)\n'),
        read(MoveType),
        (
        (MoveType = 'p' -> player_input_move(Side, Board1, Board2), !);
        (MoveType = 'b' -> player_bide(Side,Pieces), append(Board1,[],Board2),!);
        (MoveType = 'r' -> ((Pieces1>1)->(player_release(Side, Pieces1, Board1, Board2), !);(write('Not enough pieces to release!\n')), player_input_move_type(Side, Board1, Board2)));
        (MoveType \= 'p', MoveType \= 'b', MoveType \= 'r') -> (write('Invalid character, please type \'p.\' or \'b.\' or \'r\' \n')), player_input_move_type(Side, Board1, Board2)).

/*reads the position the player wants to place a piece on and calls fucntions to validate if the position is legal*/
player_input_move(Side, Board, NewBoard):- 
    write('\nChoose where to move: (X-Y)'),
    read(X-Y),
    (
        valid_move(X,Y,Board);
        (write('\nInvalid position. Retry: '), player_input_move(Side, Board, NewBoard))
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
    value_of_y_based_on_x(X,Y,Y1),
    nth0(X1,Board,Rs),
    nth0(Y1,Rs,E).

/*------------------------------ Movement Execution -------------------------*/
player_release(Side, 0, Board1, NewBoard):-
    retract(playerPieces(Side,_)),
    assert(playerPieces(Side,0)),
    append(Board1,[],NewBoard),!.

player_release(Side, Pieces, Board1, Board2):-
    player_input_move(Side, Board1, Board2),
    display_game(Board2,0),
    Pieces1 is Pieces - 1,
    player_release(Side, Pieces1, Board2, Board3),!.

player_bide(Side, Pieces):-
    retract(playerPieces(Side,Pieces)),
    Pieces1 is Pieces + 1,
    assert(playerPieces(Side,Pieces1)).

/*places a piece on the board in the chosen tile*/
place_piece(Side,Board,NewBoard,X,Y):-
    playerValue(Side,Value),
    nth1(X,Board,Rs),
    value_of_y_based_on_x(X,Y,Y1),
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