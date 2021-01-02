:-use_module(library(lists)).
:-use_module(library(clpfd)).

initial(Board):-
	Board=[[A,B,C,D,E,F,o,H],
			[A1,B1,C1,o,E1,F1,G1,H1],
			[o,B2,C2,D2,E2,F2,G2,o],
			[A3,B3,C3,D3,E3,F3,G3,H3],
			[A4,B4,C4,D4,E4,F4,G4,H4],
			[A5,B5,C5,D5,E5,o,G5,H5]].

/*---------- Helping Predicates ----------------*/
length_of(N, Ls) :-
   length(Ls, N).

size(Matrix, Rows, Columns) :-
   length(Matrix, Rows),
   maplist(length_of(Columns), Matrix).

variableValues(N, ListVarValues):-
	iterateList(N, ListVarValues1),
	reverse(ListVarValues1, ListVarValues).

iterateList(0,[]).
iterateList(N, [N|ListVarValues]):-
	N1 is N-1,
	iterateList(N1, ListVarValues).
/*------------- Get the position of the dots on the board ----------------*/
dotPositions([],[],49).
dotPositions([Line|T],DotPos,N):-
	dotPositions(T,DotPos1,N1),
	dotPositionsLine(Line,DotPos2,N1,NT),
	append(DotPos1,DotPos2, DotPos),
	N is NT.

dotPositionsLine([],[],N,N).
dotPositionsLine([o|T],[NT|DotPos],N,NT):-
	dotPositionsLine(T,DotPos,N,NT1),
	NT is NT1-1.
dotPositionsLine([H|T],DotPos,N,NT):-
	dotPositionsLine(T,DotPos,N,NT1),
	NT is NT1-1.

multiBalance(B,N):-
	initial(Linhas),
	transpose(Linhas,Colunas),
    maplist(same_length(N),Vars),
    variableValues(N, VarsValues),
    size(Linhas, R, C),
    TotalLength is R*C,
    domain(Vars,0,TotalLength),
	%dotPositions(Board, DotPos, 49),
	write(DotPos),
	dotInLine(Linhas),
	labeling([],Vars).

dotInLine([H|T]):-
	member(o, H),
	length(H, N),
	\+nth1(1, H, o),
	\+nth1(N, H, o),
	sumlist(H, SumL),
	SumL>0,
	nth1(DotIndex, H, o),
	leftSideCalc(DotIndex, H, 1, LSum),
	rightSideCalc(DotIndex, H, 1, N, RSum),
	sum(LSum, #=, RSum).

leftSideCalc(DotIndex, [_], DotIndex, 0).
leftSideCalc(DotIndex, [H|T], VariableIndex, LSum):-
	VariableIndex1 is VariableIndex+1,
	leftSideCalc(DotIndex, T, VariableIndex1, LSum1),
	Multiplier is DotIndex - VariableIndex1,
	CellValue is H * Multiplier,
	LSum is LSum1 + CellValue.

rightSideCalc(_,_,LengthOfLine,LengthOfLine,0).
rightSideCalc(DotIndex, Line, VariableIndex, LengthOfLine,Rsum):-
	VariableIndex=<DotIndex,
	VariableIndex1 is VariableIndex +1,
	rightSideCalc(DotIndex, Line, VariableIndex1, LengthOfLine, RSum).	
rightSideCalc(DotIndex, [H|T], VariableIndex, LengthOfLine, RSum):-
	VariableIndex>DotIndex,
	VariableIndex1 is VariableIndex + 1,
	rightSideCalc(DotIndex, T, VariableIndex1, LengthOfLine, RSum1),
	Multiplier is VariableIndex1 - DotIndex,
	CellValue is H * Multiplier,
	RSum is RSum1 + CellValue.