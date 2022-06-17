% *-------------------*
% | PARTE DE LEONARDO |
% *-------------------*

/** Función que no gira, no modifica la irientación*/
movimientoGiro(Oi, noGira, Oi).

/**Funcion que hace girar hacia la izquierda al raton, modificando la orientacion*/

movimientoGiro(Oi,giraI,Of):- giroIzq(Oi,giraI,Of).

/**Funcion que hace girar hacia la derecha al raton, así como su orientacion*/

movimientoGiro(Oi,giraD,Of):- giroDer(Oi,giraD,Of).

/**Funcion que hace al raton dar media vuelta, de acuerdo a su orientacion*/

movimientoGiro(Oi,gira180,Of):- giro180(Oi,gira180,Of).

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

/**
Base de conocimientos que figura las acciones que puede hacer el raton para agregarlos a una lista simulando que el raton actua por voluntad propia
*/
accion(0,noGira).
accion(1,giraI).
accion(2,giraD).
accion(3,gira180).

/**
Funcion que genera un movimiento al azar de acuerdo a la base de conocimientos implementado anteriormente
*/

generarMovimientoGiro(A):- random(0,3,X),accion(X,Acc), A = Acc.

/**Funcion que simula un paso al frente que hace el raton sin alterar su orientacion*/

movimiento((Xi,Yi),north,avanzar,(Xi,Yf)) :- Yf is Yi+1.
movimiento((Xi,Yi),south,avanzar,(Xi,Yf)) :- Yf is Yi-1.
movimiento((Xi,Yi),east,avanzar,(Xf,Yi))  :- Xf is Xi+1.
movimiento((Xi,Yi),west,avanzar,(Xf,Yi))  :- Xf is Xi-1.

/**Base de conocimientos que muestra el comportamiento del raton luego de comer un determinado queso de acuerdo a su estado actual*/

tipoQueso(sobrio,normal,sobrio).
tipoQueso(sobrio,veneno,sobrio).
tipoQueso(sobrio,ron,ebrio).

tipoQueso(ebrio,normal,ebrio).
tipoQueso(ebrio,veneno,muerto).
tipoQueso(ebrio,ron,ebrio).

/**Funcion auxiliar que revisa el tipo de queso a comer y devolviendo el estado que tiene el raton despues de consumirlo*/

comerQueso(Estado_Raton_I,T_Queso,Estado_Raton_F):-tipoQueso(Estado_Raton_I,T_Queso,Est), Estado_Raton_F = Est.



% ------------------------------------------------------------------------------------------------------------------------------------------------------
% *-------------------*
% | PARTE DE SAMUEL   |
% *-------------------*
/*
** Representación de Mini Laberinto de Pruebas **

I   : Inicio.
S   : Salida
QR  : Queso con Ron.
QV  : Queso con veneno.
Q   : Queso solo.

---------------------------
6 |   |   |   |   |   |   |
---------------------------
5 |   |   |   |   | Q | S |
---------------------------
4 |   | Q |   |   |   |   |
---------------------------
3 |   |QV |   |   |   |   |
---------------------------
2 |   |   |   |   |   | Q |
---------------------------
1 | I |   |QV |QR |   |   |
---------------------------
    1   2   3   4   5    6

*/

/*
Función que nos indica qué es una casilla dentro del mapa.
SOLO PARA PRUEBAS
*/
% Casillas importantes
queEs((1,1),Qs) :- Qs = inicio.
queEs((6,5),Qs) :- Qs = salida.
% Casillas con Quesos
queEs((2,4),Qs) :- Qs = normal.
queEs((4,2),Qs) :- Qs = normal.
queEs((5,5),Qs) :- Qs = normal.
queEs((6,2),Qs) :- Qs = normal.
queEs((2,3),Qs) :- Qs = normal.

queEs((4,1),Qs) :- Qs = ron.

queEs((3,1),Qs) :- Qs = veneno.
% Casillas fuera del laverinto
queEs((X,_),Qs) :- (X<1), Qs = fuera.
queEs((_,Y),Qs) :- (Y<1), Qs = fuera.
queEs((X,_),Qs) :- (X>6), Qs = fuera.
queEs((_,Y),Qs) :- (Y>6), Qs = fuera.
% % Casillas pared
% queEs((X,_),Qs) :- (X=:=0), Qs = pared.
% queEs((X,_),Qs) :- (X=:=7), Qs = pared.
% queEs((_,Y),Qs) :- (Y=:=0), Qs = pared.
% queEs((_,Y),Qs) :- (Y=:=7), Qs = pared.
% Casillas dentro del laberinto pero sin queso
queEs(_,Qs) :- Qs = vacio.



/*
Función que nos inica si hay queso en una casilla X,Y
R : regresa el tipo de queso en la casilla. En caso de que no
    haya queso la función regresa false.
*/
hayQueso((X,Y),normal) :- queEs((X,Y),normal).
hayQueso((X,Y),ron)   :- queEs((X,Y),ron).
hayQueso((X,Y),veneno) :- queEs((X,Y),veneno).

