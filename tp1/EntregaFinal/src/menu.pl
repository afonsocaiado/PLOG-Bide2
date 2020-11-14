mainMenu :-
    printMain,
    getOption,
    read(Input),
    optionChosen(Input).

printMain :-
    nl,nl,
    write(' _______________________________________________________________________ '),nl,
    write('|                                                                       |'),nl,
    write('|                       ____ _____ _____  ______                        |'),nl,
    write('|                      |  _  _   _|  __  |  ____|                       |'),nl,
    write('|                      | |_) || | | |  | | |__                          |'),nl,
    write('|                      |  _ < | | | |  | |  __|                         |'),nl,
    write('|                      | |_) || |_| |__| | |____                        |'),nl,
    write('|                      |____/_____|_____/|______|                       |'),nl,
    write('|                                                                       |'),nl,
    write('|                                                                       |'),nl,
    write('|                         Afonso Caiado de Sousa                        |'),nl,
    write('|                             Vasco Teixeira                            |'),nl,
    write('|               -----------------------------------------               |'),nl,
    write('|                                                                       |'),nl,
    write('|                                                                       |'),nl,
    write('|                          1. Play                                      |'),nl,
    write('|                                                                       |'),nl,
    write('|                          2. Aqui podemos eventualmente                |'),nl,
    write('|                                                                       |'),nl,
	write('|                          3. Ter mais modos de jogo                    |'),nl,
    write('|                                                                       |'),nl,
    write('|                          0. Quit                                      |'),nl,
    write('|                                                                       |'),nl,
    write('|                                                                       |'),nl,
    write(' _______________________________________________________________________ '),nl,nl,nl.

getOption :-
    write('Type your choice: ').

optionChosen(1) :-
    play.

optionChosen(0) :-
    write('\nGoodbye...\n\n').

optionChosen(_Other) :-
    write('\nInvalid choice! Try again please.\n\n'),
    getOption,
    read(Input),
    optionChosen(Input).