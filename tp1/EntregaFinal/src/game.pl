/*state(Board,Player,Score) a modificar conforme criterios de discussao*/
/*ideia- mudar o board para um termo de listas para cada linha i.e. tab(1//[0,0,0], 2//[0,0,0,0,0].....)*/
/* fazer um predicado para retornar o valor de cada casa para se utilizar durante o jogo*/
/*guardar o número de peças que cada jogador tem guardadas a espera de jogar(com o bide)*/
/*usar operações como factos i.e.:- place(casa, jogador)  bide(jogador,Npecas)*/
:-use_module(library(lists)).
:-use_module(library(between)).
player(red).
player(blue).
other_player(red, blue).
other_player(blue, red).
playerValue(blue,1).
playerValue(red,2).

:- dynamic playerPieces/2.
:- dynamic playerMaxPieces/2.

/*score positivo jogador 1 esta a ganhar e negativo o jogador 2 esta a ganhar*/
%game_state(Board, Player, Score).
 
/*--------------------- Miscellaneous Functions ------------------------*/
value_of_y_based_on_x(X,Y,Y1):-
        (X=1; X=9) -> Y1 is Y - 4;
        (X=2; X=8) -> Y1 is Y - 3;
        (X=3; X=7) -> Y1 is Y - 2;
        (X>3; X<7) -> Y1 is Y - 1.

reverse_value_of_y_based_on_x(X,Y,Y1):-
        (X=1; X=9) -> Y1 is Y + 4;
        (X=2; X=8) -> Y1 is Y + 3;
        (X=3; X=7) -> Y1 is Y + 2;
        (X>3; X<7) -> Y1 is Y+1.

adjacent(Board, X, Y, X1, Y1):-
    /*inside_board(X1, Y1),*/
    (
        (X1 is X, Yt is Y+1, get_player_by_pos(X1,Yt, Board, 1, P), P\=0, reverse_value_of_y_based_on_x(X1,Yt, Y1));
        (X1 is X, Yt is Y-1, get_player_by_pos(X1,Yt, Board, 1, P), P\=0, reverse_value_of_y_based_on_x(X1,Yt, Y1));
        (X1 is X+1, Yt is Y, get_player_by_pos(X1,Yt, Board, 1, P), P\=0, reverse_value_of_y_based_on_x(X1,Yt, Y1));
        (X1 is X+1, Yt is Y-1, get_player_by_pos(X1,Yt, Board, 1, P), P\=0, reverse_value_of_y_based_on_x(X1,Yt, Y1));
        (X1 is X+1, Yt is Y+1, get_player_by_pos(X1,Yt, Board, 1, P), P\=0, reverse_value_of_y_based_on_x(X1,Yt, Y1));
        (X1 is X-1, Yt is Y, get_player_by_pos(X1,Yt, Board, 1, P), P\=0, reverse_value_of_y_based_on_x(X1,Yt, Y1));
        (X1 is X-1, Yt is Y-1, get_player_by_pos(X1,Yt, Board, 1, P), P\=0, reverse_value_of_y_based_on_x(X1,Yt, Y1));
        (X1 is X-1, Yt is Y+1, get_player_by_pos(X1,Yt, Board, 1, P), P\=0, reverse_value_of_y_based_on_x(X1,Yt, Y1))
    ).

find_adjacent_cells(Board, X, Y, ListAdjX, ListAdjY):-
    findall(X1,adjacent(Board,X,Y,X1,Y1),ListAdjX),
    findall(Y1,adjacent(Board,X,Y,X1,Y1),ListAdjY).

/*-------------------------- Basic Game Mechanisms --------------------------------*/
 
gamePC(Side, Board1, Score, ReleaseTag):-
        score_board(ScoreBoard),
        other_player(Side, OtherSide),
        display_game(Board1),
        write('\n'),write(Side), write(' playing!\n'),
        write('Score: '), write(Score), write('\n'),
        player_input_move_type(Side, Board1, Board2, ReleaseTag, ReleaseTag1),
        write('\n'), write(Side), write(' moving:\n'),
        display_game(Board2),
        value(Board2, ScoreBoard, Score1),
        game_over(Board2, GO),
        (GO = 1 -> (announceResult(Score1), mainMenu); write('$')),
        write('\n'),write(OtherSide), write(' playing!\n'),
        write('Score: '), write(Score1), write('\n'),
        cpuMove(OtherSide, Board2, Board3, ReleaseTag1, ReleaseTag2),
        write('\n'), write(OtherSide), write(' moving:\n'),
        value(Board3, ScoreBoard, Score2),
        game_over(Board3, GO1),
        (GO1 = 1 -> (announceResult(Score2), mainMenu); write('$')),
        gamePC(Side, Board3, Score2, ReleaseTag2).

