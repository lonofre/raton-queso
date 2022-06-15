% Archivos importados
:- [mapa].

/*
Para los movimientos pueden asignarse un numero para poder generar 
un movimiento al azar para simular el movimiento del raton
*/

/*
*
Movimientos para el ratón dependiendo si está sobrio o ebrio.
*/
estado((X,Y),Orientacion_Inicial,C,Est_Raton,P,O,Est_Raton) :-
estado_auxiliar((X,Y),Orientacion_Inicial,C,Est_Raton,P,O,Est_Raton).

estado_auxiliar((Xi,Yi),Oi,[],Est_Raton,(Xi,Yi),Oi,_).
estado_auxiliar((Xi,Yi),Oi,[C|T],Est_Raton,Pf,Of,_) :-
	movimiento((Xi,Yi),Oi,C,Est_Raton,P1,O1),
    estado_auxiliar(P1,O1,T,Est_Raton,Pf,Of,_).


/**Simula un paso al frente 
que hace el raton sin alterar su orientacion*/
movimiento((Xi,Yi),north,avanzar,Est_Raton,(Xi,Yf),north) :-
    Yf is Yi+1.

movimiento((Xi,Yi),south,avanzar,Est_Raton,(Xi,Yf),south) :-
    Yf is Yi-1.

movimiento((Xi,Yi),east,avanzar,Est_Raton,(Xf,Yi),east) :-
    Xf is Xi+1.

movimiento((Xi,Yi),west,avanzar,Est_Raton,(Xf,Yi),west) :-
    Xf is Xi-1.

/**Hace girar hacia la izquierda al raton, 
modificando la orientacion*/

movimiento((Xi,Yi),Oi,giraI,Est_Raton,(Xi,Yi),Of) :-
    giro_izq(Oi,giraI,Of).

/**Hace girar hacia la derecha al raton, así como su orientacion*/

movimiento((Xi,Yi),Oi,giraD,Est_Raton,(Xi,Yi),Of) :-
    giro_der(Oi,giraD,Of).

/**Hace al raton dar media vuelta, de acuerdo a su orientacion*/

movimiento((Xi,Yi),Oi,gira180,Est_Raton,(Xi,Yi),Of) :-
    giro180(Oi,gira180,Of).

/**Hace al raton comer un queso*/

movimiento((Xi,Yi),Oi,comer_queso,Est_Raton,(Xi,Yi),Of) :-
    comer_queso(Est_Raton,T_Queso,Estado_Raton_F).

/**Auxiliar que realiza las respectivas rotaciones 
de acuerdo a la direccion que está mirando el raton*/
giro180(north,gira180,south).
giro180(south,gira180,north).
giro180(east,gira180,west).
giro180(west,gira180,east).

/**Auxiliar que realiza las respectivas 
rotaciones hacia la izquierda de acuerdo a la direccion que está mirando el raton*/
giro_izq(north,giraI,west).
giro_izq(south,giraI,east).
giro_izq(east,giraI,north).
giro_izq(west,giraI,south).

/**Auxiliar que realiza las respectivas rotaciones 
hacia la derecha de acuerdo a la direccion que está mirando el raton*/

giro_der(north,giraD,east).
giro_der(south,giraD,west).
giro_der(east,giraD,south).
giro_der(west,giraD,north).


/**Auxiliar que muestra el comportamiento 
del raton luego de comer un determinado queso de acuerdo a su estado actual*/
comer_queso(sobrio,normal,sobrio).
comer_queso(ebrio,normal,ebrio).
comer_queso(sobrio,vino,ebrio).
comer_queso(ebrio,vino,ebrio).
comer_queso(ebrio,veneno,muerto).
comer_queso(sobrio,veneno,sobrio).

/**
Base de conocimientos que figura las acciones que puede hacer 
el raton para agregarlos a una lista simulando que el raton actua por voluntad propia
*/
accion(0,avanzar).
accion(1,giraI).
accion(2,giraD).
accion(3,gira180).

/**
Genera un movimiento al azar de acuerdo 
a la base de conocimientos implementado anteriormente
*/
generarMovimiento(A):- random(0,3,X),accion(X,A).


