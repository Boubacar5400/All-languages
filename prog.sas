data work.base;
set work.base;
log_y=log(y);
dlog_y=log_y-lag(log_y);

by pays date;
if first.pays then do;
dlog_y=.;
dx=.;
dz=.;
end;
run;

data work.base;
set work.base;
if z^=. & x^=. & y^=.;
run;

proc sgpanel data=work.base;
panelby pays;
histogram y;
density y;
density y / type=kernel;
run;
proc sgplot data=work.base;
series Y=y X= date / group=pays;
run;
%macro z(var);
proc glm data=work.base;
class pays date;
model &var = pays date;
run;
%mend;
%z(x); %z(z);
proc corr data= work.base plots=scatter(ellipse=none);
var ;
run;

/* pr�parations de l'estimateur within */

proc univariate data=work.base;
var ;
by pays;
output out=work.moyenne mean=moy_x moy_y moy_z;
run;

data work.base;
merge work.base work.moyenne;
by pays;
x_w=x-moy_x;
z_w=z-moy_z;
y_w=y-moy_y;
run;

proc corr data=work.base plots= scatter(ellipse=none);
var y_w x_w z_w;
run;

/* Les r�gressions des mod�les*/
/* Mod�le sans effets */
/* moindre carr� ordinaire */

proc reg data=work.base;
model / HCC HCCMETHOD=3 SPEC;
run;
 
/* Mod�le � effets fixes */
/* estimateur within des effets fixes */

proc panel data=work.base;
id pays date;
model   / fixtwo HCCME=4;
run;


/* estimateur en diff�rence premier */

proc reg data= work.base;
model  / HCC HCCMETHOD=3;
run;

/* Mod�le � effets al�atoire */

proc panel data=work.base;
id pays date;
model  / rantwo;
run;

proc panel data=work.base;
id pays date;
model  / rantwo BP;
run;



