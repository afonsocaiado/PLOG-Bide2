:- consult('menu.pl').
:- consult('board.pl').
:- consult('game.pl').
:- use_module(library(random)).
:- use_module(library(system)).

play :-
    mainMenu.