game(Side, Board1, Score,ReleaseTag):-
        score_board(ScoreBoard),
        other_player(Side, OtherSide),
        display_game(Board1),
        write('\n'),write(Side), write(' playing!\n'),
        write('Score: '), write(Score), write('\n'),
        player_input_move_type(Side, Board1, Board2, ReleaseTag, ReleaseTag1),
        write('\n'), write(Side), write(' moving:\n'),
        display_game(Board2),
        value(Board2, ScoreBoard, Score1),
        game_over(Board2, GO),
        (GO = 1 -> (announceResult(Score1), mainMenu); write('$')),
        write('\n'),write(OtherSide), write(' playing!\n'),
        write('Score: '), write(Score1), write('\n'),
        player_input_move_type(OtherSide, Board2, Board3, ReleaseTag1, ReleaseTag2),
        write('\n'), write(OtherSide), write(' moving:\n'),
        value(Board3, ScoreBoard, Score2),
        game_over(Board3, GO1),
        (GO1 = 1 -> (announceResult(Score2), mainMenu); write('$')),
        gamePC(Side, Board3, Score2, ReleaseTag2).

value(Board, ScoreBoard, NewScore):-
    iterateThroughBoard(Board, ScoreBoard, ScoreSide, ScoreOtherSide),
    NewScore is (ScoreSide - ScoreOtherSide).

iterateThroughBoard([], [], ScoreSideTotal1, ScoreOtherSideTotal1):-
    ScoreSideTotal1 is 0, ScoreOtherSideTotal1 is 0.
iterateThroughBoard([HR|TR], [SBH|SBT], ScoreSideTotal, ScoreOtherSideTotal):-
    iterateThroughBoard(TR, SBT, ScoreSideTotal1, ScoreOtherSideTotal1),
    iterateThroughRow(HR, SBH, ScoreSide, ScoreOtherSide),
    ScoreSideTotal is ScoreSideTotal1 + ScoreSide,
    ScoreOtherSideTotal is ScoreOtherSideTotal1 + ScoreOtherSide.

iterateThroughRow([], [], ScoreSide1,ScoreOtherSide1):-
    ScoreSide1 is 0, ScoreOtherSide1 is 0.
iterateThroughRow([H|T], [SBH|SBT], ScoreSide, ScoreOtherSide):-
    iterateThroughRow(T, SBT, ScoreSide1, ScoreOtherSide1),
    (
        (H = 0, (ScoreOtherSide is ScoreOtherSide1 + 0, ScoreSide is ScoreSide1 + 0));
        (H = 1, (ScoreSide is ScoreSide1 + (1 * SBH), ScoreOtherSide is ScoreOtherSide1 + 0));
        (H = 2, (ScoreOtherSide is ScoreOtherSide1 + (1 * SBH), ScoreSide is ScoreSide1 + 0))
    ).
    
announceResult(Score):-
    (
    Score>0 -> write('\nBlue Wins by '), write(Score), write(' points!!!!');
    Score<0 -> write('\nRed Wins by '), Score1 is Score *(-1), write(Score1), write(' points!!!!');
    Score=0 -> write('\nIt\'s a draw!!!')
    ).

game_over(Board, GO):-
    iterate(Board, Val),
    (Val=1, GO is 0);
    (Val=0, GO is 1).

iterate([],0).
iterate([H|T],Val):-
    iterateRow(H,ValR),
    (ValR = 0 )-> (iterate(T, Val1), Val is Val1);
    (ValR = 1 )-> (Val is ValR).

iterateRow([], 0).
iterateRow([H|T], Val):-
    (H = 0) -> Val is 1;
    (H \= 0) -> (iterateRow(T,Val1),Val is Val1).

play_game(1):- 
    player_select_side(Player),
    initial(Board),
    (game(Player, Board, 0, 0);
    mainMenu).

