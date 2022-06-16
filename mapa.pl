:- [util].

/*
Crea un mapa dado:
N: ancho del mapa, n > 0.
M: alto, m > 0.
Mapa: el mapa creado, que es una lista de dimensión n x m.
*/
crear_mapa(N, M, Mapa) :-
    N > 0,
    M > 0,
    posicion_salida(N, M, Salida),
    crear_mapa_salida(N, M, Salida, Mapa).


/*
Se obtiene el tipo de casilla en el mapa (vacio,
normal, vino, veneno, salida)
X: Posición en la coordenada X
Y: Posición en la coordenada Y
Mapa: Lista 2D con los tipos de casilla
Tipo: El valor en la posición (X,Y)
*/
tipo_casilla((X, Y), Mapa, Tipo) :-
    nth0(Y, Mapa, Fila),
    nth0(X, Fila, Tipo).

/*
* Actualiza el tipo de la casilla de un mapa
(X, Y): Las coordenadas del mapa
Mapa: El mapa a actualizar
Tipo: Tipo de casilla a cambiar (vacio, normal, vino, veneno, salida)
MapaActualizado: El mapa resultante después de actualizar
*/
casilla_actualizada((X, Y), Mapa, Tipo, MapaActualizado) :-
    nth0(Y, Mapa, Fila),
    remplazar(Fila, X, Tipo, NuevaFila),
    remplazar(Mapa, Y, NuevaFila, MapaActualizado).

/*
Rellena con queso al mapa
N, M: N,M > 0, son las dimensiones del mapa
Mapa: El mapa a rellanar
[H,T]: Lista de quesos (normal, con vino, con veneno)
MapaConQueso: Ya el mapa con queso en sus cuadrículas al azar
*/
rellenar_queso(_,_,MapaConQueso, [], MapaConQueso).
rellenar_queso(N, M, Mapa, [Queso|T], MapaConQueso) :-
    random(0, N, X),
    random(0, M, Y),
    % Se selecciona una fila al azar
    nth0(Y, Mapa, Fila),
    remplazar(Fila, X, Queso, NuevaFila),
    remplazar(Mapa, Y, NuevaFila, MapaActualizado),
    rellenar_queso(N, M, MapaActualizado, T, MapaConQueso).


lista_queso(0, []).
lista_queso(N, Lista) :-
    N > 0,
    random(0, 3, NumQueso),
    queso(NumQueso, Queso),
    M is N - 1,
    lista_queso(M, ListaRestante),
    append([Queso], ListaRestante, Lista).

queso(0, normal).
queso(1, vino).
queso(2, veneno).

/*
Crea un mapa dado:
N: ancho del mapa, n > 0.
M: alto, m > 0.
(X,Y): la posición de la salida
Mapa: el mapa creado, que es una lista de dimensión n x m.
*/
crear_mapa_salida(N, M, (X,Y), Mapa) :-
    N > 0,
    M > 0,
    fila_vacia(N, Fila),
    repetir(M, Fila, MapaVacio),
    % Con esto se define cuántos quesos van a aparecer
    % si se desea se puede disminuir o aumentar
    Mitad is (N * M)/2,
    Redondeado is ceiling(Mitad),
    lista_queso(Redondeado, ListaDeQueso),
    rellenar_queso(N, M, MapaVacio, ListaDeQueso, MapaConQueso),
    agregar_salida((X,Y), MapaConQueso, Mapa).

agregar_salida((X,Y), Mapa, MapaResultante) :-
    nth0(Y, Mapa, Fila),
    remplazar(Fila, X, salida, NuevaFila),
    remplazar(Mapa, Y, NuevaFila, MapaResultante).

posicion_salida(N, M, (X, Y)) :-
    N > 0,
    M > 0,
    random(0, M, Y),
    posicion_X(N, M, Y, X).

/*
Se usa para obtener la posición en X,
ya que primero se plantea elegir la posición al azar el Y.
Como la salida de la caja es a los costados, hay que moverse entre
los lados si se está en medio o por toda la fila
si se está al final/inicio
N, M: Dimensiones del Mapa
Y: Posición en Y
X: Posición en X
*/
posicion_X(N, M, Y, X) :-
    Y =\= 0,
    Ultimo is M - 1,
    Y =\= Ultimo,
    random(0, 2, Binario),
    izq_derecha(Binario, N, X).

posicion_X(N, _, Y, X) :-
    Y == 0,
    random(0, N, X).

posicion_X(N, M, Y, X) :-
    Ultimo is M - 1,
    Y == Ultimo,
    random(0, N, X).

/*
Elegir al azar si se usa la posición 0
o final de una lista
*/
izq_derecha(0, _, 0).
izq_derecha(1, X, Xf) :-
    Xf is X - 1.

fila_vacia(0, Fila) :-
    append([], [], Fila).

fila_vacia(N, Fila) :-
    N > 0,
    M is N -1,
    fila_vacia(M, Lista),
    append([vacio], Lista, Fila).