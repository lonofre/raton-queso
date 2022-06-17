% Archivos importados
:- [mapa].

/*
(X, Y): La posición inicial en el recorrido
Mapa: Cuadrícula 2D donde se hace el recorrido
Movimientos: Lista de los movimientos que se realizan
    hacia la salida o hasta que se encuentre veneno.
*/
recorrido((X,Y), Mapa, Movimientos) :-
    dimensiones(Mapa, Ancho, Alto),
    X >= 0,
    X < Ancho,
    Y >= 0,
    Y < Alto,
    recorrido((X,Y), Mapa, norte, normal, Movimientos).

/*
Dimensiones del mapa
*/
dimensiones(Mapa, Ancho, Alto) :-
    length(Mapa, Alto),
    nth0(0, Mapa, Fila),
    length(Fila, Ancho).

/*
(X, Y): Posición actual del ratón
Mapa: Cuadrícula 2D con la información de los cuadros y quesos
Orientación: En qué dirección se mueve el ratón actualmente
EstadoActual: El estado del ratón (normal, vino, veneno)
Movimientos: Movimientos que ha realizado el ratón
*/
%  Caso Base o donde se detiene la ejecución
recorrido((X, Y), Mapa, _, _, [] ) :-
    tipo_casilla((X, Y), Mapa, salida).

recorrido(_, _, _, veneno, [] ).

% Casos cuando choca con la pared
recorrido((X, Y), Mapa, Orientacion, normal, Movimientos ) :-
    va_chocar((X,Y), Orientacion, Mapa, choca),
     % Checa que no es la salida, para evitar el loop infinito
    no_sale((X, Y), Mapa),
    % Gira hacia la izquierda
    gira(Orientacion, NuevaOrientacion),
    recorrido((X, Y), Mapa, NuevaOrientacion, normal, Movimientos),
    !.

% Casos cuando se mueve normal
recorrido((X, Y), Mapa, Orientacion, normal, NuevosMovimientos ) :-
    va_chocar((X,Y), Orientacion, Mapa, noChoca),
    % Checa que no es la salida, para evitar el loop infinito
    no_sale((X, Y), Mapa),
    % Procede a avanzar
    avanza((X, Y), Orientacion, (Xn, Yn)),
    nuevos_movimientos(Movimientos, Orientacion, NuevosMovimientos),
    tipo_casilla((Xn, Yn), Mapa, CasillaSiguiente),
    CasillaSiguiente \== veneno,
    estado_raton(CasillaSiguiente, EstadoRaton),
    % Actualiza el mapa para borrar los quesos
    % a la posición actual (la que va a dejar)
    come_queso((X, Y), Mapa, MapaActualizado),
    recorrido((Xn, Yn), MapaActualizado, Orientacion, EstadoRaton, Movimientos),
    !.

recorrido((X, Y), Mapa, Orientacion, normal, NuevosMovimientos ) :-
    va_chocar((X,Y), Orientacion, Mapa, noChoca),
    % Checa que no es la salida, para evitar el loop infinito
    no_sale((X, Y), Mapa),
    % Procede a avanzar
    avanza((X, Y), Orientacion, (Xn, Yn)),
    nuevos_movimientos(Movimientos, Orientacion, NuevosMovimientos),
    tipo_casilla((Xn, Yn), Mapa, CasillaSiguiente),
    CasillaSiguiente == veneno,
    estado_raton(CasillaSiguiente, EstadoRaton),
    % Actualiza el mapa para borrar los quesos
    % a la posición actual (la que va a dejar)
    recorrido((Xn, Yn), Mapa, Orientacion, EstadoRaton, Movimientos),
    !.

%
% Casos cuando el ratón está borracho
%
recorrido((X, Y), Mapa, Orientacion, vino, Movimientos) :-
    recorrido((X, Y), Mapa, Orientacion, vino, 7, Movimientos).

/*
Recorrido del ratón cuando está borracho
(X, Y): Posición actual del ratón
Mapa: Cuadrícula 2D con la información de los cuadros y quesos
Orientación: En qué dirección se mueve el ratón actualmente
EstadoActual: El estado del ratón (normal, vino, veneno)
NivelEbriedad: Indica en cuántos movimientos el ratón va a volver a
    la normalidad
Movimientos: Movimientos que ha realizado el ratón
*/
recorrido((X, Y), Mapa, _, _, _, []) :-
    tipo_casilla((X, Y), Mapa, salida).

recorrido((X, Y), Mapa, _, _, _, []) :-
    tipo_casilla((X, Y), Mapa, veneno).

recorrido((X, Y), Mapa, Orientacion, vino, NivelEbriedad, Movimientos) :-
    NivelEbriedad =:= 0,
    no_sale_veneno((X, Y), Mapa),
    come_queso((X, Y), Mapa, MapaActualizado),
    recorrido((X, Y), MapaActualizado, Orientacion, normal, Movimientos).