play_game(2):-
    player_select_side(Player),
    initial(Board),
    (gamePC(Player, Board, 0, 0);
    mainMenu).


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
player_input_move_type(Side, Board1, Board2, ReleaseTag, ReleaseTag1):-
        ReleaseTag = 0,
        playerPieces(Side,Pieces),
        Pieces1 is Pieces + 1,
        write('\nYou have '), write(Pieces1), write(' pieces..\n'),
        write('\nDo you want to play, bide, or release? (p / b / r)\n'),
        read(MoveType),
        (
            (MoveType = 'p' -> player_input_move(Side, Board1, X, Y), move(Side,Board1,Board2,X,Y),!);
            (MoveType = 'b' -> ((player_bide(Side,Pieces), append(Board1,[],Board2),!);(write('Can\'t bide again!\n'), player_input_move_type(Side, Board1, Board2,ReleaseTag, ReleaseTag))));
            (MoveType = 'r' -> ((Pieces1>1)->(player_release(Side, Pieces1, Board1, Board2),!);(write('Not enough pieces to release!\n'), player_input_move_type(Side, Board1, Board2,ReleaseTag, ReleaseTag))), ReleaseTag1 is ReleaseTag+1);
            (MoveType \= 'p', MoveType \= 'b', MoveType \= 'r') -> (write('Invalid character, please type \'p.\' or \'b.\' or \'r\' \n')), player_input_move_type(Side, Board1, Board2,ReleaseTag, ReleaseTag)
        ).
player_input_move_type(Side, Board1, Board2, ReleaseTag, ReleaseTag1):-
        ReleaseTag = 1,
        playerPieces(Side,Pieces),
        Pieces1 is Pieces + 1,
        write('\nYou have '), write(Pieces1), write(' pieces..\n'),
        other_player(Side,OtherSide), write(OtherSide), write(' released so you must release as well!'),nl,
        (Pieces1>1,(player_release(Side, Pieces1, Board1, Board2),!);(write('Not enough pieces to release!\n'))); (player_input_move(Side, Board1, X, Y), move(Side, Board1, Board2, X, Y),!),ReleaseTag1 is ReleaseTag-1.

/*reads the position the player wants to place a piece on and calls fucntions to validate if the position is legal*/
player_input_move(Side, Board, XF, YF):- 
    write('\nChoose where to move: (X-Y)'),
    read(X-Y),
    (
        (valid_move(X,Y,Board), XF is X, YF is Y);
        (write('\nInvalid position. Retry: '),player_input_move(Side, Board, X1, Y1), XF is X1, YF is Y1)
    ).

/*------------------------------------- CPU ------------------------------------------*/
valid_moves(Board,MovesList):-
    findall(X-Y, valid_move(X,Y, Board), MovesList).

best_move([X-Y],ScoreBoard,X,Y,Max):-
    value_of_y_based_on_x(X,Y,Y1),
    getCellScore(X,Y1,ScoreBoard,Max).
best_move([X-Y|T], ScoreBoard, Xf,Yf, Max):-
        best_move(T, ScoreBoard, Xf1, Yf1, Max1),
        value_of_y_based_on_x(X,Y,Y1),
        getCellScore(X,Y1,ScoreBoard,Value),
        (Value>Max1 -> (Max is Value, Xf is X, Yf is Y); (Max is Max1, Xf is Xf1, Yf is Yf1)).

getCellScore(X,Y,ScoreBoard,Value):-
    nth1(X,ScoreBoard, Column),
    nth0(Y, Column, Value).

cpuMove(Side,Board, NewBoard, ReleaseTag, ReleaseTag1):-
    score_board(ScoreBoard),
    valid_moves(Board, MovesList),
    best_move(MovesList, ScoreBoard, X, Y, _),
    move(Side,Board,NewBoard,X,Y).

/*----------------------------- Movement Validations ---------------------------------*/

/*checks if a movement selected by a player is valid*/
valid_move(X,Y,Board):-
        inside_board(X,Y),
        pos_is_empty(Board,X,Y,0).

/*checks if the position chosen is inside the board*/
inside_board(X,Y):-
        ((X=1; X=9), between(4,6,Y));
        ((X=2; X=8), between(3,7,Y));
        ((X=3; X=7), between(2,8,Y));
        (between(4,6,X), between(1,9,Y)).

/*checks if the position chosen is empty*/
pos_is_empty(Board,X,Y,E) :-
    X1 is X-1,
    value_of_y_based_on_x(X,Y,Y1),
    nth0(X1,Board,Rs),
    nth0(Y1,Rs,E).

knockback_move(Board,_,_,[],[],NewBoard):-
    append(Board,[],NewBoard).
