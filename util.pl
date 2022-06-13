% Cosas que pueden ser reutilizadas
% en otros archivos

/*
Remplaza un elemento de una lista 
dado su indice.
[H|T]: La lista con elemento a remplazar
P: índice en la lista del elemento que se va a remplazar
E: Elemento a añadir
[E|T]: Lista resultante
*/
remplazar([_|T],0,E,[E|T]).
remplazar([H|T],P,E,[H|R]) :-
    P > 0, NP is P-1, remplazar(T,NP,E,R).


/*
Repite un elemento y genera una lista
N: Número de veces a repetir
E: Elemento a repetir
Lista: Lista de lista resultantes
*/
repetir(0, _, []).
repetir(N, E, Lista) :-
    N > 0,
    N1 is N-1,
    repetir(N1, E, Repetidos),
    append([E], Repetidos, Lista).