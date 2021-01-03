:-use_module(library(clpfd)).
:-use_module(library(lists)).

main:-
    baker([85, 98, 60, 70], [[0, 3, 14, 1], [15, 0, 10, 25], [14, 10, 0, 3], [1, 25, 3, 0]], [10, 5, 20, 15]).

baker(PreferedTime, HouseTravelTime, BakeryTravelTime):-

    printProblem(PreferedTime, HouseTravelTime, BakeryTravelTime),

    getLengths(PreferedTime,Route,DeliveryInstants,NumberOfHouses),

    declareVars(Route,DeliveryInstants,NumberOfHouses),

    % Restrictions

    restriction1(Route,DeliveryInstants),

    restriction2(Route,BakeryTravelTime,DeliveryInstants),
    
    restriction3(HouseTravelTime,TravelTimeList,PreferedTime, DeliveryInstants, Delay, NumberOfHouses,Delay,Route),
    
    restriction4(NumberOfHouses,Route,BakeryTravelTime,DeliveryInstants,Time),

    labeling([minimize(Time)], Route),

    printSolution(Time,Delay,Route)
.

printProblem(PreferedTime, HouseTravelTime, BakeryTravelTime):-
    write('PreferedTime = '),
    write(PreferedTime),
    write('\n'),
    write('HouseTravelTime = '),
    write(HouseTravelTime),
    write('\n'),
    write('BakeryTravelTime = '),
    write(BakeryTravelTime),
    write('\n')
.

getLengths(PreferedTime,Route,DeliveryInstants,NumberOfHouses):-
    
    length(PreferedTime, NumberOfHouses),

    length(Route, NumberOfHouses),
    length(DeliveryInstants, NumberOfHouses)
.

declareVars(Route,DeliveryInstants,NumberOfHouses):-

    domain(Route, 1, NumberOfHouses),
    domain(DeliveryInstants, 1, 100000)
.

restriction1(Route,DeliveryInstants):-
    all_distinct(Route),
    all_distinct(DeliveryInstants)
.

restriction2(Route,BakeryTravelTime,DeliveryInstants):-
    element(1, Route, FirstHouseID),
    element(FirstHouseID, BakeryTravelTime, BakeryToHouseTime),
    element(1, DeliveryInstants, BakeryToHouseTime)
.

restriction3(HouseTravelTime,TravelTimeList,PreferedTime, DeliveryInstants, Delay, NumberOfHouses,Delay,Route):-
    append(HouseTravelTime, TravelTimeList),
    getRouteTime(Route, TravelTimeList, PreferedTime, DeliveryInstants, Delay, NumberOfHouses)
.

restriction4(NumberOfHouses,Route,BakeryTravelTime,DeliveryInstants,Time):-
    element(NumberOfHouses, Route, LastHouseID),
    element(LastHouseID, BakeryTravelTime, HouseToBakeryTime),
    element(NumberOfHouses, DeliveryInstants, LastInstant),
    Time #= LastInstant + HouseToBakeryTime
.

getRouteTime([PrevHouse, House], TravelTimeList, PreferedTime, [PrevHouseTime, HouseTime], Delay, NumberOfHouses):-
    Position #= (PrevHouse - 1) * NumberOfHouses + House,
    element(Position, TravelTimeList, HouseTravelTime),
    HouseTime #= (PrevHouseTime + 5) + HouseTravelTime,
    % Get Delay
    element(House, PreferedTime, DeliveryTime),
    Delay #= HouseTime - DeliveryTime
.

getRouteTime([PrevHouse, House|Rest], TravelTimeList, PreferedTime, [PrevHouseTime, HouseTime | RestTime], Delay, NumberOfHouses):- 
    % Get travel Time
    Position #= (PrevHouse - 1) * NumberOfHouses + House,
    element(Position, TravelTimeList, HouseTravelTime),
    HouseTime #= HouseTravelTime + (PrevHouseTime + 5),

    % Get Delay
    element(House, PreferedTime, DeliveryTime),
    Delay #= HouseTime - DeliveryTime + NewDelay,

    getRouteTime([House|Rest], TravelTimeList, PreferedTime, [HouseTime | RestTime], NewDelay, NumberOfHouses)
.

printSolution(Time,Delay,Route):-
    write(Time),
    write('<-->'),
    write(Delay),
    write('<-->'),
    write(Route)
.