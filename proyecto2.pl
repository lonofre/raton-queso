% Archivos importados
:- [mapa].

/*
*
iRecRat(N,M,D) dice que un ratón comienza un recorrido donde:
N es el ancho del mapa en el que se realiza el recorrido
M es el largo del mapa en el que se realiza el recorrido
D es la posición inicial del ratón, de la forma (X,Y)
*/
iRecRat(N,M,D) :- 
    crear_mapa(N, M, Mapa),
    generarOri(O),    
	write(Mapa),
    write('\n |\n'),
    write(' Ebriedad: '),
    write(0),
    recRat(D,O,0,Mapa,true,false).



/*
*
recRat((X,Y),O,E,M,V,S) dice que un ratón realiza un recorrido donde:
-(X,Y) es la posición del ratón
-O es la orientación del ratón
-E es el nivel de ebriedad del ratón
-M es el mapa en el que se realiza el recorrido
-V es el estado de vida del ratón
-S es el estado de llegada del ratón a la salida
*/
recRat(_,_,_,_,false,_) :-
	write('\n'),
	write('*MUERE*'),
	write('\n').
recRat(_,_,_,_,_,true) :-
	write('\n'),
	write('*SALE*'),
	write('\n').
recRat((Xi,Yi),Oi,Ei,M,true,false) :-
    orientaYAvanza((Xi,Yi),Oi,M,Ei,Of,(Xf,Yf),Em),
    vaComerAlcohol((Xf,Yf),M,Alcohol),
    noVaComerVeneno((Xf,Yf),M,Em,NoVeneno),
    comeQueso((Xf,Yf),M,MapaMenosQueso),
    Ef is Em+Alcohol,
    write(' |\n'),
    write(' Ebriedad: '),
    write(Ef),
    sale((Xf,Yf),M,Sale),
    recRat((Xf,Yf),Of,Ef,MapaMenosQueso,NoVeneno,Sale).



/**
orientaYAvanza((Xi,Yi),Oi,M,Ei,Om,(Xf,Yf),Em) dice que el ratón fija 
la dirección hacia la que intentará avanzar e intenta avanzar, donde:
-(Xi,Yi) es la posición inicial del ratón
-Oi es la orientación inicial del ratón
-M es el mapa en el que se realiza el recorrido
-Ei es el nivel de ebriedad del ratón antes de intentar avanzar
-Om es la orientación en la que el ratón intentará avanzar
-(Xf,Yf) es la posición final del ratón
-Em es el nivel de ebriedad del ratón después de intentar avanzar
    
Si al intentar avanzar con la orientación inicial Oi no va a chocar 
con una pared, no cambia orientación y avanza.
Si sí va a chocar con una pared hay 3 casos:
- Si no está ebrio (Ei=:=0) y no está en una esquina de manera que al 
girar a la izquierda vaya a chocar también, hace que la orientación Om 
sea Oi girada ala izquierda y luego avanza.
- Si la ebriedad Ei es mayor a 0, la orientación no cambia y el ratón 
choca con la pared hasta que pase la borrachera.

En todo caso disminuye la ebriedad Ei en 1 si era mayor a 0 y guarda 
ese valor en Em después de intentar avanzar.
*/
%% Caso sin pared
orientaYAvanza((Xi,Yi),Oi,M,Ei,Of,(Xf,Yf),Ef) :-
    vaChocar((Xi,Yi),Oi,M,false),
    avanza((Xi,Yi),Oi,(Xf,Yf)),
    bajaAlcohol(Ei,Ef),
    desorientaPorAlcohol(Oi,Ef,Of).    
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
orientaYAvanza((X,Y),O,M,Ei,O,(X,Y),Em) :-
    Ei =\= 0,
    vaChocar((X,Y),O,M,true),
    choca((X,Y),O,(X,Y)),     
    bajaAlcohol(Ei,Em).                       

/*Auxiliar que dice si se va a chocar con pared*/ 
vaChocar((_,Yi),north,M,true) :-
    length(M,A),
    Yi =:= A-1.
vaChocar((Xi,_),east,[H|_],true) :-
    length(H,A),
    Xi =:= A-1.
vaChocar((0,_),west,_,true).
vaChocar((_,0),south,_,true).

vaChocar((_,Yi),north,M,false) :-
    length(M,A),
    Yi =\= A-1.
vaChocar((Xi,_),east,[H|_],false) :-
    length(H,A),
    Xi =\= A-1.