/*
Función que nos indica si hay una pared enfrente del ratón.
(X,Y) : coodenadas (X,Y) en las que se encuentra el ratón.
Oi    : orientación del ratón.
*/
paredEnfrente((X,Y),Oi) :-
    movimiento((X,Y),Oi,avanzar,(Xf,Yf)),
    queEs((Xf,Yf), fuera).

/*
Función que al llegar a topar con pared, da las vueltas necesarias para
poder seguir avanzando.
(X,Y) : coordenadas (X,Y) en las que se encuentra el ratón.
Oi    : orientación inicial del ratón.
Of    : orientación final, luego de girar a la izquierda n veces.
*/
buscaIzquierda((X,Y), Oi, Of) :-
    movimientoGiro(Oi,giraI,Oc),
    movimiento((X,Y),Oc, avanzar, (Xc,Yc)),
    queEs((Xc,Yc),fuera),
    buscaIzquierda((X,Y),Oc,Of).

buscaIzquierda((X,Y), Oi, Of) :-
    movimientoGiro(Oi,giraI,Oc),
    movimiento((X,Y),Oc, avanzar, (Xc,Yc)),
    queEs((Xc,Yc),Qs),
    Qs \= fuera,
    Of = Oc.

/*
Función que hace dar al ratón 7 pasos en dirección aleatoria.
*/
movAleatorio((X,Y), _, _, PsF) :-
    hayQueso((X,Y),Tq),
    comerQueso(ebrio, Tq, muerto),
    write("\n\nEl ratón murio.\nPasos realizados antes de la muerte:\n\n"),
    write(PsF).

movAleatorio((X,Y), _, _, PsI) :-
    queEs((X,Y), salida),
    write("\n\nEl rató encontró la salida estando ebrio. \nPasos realizados: \n\n"),
    write(PsI).

movAleatorio((X,Y), Oi, 1, PsI) :-
    generarMovimientoGiro(Giro),
    movimientoGiro(Oi,Giro,Of),
    movimiento((X,Y), Of, avanzar, (Xf,Yf)),
    append(PsI, [(Xf,Yf)], PsF),
    write("\nSe le bajo la borrachera al raton luego de 7 pasos aleatirios"),
    buscarSalida((Xf,Yf), Of, sobrio, PsF).

movAleatorio((X,Y), Oi, _, PsI) :-
    paredEnfrente((X,Y),Oi),
    write("\ntap tap tap... \n Se estrello contra la pared y se le pasó la borrachera al ratón.\n"),
    buscaIzquierda((X,Y), Oi, Of),
    movimiento((X,Y), Of, avanzar, (Xf,Yf)),
    append(PsI, [(Xf,Yf)], PsF),
    buscarSalida((Xf,Yf), Of, sobrio, PsF).

movAleatorio((X,Y), Oi, PaD, PsI) :-
    generarMovimientoGiro(Giro),
    movimientoGiro(Oi,Giro,Of),
    movimiento((X,Y), Of, avanzar, (Xf,Yf)),
    append(PsI, [(Xf,Yf)], PsF),
    PaF = PaD - 1, 
    movAleatorio((Xf,Yf), Of, PaF, PsF).


/*
Función que hace buscar al raton la salida del laberinto.
X    : coordenada X en la que se encuentra el ratón.
Y    : coordenada Y en la que se encuentra el ratón.
Oi   : orientación inicial del ratón.
EstI : estado inicial en el que se encuentra el ratón.
PsI  : lista de los pasos realizador por el ratón hasta ahora.
*/

buscarSalida((X,Y), _, _, PsI) :-
    queEs((X,Y), salida),
    write("\n\nEl rató encontró la salida. \nPasos realizados: \n\n"),
    write(PsI).

buscarSalida((X,Y), Oi, sobrio, PsI) :-
    paredEnfrente((X,Y),Oi),
    buscaIzquierda((X,Y), Oi, Of),
    movimiento((X,Y), Of, avanzar, (Xf,Yf)),
    append(PsI, [(Xf,Yf)], PsF),
    buscarSalida((Xf,Yf), Oi, sobrio, PsF).

buscarSalida((X,Y), Oi, EstI, PsI) :-
    hayQueso((X,Y),Tq),
    comerQueso(EstI, Tq, ebrio),
    write("\nEl ratón se puso ebrio"),
    movAleatorio((X,Y), Oi, 7, PsI).

buscarSalida((X,Y), Oi, sobrio, PsI) :-
    queEs((X,Y), vacio),
    movimiento((X,Y), Oi, avanzar, (Xf,Yf)),
    append(PsI, [(Xf,Yf)], PsF),
    buscarSalida((Xf,Yf), Oi, sobrio, PsF).

buscarSalida((X,Y), Oi, EstI, PsI) :- 
    hayQueso((X,Y),Tq),
    comerQueso(EstI, Tq, sobrio),
    movimiento((X,Y), Oi, avanzar, (Xf,Yf)),
    append(PsI, [(Xf,Yf)], PsF),
    buscarSalida((Xf,Yf), Oi, sobrio, PsF).
