% Archivos importados
:- [mapa].

/*
*
Predicado que dice que recorrido de un ratón en un mapa comienza.
N: ancho del mapa en el que se realiza el recorrido
M: largo del mapa en el que se realiza el recorrido
D: posición del ratón, de la forma (X,Y)
*/
iRecRat(N,M,D) :- 
    crear_mapa(N, M, Mapa),
    generarOri(O),    
	write(Mapa),
    recRat(D,O,0,Mapa,true,false).



/*
*
recRat((X,Y),O,E,M,V,S)
dice que un ratón realiza un recorrido donde:
-(X,Y) es la posición del ratón
-O es la orientación del ratón
-E es el nivel de ebriedad del ratón
-M es el mapa en el que se realiza el recorrido
-V es el estado de vida del ratón
-S es el estado de llegada del ratón a la salida
*/
recRat(_,_,_,_,false,_) :-
	write(-muere).
recRat(_,_,_,_,_,true) :-
	write(-sale).
recRat((Xi,Yi),Oi,Ei,M,true,false) :-
    orientaYAvanza((Xi,Yi),Oi,M,Ei,Om,(Xf,Yf),Em),
    vaComerAlcohol((Xf,Yf),M,Alcohol),
    noVaComerVeneno((Xf,Yf),M,Em,NoVeneno),
    comeQueso((Xi,Yf),M,MapaMenosQueso),
    Ef is Em+Alcohol,
    write(Em),
    desorientaPorAlcohol(Om,Ef,Of),
    sale((Xf,Yf),M,Sale),
    recRat((Xi,Yf),Of,Ef,MapaMenosQueso,NoVeneno,Sale).



/**
orientaYAvanza((Xi,Yi),Oi,M,Ei,Om,(Xf,Yf),Em)
dice que el ratón fija la dirección hacia la que intentará avanzar
e intenta avanzar, donde:
-(Xi,Yi) es la posición inicial del ratón
-Oi es la orientación inicial del ratón
-M es el mapa en el que se realiza el recorrido
-Ei es el nivel de ebriedad del ratón antes de intentar avanzar
-Om es la orientación en la que el ratón intentará avanzar
-(Xf,Yf) es la posición final del ratón
-Em es el nivel de ebriedad del ratón después de intentar avanzar
    
Si al intentar avanzar con la orientación inicial Oi no va a chocar con una pared, no cambia orientación y avanza.
Si sí va a chocar con una pared hay 3 casos:
- Si no está ebrio (Ei=:=0) y no está en una esquina de manera que al girar a la izquierda vaya a chocar también, hace que la orientación Om sea Oi girada ala izquierda y luego avanza.
- Si la ebriedad Ei es mayor a 0, la orientación no cambia y el ratón choca con la pared hasta que pase la borrachera.

En cualquier caso, imprime la orientaci'on en que intentó moverse con 
    write(Om).
En todo caso disminuye la ebriedad Ei en 1 si era mayor a 0 y 
    guarda ese valor en Em después de intentar avanzar

AQU'I NO SE HACE QUE LA EBRIEDAD ALTERE ORIENTACI'ON, ESO 
PASA EN desorientaPorAlcohol(...)
*/
%% Caso sin pared
orientaYAvanza((Xi,Yi),O,M,Ei,O,(Xf,Yf),Em) :-
    vaChocar((Xi,Yi),O,M,false),
    avanza((Xi,Yi),O,(Xf,Yf)),
    bajaAlcohol(Ei,Em).    
%% Caso con pared no esquina que requiere giro doble sin ebriedad
orientaYAvanza((Xi,Yi),Oi,M,Ei,Om,(Xf,Yf),Em) :-
    Ei =:= 0,
    vaChocar((Xi,Yi),Oi,M,true),
    giro_izq(Oi,Om),
    vaChocar((Xi,Yi),Om,M,false),
    avanza((Xi,Yi),Om,(Xf,Yf)),     
    bajaAlcohol(Ei,Em).   
%% Caso con pared esquina que requiere giro doble sin ebriedad
orientaYAvanza((Xi,Yi),Oi,M,Ei,Om,(Xf,Yf),Em) :-
    Ei =:= 0,
    vaChocar((Xi,Yi),Oi,M,true),
    giro_izq(Oi,Om1),
    vaChocar((Xi,Yi),Om1,M,true),
    giro_izq(Om1,Om),
    avanza((Xi,Yi),Om,(Xf,Yf)),     
    bajaAlcohol(Ei,Em).   
%% Caso con pared (cualquiera) con ebriedad
orientaYAvanza((X,Y),O,M,Ei,O,(X,Y),0) :-
    Ei =\= 0,
    vaChocar((X,Y),O,M,true),
    choca(Ei,O).                       

/*Auxiliar que dice si se va a chocar con pared*/ 
vaChocar((_,Yi),north,M,true) :-
    write(vACHOCAR1),
    length(M,A),
    Yi =:= A-1.
vaChocar((Xi,_),east,[H|_],true) :-
    write(vACHOCAR2),
    length(H,A),
    Xi =:= A-1.
vaChocar((0,_),west,_,true):-
    write(vACHOCAR3).
vaChocar((_,0),south,_,true):-
    write(vACHOCAR4).

vaChocar((_,Yi),north,M,false) :-
    length(M,A),
    Yi =\= A-1.
vaChocar((Xi,_),east,[H|_],true) :-
    length(H,A),
    Xi =\= A-1.