% Esta borracho y choca
recorrido((X, Y), Mapa, Orientacion, vino, NivelEbriedad, NuevosMovimientos) :-
    NivelEbriedad > 0,
    NuevoNivel is NivelEbriedad - 1,
    % Siempre que la casilla no es salida
    no_sale_veneno((X, Y), Mapa),
    va_chocar((X,Y), Orientacion, Mapa, choca),
    nuevos_movimientos(Movimientos, Orientacion, NuevosMovimientos),
    come_queso((X, Y), Mapa, MapaActualizado),
    % Para el movimiento al azar
    movimiento_azar(NuevaOrientacion),
    recorrido((X,Y), MapaActualizado, NuevaOrientacion, vino, NuevoNivel, Movimientos),
    !.

% Esta borracho y no choca
recorrido((X, Y), Mapa, Orientacion, vino, NivelEbriedad, NuevosMovimientos) :-
    NivelEbriedad > 0,
    NuevoNivel is NivelEbriedad - 1,
    % Siempre que la casilla no es salida
    no_sale_veneno((X, Y), Mapa),
    va_chocar((X,Y), Orientacion, Mapa, noChoca),
    avanza((X, Y), Orientacion, (Xn, Yn)),   
    nuevos_movimientos(Movimientos, Orientacion, NuevosMovimientos),
    come_queso((X, Y), Mapa, MapaActualizado),
    movimiento_azar(NuevaOrientacion),
    recorrido((Xn, Yn), MapaActualizado, NuevaOrientacion, vino, NuevoNivel, Movimientos),
    !.

/*
Hace que el ratón se coma el queso y deje la casilla en vacío
*/
come_queso((X, Y), Mapa, MapaActualizado) :-
    casilla_actualizada((X, Y), Mapa, vacio, MapaActualizado).


/*
Actualiza los movimientos dada una orientación
Movimientos: Lista actual
Orientación: Elemento a agregar
MovimientosActualizados: Lista con la orientación agregada 
    al principio de la lista
*/
nuevos_movimientos([H|T], Orientacion, MovimientosActualizados) :-
    append([Orientacion], [H|T], MovimientosActualizados).

nuevos_movimientos([], Orientacion, Movimientos) :-
    append([], [Orientacion], Movimientos).

/*
El estado del ratón:
TipoCasilla: La casilla donde está el ratón.
Estado: Cómo se encuentra el ratón después de pasar esa casilla.
*/
estado_raton(vacio, normal).
estado_raton(normal, normal).
% Porque esta en estado normal
estado_raton(veneno, normal).
estado_raton(vino, vino).
estado_raton(salida, normal).


/*
Base de conocimientos para hacer girar
al ratón hacia la izquierda
*/
gira(norte, oeste).
gira(oeste, sur).
gira(sur, este).
gira(este, norte).

/*
Genera un movimiento al azar
*/
movimiento_azar(Movimiento) :-
    random(0, 4, X),
    movimiento(X, Movimiento).

/*
Enuméración de los movimientos
*/
movimiento(0, norte).
movimiento(1, oeste).
movimiento(2, sur).
movimiento(3, este).

/* Avanza según la orientación */
avanza((X,Yi), norte,(X,Yf)) :-
    Yf is Yi + 1.
avanza((Xi,Y), este,(Xf,Y)) :-
    Xf is Xi + 1.
avanza((X,Yi), sur,(X,Yf)) :-
    Yf is Yi - 1.
avanza((Xi,Y), oeste,(Xf,Y)) :-
    Xf is Xi - 1.


/* Auxiliar que dice si se va a chocar con pared
(Xi, Yi): Posición actual del ratón
Orientación: Orientación actual
M: Mapa
Acción: choca|noChoca dependiendo de lo anterior
*/ 
va_chocar((_,Yi), norte, M, choca) :-
    length(M,A),
    Yi =:= A-1.

va_chocar((Xi,_), este, [H|_], choca) :-
    length(H,A),
    Xi =:= A-1.

va_chocar((0,_), oeste, _, choca).

va_chocar((_,0), sur, _, choca).

va_chocar((_,Yi), norte, M, noChoca) :-
    length(M,A),
    Yi =\= A-1.
va_chocar((Xi,_), este, [H|_], noChoca) :-
    length(H,A),
    Xi =\= A-1.

va_chocar((X,_), oeste, _, noChoca) :-
    X =\= 0.

va_chocar((_,Y), sur, _, noChoca) :-
    Y =\= 0.

/**
Dice si el ratón no sale del mapa por haber llegado
a la posición de la salida o a un lugar donde hay queso, donde:
(X,Y): es la posición del ratón
M: es el mapa con respecto al cual se da la posición
*/
no_sale_veneno((X, Y), Mapa) :-
    tipo_casilla((X, Y), Mapa, CasillaActual),
    CasillaActual \== salida,
    CasillaActual \== veneno.

no_sale((X, Y), Mapa) :-
    tipo_casilla((X, Y), Mapa, CasillaActual),
    CasillaActual \== salida.