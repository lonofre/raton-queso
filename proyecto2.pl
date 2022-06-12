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
Rellena con queso al mapa
N, M: N,M > 0, son las dimensiones del mapa
Mapa: El mapa a rellanar
[H,T]: Lista de quesos (normal, con vino, con veneno)
MapaConQueso: Ya el mapa con queso en sus cuadrículas al azar
*/
rellenar_queso(_,_,MapaConQueso, [], MapaConQueso).
rellenar_queso(N, M, Mapa, [H|T], MapaConQueso) :-
    random(0, N, X),
    random(0, M, Y),
    % Se selecciona una fila al azar
    nth0(Y, Mapa, Fila),
    remplazar(Fila, X, H, NuevaFila),
    remplazar(Mapa, Y, NuevaFila, MapaActualizado),
    rellenar_queso(N, M, MapaActualizado, T, MapaConQueso).

remplazar([_|T],0,E,[E|T]).
remplazar([H|T],P,E,[H|R]) :-
    P > 0, NP is P-1, remplazar(T,NP,E,R).

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

/*
Repite una lista dada y da como resultado una lista de listas
N: Número de veces a repetir
L: Lista a repetir
Lista: Lista de lista resultantes
*/
repetir(0, _, []).
repetir(N, L, Lista) :-
    N > 0,
    N1 is N-1,
    repetir(N1, L, Repetidos),
    append([L], Repetidos, Lista).

    /*
    Para los movimientos pueden asignarse un numero para poder generar un movimiento al azar para simular el movimiento del raton
    */
/*
*
Movimientos para el ratón dependiendo si está sobrio o ebrio.
*/
estado((X,Y),Orientacion_Inicial,C,Est_Raton,P,O,Est_Raton):-
estadoAuxiliar((X,Y),Orientacion_Inicial,C,Est_Raton,P,O,Est_Raton).

estadoAuxiliar((Xi,Yi),Oi,[],Est_Raton,(Xi,Yi),Oi,_).
estadoAuxiliar((Xi,Yi),Oi,[C|T],Est_Raton,Pf,Of,_):-
	movimiento((Xi,Yi),Oi,C,Est_Raton,P1,O1),estadoAuxiliar(P1,O1,T,Est_Raton,Pf,Of,_).

/**Funcion que simula un paso al frente que hace el raton sin alterar su orientacion*/

movimiento((Xi,Yi),north,avanzar,Est_Raton,(Xi,Yf),north):-
Yf is Yi+1.
movimiento((Xi,Yi),south,avanzar,Est_Raton,(Xi,Yf),south):-
Yf is Yi-1.
movimiento((Xi,Yi),east,avanzar,Est_Raton,(Xf,Yi),east):-
Xf is Xi+1.
movimiento((Xi,Yi),west,avanzar,Est_Raton,(Xf,Yi),west):-
Xf is Xi-1.
/**
estado((0,0),north,[avanzar,avanzar,giraD,giraI,giraI,avanzar,avanzar],sobrio,P,O,E).
*/
/**Funcion que hace girar hacia la izquierda al raton, modificando la orientacion*/

movimiento((Xi,Yi),Oi,giraI,Est_Raton,(Xi,Yi),Of):-
giroIzq(Oi,giraI,Of).

/**Funcion que hace girar hacia la derecha al raton, así como su orientacion*/

movimiento((Xi,Yi),Oi,giraD,Est_Raton,(Xi,Yi),Of):-
giroDer(Oi,giraD,Of).

/**Funcion que hace al raton dar media vuelta, de acuerdo a su orientacion*/

movimiento((Xi,Yi),Oi,gira180,Est_Raton,(Xi,Yi),Of):-
giro180(Oi,gira180,Of).

/**Funcion para que el raton pueda comer un queso*/

movimiento((Xi,Yi),Oi,comerQueso,Est_Raton,(Xi,Yi),Of):-comerQueso(Est_Raton,T_Queso,Estado_Raton_F).

/**Funcion auxiliar que realiza las respectivas rotaciones de acuerdo a la direccion que está mirando el raton*/

giro180(north,gira180,south).
giro180(south,gira180,north).
giro180(east,gira180,west).
giro180(west,gira180,east).

/**Funcion auxiliar que realiza las respectivas rotaciones hacia la izquierda de acuerdo a la direccion que está mirando el raton*/

giroIzq(north,giraI,west).
giroIzq(south,giraI,east).
giroIzq(east,giraI,north).
giroIzq(west,giraI,south).

/**Funcion auxiliar que realiza las respectivas rotaciones hacia la derecha de acuerdo a la direccion que está mirando el raton*/

giroDer(north,giraD,east).
giroDer(south,giraD,west).
giroDer(east,giraD,south).
giroDer(west,giraD,north).

/**Funcion auxiliar que revisa el tipo de queso a comer y devolviendo el estado que tiene el raton despues de consumirlo*/

comerQueso(Estado_Raton_I,T_Queso,Estado_Raton_F):-tipoQueso(Estado_Raton_I,T_Queso,Estado_Raton_F).

/**
queso(0, normal).
queso(1, vino).
queso(2, veneno).
*/

/**Base de conocimientos que muestra el comportamiento del raton luego de comer un determinado queso de acuerdo a su estado actual*/

tipoQueso(sobrio,normal,sobrio).
tipoQueso(ebrio,normal,ebrio).
tipoQueso(sobrio,vino,ebrio).
tipoQueso(ebrio,normal,ebrio).
tipoQueso(ebrio,veneno,muerto).
tipoQueso(sobrio,veneno,sobrio).

/**
Base de conocimientos que figura las acciones que puede hacer el raton para agregarlos a una lista simulando que el raton actua por voluntad propia
*/
accion(0,avanzar).
accion(1,giraI).
accion(2,giraD).
accion(3,gira180).

/**
Funcion que genera un movimiento al azar de acuerdo a la base de conocimientos implementado anteriormente
*/

generarMovimiento(A):- random(0,3,X),accion(X,A).


