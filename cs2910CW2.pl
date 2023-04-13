/* location defines a set of locations in the building */
location(outside).
location(porch1).
location(porch2).
location(kitchen).
location(livingRoom).
location(coridoor).
location(masterBed).
location(bedroom).
location(wc).

/* edges represent the doorways */
edge(outside, porch2).
edge(outside, porch1).
edge(porch1, kitchen).
edge(livingRoom, kitchen).
edge(livingRoom, porch2).
edge(livingRoom, coridoor).
edge(coridoor, masterBed).
edge(coridoor, bedroom).
edge(coridoor, wc).

/* edges with distance in meters */
edge(outside, porch2, 1).
edge(outside, porch1, 1).
edge(porch1, kitchen, 1).
edge(livingRoom, kitchen, 3).
edge(livingRoom, porch2, 5).
edge(livingRoom, coridoor, 1).
edge(coridoor, masterBed, 2).
edge(coridoor, bedroom, 2).
edge(coridoor, wc, 2).

/* connected predicates to check if two locations are connected and what length the connection is */
connected(X,Y) :- edge(X,Y) ; edge(Y,X).
connected(X,Y,L) :- edge(X,Y,L) ; edge(Y,X,L).

/* Error Handling for inputs */
path(O,_,_) :- \+location(O), write("Origin is not a valid location"),!,fail.
path(_,D,_) :- \+location(D), write("Destination is not a valid location"),!, fail.
path(O,D,_) :- \+(O\==D), write("Origin and Destination are the same"), !, fail.

/* Path predicates use Depth First Search to find a path between two locations and optionaly return the length */
path(O, D, Path) :-
	find(O,D,[O],W),
	reverse(W,Path).

path(O, D, Path, Len) :-
        find(O,D,[O],W, Len),
	reverse(W,Path).

/* Find predicates are used to track visited nodes and find distinct paths */
find(O, D, Visited, Way) :-
    connected(O, D),
    Way = [D|Visited].
find(O, D, Visited, Way) :-
    connected(O, M),
    M \== D,
    \+member(M, Visited),
    find(M, D, [M|Visited], Way).
find(_, _, _, no_path).

find(O, D, Visited, Way, L) :-
    connected(O, D, L),
    Way = [D|Visited].
    find(O, D, Visited, Way, L) :-
        connected(O, M, G),
	M \== D,
        \+member(M, Visited),
        find(M, D, [M|Visited], Way, L1),
	L is G+L1.


/* path_bidirectional predicate finds path bwteen two origins and one common destination and returns the path from origin 1 to origin 2 */
path_bidirectional(O1, O2, D, Path) :-
	% Forward search from origin 1
    find(O1, D,[O1],  Forward),
	% Backward search from origin 2
    find(O2, D, [O2],  Backward),
    reverse(Forward, RevForward),
    without_last(RevForward, CutRevForward),
    (Backward \= no_path,
    append(CutRevForward, Backward, Path)
    ).
/* helper to get rid of duplicate destination node from list */       
without_last([_],[]).
without_last([X|Xs], [X|WithoutLast]) :-
    without_last(Xs, WithoutLast).

/* paths_sorted predicate returns list of all paths between two locations which is sorted by cost in meters */
paths_sorted(O, D,  Paths, Cost) :-
    findall(path(O, D, Path, Len), path(O, D, Path, Len), AllPaths),
    % Sort the combined paths based on their total cost
    sort(AllPaths, SortedPaths),
    path(O, D, _, Cost),
    maplist(arg(3), SortedPaths, Paths).

/* meeting_point predicate tries to find a bidirectional path from two origins and a common destination provided the cost of getting from the destination to eitehr origin is equilivant*/
meeting_point(O1, O2, D, Path) :-
    path(O1, D, _, Cost1),
    path(O2, D, _, Cost2),
    Cost1 =:= Cost2,
    path_bidirectional(O1, O2, D, Path).