knockback_move(Board, X, Y,[HeadAdjX|TailAdjX], [HeadAdjY|TailAdjY], NewBoard):-
    knockback_move(Board, X, Y, TailAdjX, TailAdjY, NewBoard1),
    (
        (knockback_direction(X,Y,HeadAdjX,HeadAdjY,DirX,DirY), KX is HeadAdjX + DirX, KY is HeadAdjY + DirY,  pos_is_empty(NewBoard1,KX,KY,0), inside_board(KX,KY), knock_it_back(NewBoard1,HeadAdjX,HeadAdjY,KX,KY,NewBoard)); 
        (knockback_direction(X,Y,HeadAdjX,HeadAdjY,DirX,DirY), KX is HeadAdjX + DirX, KY is HeadAdjY + DirY, knockback_ramification(NewBoard1, HeadAdjX, HeadAdjY, KX, KY, DirX, DirY, NewBoard));
        (append(NewBoard1,[],NewBoard))
    ).

knockback_direction(X,Y,HeadAdjX,HeadAdjY,DirX,DirY):-
    DirX is HeadAdjX - X,
    DirY is HeadAdjY - Y.

knockback_ramification(Board, HeadAdjX, HeadAdjY, KX, KY, DirX, DirY, NewBoard):-
    inside_board(KX,KY),
    (
         (pos_is_empty(Board,KX,KY,0), append(Board,[],Board1));
         (KX1 is KX + DirX, KY1 is KY + DirY, knockback_ramification(Board, KX, KY, KX1, KY1, DirX, DirY, Board1))
    ),
    knock_it_back(Board1,HeadAdjX,HeadAdjY,KX,KY,NewBoard).


knock_it_back(Board,HeadAdjX,HeadAdjY,KX, KY,NewBoard):-
    value_of_y_based_on_x(HeadAdjX,HeadAdjY, Y1),
    get_player_by_pos(HeadAdjX,Y1,Board, 1, Player),
    remove_piece(Board, Board1, HeadAdjX, HeadAdjY),
    playerValue(P,Player),
    place_piece(P, Board1, NewBoard, KX, KY). 


get_player_by_pos(X,Y,[H|T], X, Player):-
        get_player_by_pos_row(Y, H, 0, Player),!.
get_player_by_pos(X,Y, [H|T], Counter, Player):-
        Counter1 is Counter + 1,
        get_player_by_pos(X,Y, T, Counter1, Player).

get_player_by_pos_row(Y,[H|T], Y, Player):-
        Player is H, !.
get_player_by_pos_row(Y, [H|T], Counter, Player):-
        Counter1 is Counter + 1,
        get_player_by_pos_row(Y, T, Counter1, Player).
    
/*------------------------------ Movement Execution -------------------------*/
player_release(Side, 0, Board1, NewBoard):-
    retract(playerPieces(Side,_)),
    assert(playerPieces(Side,0)),
    append(Board1,[],NewBoard),!.

player_release(Side, Pieces, Board, NewBoard):-
    Pieces1 is Pieces - 1,
    player_release(Side, Pieces1, Board, Board1),
    player_input_move(Side, Board1, XF, YF),
    move(Side, Board1, NewBoard, XF, YF),
    display_game(NewBoard).

player_bide(Side, Pieces):-
    retract(playerPieces(Side,Pieces)),
    Pieces1 is Pieces + 1,
    assert(playerPieces(Side,Pieces1)).

move(Side,Board,NewBoard,X,Y):-
    place_piece(Side,Board,Board2,X,Y),
    value_of_y_based_on_x(X,Y,Y1),
    find_adjacent_cells(Board2, X, Y1, ListAdjX, ListAdjY),
    move_adjacent_cells(Board2, X, Y, ListAdjX, ListAdjY, NewBoard).

move_adjacent_cells(Board, _,_, [],[], NewBoard):-
    append(Board,[],NewBoard).
move_adjacent_cells(Board, X, Y, ListAdjX, ListAdjY, NewBoard):-
    knockback_move(Board, X, Y,ListAdjX, ListAdjY, NewBoard).


/*places a piece on the board in the chosen tile*/
place_piece(Side,Board,NewBoard,X,Y):-
    playerValue(Side,Value),
    nth1(X,Board,Rs),
    value_of_y_based_on_x(X,Y,Y1),
    replace_element_in_list(Rs,Y1,Value,NewList),
    X1 is X-1,
    replace_list_in_board(Board, X1, NewList, NewBoard).

remove_piece(Board,NewBoard,X,Y):-
    Value is 0,
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