vaChocar((X,_),west,_,false) :-
    X =\= 0.
vaChocar((_,Y),south,_,false) :-
    Y =\= 0.

/*Auxiliar que dice que se avanza en la orientación dada*/ 
avanza((X,Yi),north,(X,Yf)) :-
    Yf is Yi+1,
    write('\n ('),
    write((X,Yi)),
    write(') north ('),
    write((X,Yf)),
    write(')\n').
avanza((Xi,Y),east,(Xf,Y)) :-
    Xf is Xi+1,
    write('\n ('),
    write((Xi,Y)),
    write(') east ('),
    write((Xf,Y)),
    write(')\n').
avanza((X,Yi),south,(X,Yf)) :-
    Yf is Yi-1,
    write('\n ('),
    write((X,Yi)),
    write(') south ('),
    write((X,Yf)),
    write(')\n').
avanza((Xi,Y),west,(Xf,Y)) :-
    Xf is Xi-1,
    write('\n ('),
    write((Xi,Y)),
    write(') west ('),
    write((Xf,Y)),
    write(')\n').

/**Auxiliar que dice que se choca en la orientación dada*/ 
choca((X,Y),O,(X,Y)) :- 
    write('\n -'),
    write((X,Y)),
    write(O),
    write((X,Y)),
    write('-\n'),
    write('*Choca con la pared*').
    
/*Auxiliar que dice que si el nivel de alcohol es mayor a 0, entonces
 se disminuye en 1*/    
bajaAlcohol(0,Em) :- Em is 0.
bajaAlcohol(Ei,Em) :- Ei =\= 0, Em is Ei-1.
    


/**
vaComerAlcohol((X,Y),M,Alcohol) dice cuanto aumentará el nivel de 
ebriedad del ratón al comer lo que encuentra donde:
-(X,Y) es la posición donde el ratón encuentra lo que comerá
-M es el mapa en el que se encuentra la posición
-Alcohol es el valor en que aumentará el nivel de ebriedad
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
noVaComerVeneno((X,Y),M,Em,NoVeneno) dice si un ratón va a no comer
veneno donde:
-(X,Y) es la posición donde el ratón puede encontrar veneno para comer
-M es el mapa con respecto al cuál se encuentra la posición
-Em es el nivel de ebriedad del ratón
-NoVeneno es true si no comerá veneno y false si sí lo comerá
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
comeQueso((X,Y),M,MapaMenosQueso) dice que el queso en el mapa fue comido y por lo tanto desapareció, donde:
-(X,Y) es la posición en que se encontraba el queso
-M es el mapa con respecto al cuál se encuentra la posición
-MapaMenosQueso es el resultado de quitar el queso al mapa
*/
comeQueso((X,Y),M,MapaMenosQueso) :-
    nth0(Y,M,Fila),
    remplazar(Fila,X,vacio,FilaMenosQueso),
    remplazar(M,Y,FilaMenosQueso,MapaMenosQueso),
    write('\n'),
    write('\n'),
    write(MapaMenosQueso),
    write('\n').



/**
desorientaPorAlcohol(Om,Ef,Of) dice como cambia la orientación de un
ratón por efecto de su nivel de ebriedad, donde
-Om es la orientación del ratón antes del cambio si lo hay
-Ef es el nivel de ebriedad del ratón
-Of es la orientación del ratón después del cambio si lo hay
*/
desorientaPorAlcohol(O,0,O).
desorientaPorAlcohol(_,Ef,Of) :-
    Ef > 0,
    generarOri(Of).



/**
sale((X,Y),M,Sale) dice si el ratón sale del mapa por haber llegado
a la posición de la salida en éste, donde:
-(X,Y) es la posición del ratón
-M es el mapa con respecto al cual se da la posición
-Sale es true si el mapa tiene la salida en la posición del ratón y
 false en otro caso
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





/*
Base de conocimientos que contiene las respectivas rotaciones hacia 
la izquierda de acuerdo a la dirección que está mirando el ratón
*/
giro_izq(north,west).
giro_izq(south,east).
giro_izq(east,north).
giro_izq(west,south).

/*
Base de conocimientos que contiene las posibles orientaciones.
*/
ori(0,west).
ori(1,north).
ori(2,east).
ori(3,south).

/**
generarOri(A) dice que se genera una orientación al azar usando la base de conocimientos anterior, donde A es la orientación generada.
*/
generarOri(A) :- random(0,4,X),ori(X,A).