vaChocar((X,_),west,_,false) :-
    X =\= 0.
vaChocar((_,Y),south,_,false) :-
    Y =\= 0.

/*Auxiliar que dice que se avanza en la orientación dada*/ 
avanza((X,Yi),north,(X,Yf)) :-
    Yf is Yi+1,
    write('\n -'),
    write(north),
    write((X,Yf)),
    write('-\n').
avanza((Xi,Y),east,(Xf,Y)) :-
    Xf is Xi+1,
    write('\n -'),
    write(east),
    write((Xf,Y)),
    write('-\n'). 
avanza((X,Yi),south,(X,Yf)) :-
    Yf is Yi-1,
    write('\n -'),
    write(south),
    write((X,Yf)),
    write('-\n').
avanza((Xi,Y),west,(Xf,Y)) :-
    Xf is Xi-1,
    write(-),
    write(west),
    write((Xf,Y)),
    write('-\n').

/**Auxiliar que dice que se choca en la orientación dada
debería imprimir Ei veces la orientación O. 
[NOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO est'a bien implementada, es relleno]
*/ 
choca(Ei,O) :-     
    write(ebriochoca),     
    write(O)  .
    
/*Auxiliar que dice que se baja el nivel de alcohol si es mayor a 0, en 1*/    
bajaAlcohol(0,Em) :- Em is 0.
bajaAlcohol(Ei,Em) :- Ei =\= 0, Em is Ei-1,
    write(\v)     .
    


/**
vaComerAlcohol((X,Y),M,Alcohol)
Alcohol es cuanto aumentará el nivel de ebriedad de un ratón al comer
el queso si lo hay en la posición dada (X,Y) del mapa M
*/
vaComerAlcohol((X,Y),M,7) :-
    nth0(Y,M,Fila),
    nth0(X,Fila,vino).
vaComerAlcohol((X,Y),M,0) :-
    nth0(Y,M,Fila),
    nth0(X,Fila,vacio).
vaComerAlcohol((X,Y),M,0) :-
    nth0(Y,M,Fila),
    nth0(X,Fila,veneno).
vaComerAlcohol((X,Y),M,0) :-
    nth0(Y,M,Fila),
    nth0(X,Fila,normal).
vaComerAlcohol((X,Y),M,0) :-
    nth0(Y,M,Fila),
    nth0(X,Fila,salida).



/**
noVaComerVeneno((Xf,Yf),M,Em,NoVeneno)
NoVeneno dice si un ratón de ebriedad Em va a no comer veneno estando en la posición (Xf,Yf) del mapa M
*/
noVaComerVeneno((X,Y),M,Em,false) :-
    Em > 0,
    nth0(Y,M,Fila),
    nth0(X,Fila,veneno).
noVaComerVeneno((X,Y),M,Em,true) :-
    Em > 0,
    nth0(Y,M,Fila),
    nth0(X,Fila,vacio).
noVaComerVeneno((X,Y),M,Em,true) :-
    Em > 0,
    nth0(Y,M,Fila),
    nth0(X,Fila,normal).
noVaComerVeneno((X,Y),M,Em,true) :-
    Em > 0,
    nth0(Y,M,Fila),
    nth0(X,Fila,vino).
noVaComerVeneno((X,Y),M,Em,true) :-
    Em > 0,
    nth0(Y,M,Fila),
    nth0(X,Fila,salida).
noVaComerVeneno(_,_,0,true).



/**
comeQueso((X,Y),M,MapaMenosQueso)
MapaMenosQueso es el resultado de quitar el queso en (X,Y) a M
*/
comeQueso((X,Y),M,MapaMenosQueso) :-
    nth0(Y,M,Fila),
    remplazar(Fila,X,vacio,FilaMenosQueso),
    remplazar(M,Y,FilaMenosQueso,MapaMenosQueso).








/**
desorientaPorAlcohol(Om,Ef,Of)
Da una dirección aleatoria en Of si hay ebriedad mayor a 0 en Ef,
en otro caso Of es Om sin alterarse
*/
desorientaPorAlcohol(O,0,O).
desorientaPorAlcohol(_,Ef,Of) :-
    Ef > 0,
    generarOri(Of).



/**
sale((Xf,Yf),M,Sale)
Sale es true si (Xf,Yf) es salida en M.
*/
sale((X,Y),M,true) :-
    nth0(Y,M,Fila),
    nth0(X,Fila,salida).
sale((X,Y),M,false) :-
    nth0(Y,M,Fila),
    nth0(X,Fila,vino).
sale((X,Y),M,false) :-
    nth0(Y,M,Fila),
    nth0(X,Fila,vacio).
sale((X,Y),M,false) :-
    nth0(Y,M,Fila),
    nth0(X,Fila,veneno).
sale((X,Y),M,false) :-
    nth0(Y,M,Fila),
    nth0(X,Fila,normal).










/**Realiza las respectivas 
rotaciones hacia la izquierda de acuerdo a la direccion que está mirando el raton*/
giro_izq(north,west).
giro_izq(south,east).
giro_izq(east,north).
giro_izq(west,south).



/**
Base de conocimientos que tiene las posibles orientaciones.
*/
ori(0,west).
ori(1,north).
ori(2,east).
ori(3,south).

/**
Genera una orientación al azar usando la base de conocimientos anterior.
*/
generarOri(A):- random(0,4,X),ori(X,A).


