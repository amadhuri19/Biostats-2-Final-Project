proc import
DATAFILE = "/home/u63569870/Biostats 2 Projects/Project 1/Surgery Timing.csv"
OUT = surgerytiming
DBMS = csv
REPLACE;
GETNAMES = yes;
run;

data surgerytiming1; /*recoding month variable*/
set surgerytiming;
if month in (1, 2, 3) then season = "Winter";
else if month in (4, 5, 6) then season = "Spring";
else if month in (7, 8, 9) then season = "Summer";
else if month in (10, 11, 12) then season = "Fall";
run;

proc format; /*Table 1*/
VALUE genderf 1 = " Male"
0 = " Female";
VALUE racef 1 = "Caucasian"
2 = "African American"
3 = "Other";
VALUE agef;
VALUE bmif;
PICTURE pctfmt (round) other = "009.9%";
run;
data surgerytiming1;
SET surgerytiming;
LABEL gender = 'Gender';
LABEL race = 'Race';
LABEL age = 'Age in Years';
LABEL bmi = 'Body Mass Index in kg/m2';
run;
proc tabulate data = surgerytiming1 order=unformatted;
CLASS gender race;
CLASSLEV race/ style = [asis=on];
VAR age bmi;
TABLE race*(n="N" colpctn = "%"*f=pctfmt.)
age*(n mean std = "SD")
bmi*(n mean std = "SD"),
(All gender) / misstext = "0"; 
FORMAT gender genderf. race racef. age agef. bmi bmif.;
run;

proc format; /*Table 2*/
VALUE hourf;
VALUE dowf 1 = "Monday"
2 = "Tuesday"
3 = "Wednesday"
4 = "Thursday"
5 = "Friday";
VALUE seasonf 1,2,3 = "Winter"
4,5,6 = "Spring"
7,8,9 = "Summer"
10,11,12 = "Fall";
VALUE moonphasef 1 = "new moon"
2 = "first quarter"
3 = "full moon"
4 = "last quarter";
VALUE complicationf 1 = "Yes"
0 = "No";
PICTURE pctfmt (round) other = "009.9%";
run;
data surgerytiming2;
SET surgerytiming1;
LABEL complication = "In-Hospital Complication";
LABEL hour = "Operating Hour";
LABEL dow = "Day of the Week";
LABEL season = "Season of Year";
LABEL moonphase = "Phase of Moon";
run;
proc tabulate data = surgerytiming2 order=unformatted;
CLASS  complication dow season moonphase;
CLASSLEV dow season moonphase/ style = [asis=on];
VAR hour;
TABLE dow*(n="N" colpctn = "%"*f=pctfmt.)
season*(n="N" colpctn = "%"*f=pctfmt.)
moonphase*(n="N" colpctn = "%"*f=pctfmt.)
hour*(n mean std = "SD"), 
(All complication) / misstext = "0";
FORMAT complication complicationf. hour hourf. dow dowf. moonphase moonphasef.;
run;

proc sgplot data=surgerytiming1; /*graphical summaries for association between variables*/
vbox hour / category=complication;
title 'Box Plot of Operation Hour by In-Hospital Complication';
xaxis label='In-Hospital Complication, 0=No and 1=Yes';
yaxis label='Operation Hour';
run;
proc sgplot data=surgerytiming1;
vbar complication / group=dow groupdisplay=cluster barwidth=0.5;
title 'In-Hospital Complication by Day of the Week';
xaxis label='In-Hospital Complication, 0=No and 1=Yes';
yaxis label='Count';
keylegend / title='Day of the Week (1 = Monday 2 = Tuesday 3 = Wednesday 4 = Thursday 5 = Friday)' location=inside position=topright;
run;
proc sgplot data=surgerytiming1;
vbar complication / group=season groupdisplay=cluster barwidth=0.5;
title 'In-Hospital Complication by Season of the Year';
xaxis label='In-Hospital Complication, 0=No and 1=Yes';
yaxis label='Count';
keylegend / title='Season (Winter Spring Summer Fall)' location=inside position=topright;
run;
proc sgplot data=surgerytiming1;
vbar complication / group=moonphase groupdisplay=cluster barwidth=0.5;
title 'In-Hospital Complication by Phase of the Moon';
xaxis label='In-Hospital Complication, 0=No and 1=Yes';
yaxis label='Count';
keylegend / title='Phase of the Moon (1 = new moon 2 = first quarter 3 = full moon 4 = last quarter)' location=inside position=topright;
run;

/*logistic regression analysis*/

proc logistic data=surgerytiming1; /*Model 1*/
model complication(event='1') = hour gender race age/ cl;
run;

proc logistic data=surgerytiming1; /*Model 2*/
CLASS dow(ref="1")/ param=ref;
model complication(event='1') = dow gender race age / cl;
run;

proc logistic data=surgerytiming1; /*Model 3*/
CLASS season(ref="Winter")/ param=ref;
model complication(event='1') = season gender race age / cl;
run;

proc logistic data=surgerytiming1; /*Model 4*/
CLASS moonphase(ref="1")/ param=ref;
model complication(event='1') = moonphase gender race age / cl;
run;

proc logistic data = surgerytiming1; /*Hosmer-Lemeshow goodness-of-fit test*/
MODEL complication(event="1") = hour gender race age / cl lackfit;
run;
proc logistic data = surgerytiming1; 
CLASS dow (ref="1")/ param=ref;
MODEL complication(event="1") = dow gender race age / cl lackfit;
run;
proc logistic data = surgerytiming1; 
CLASS season (ref="Winter")/ param=ref;
MODEL complication(event="1") = season gender race age / cl lackfit;
run;
proc logistic data = surgerytiming1;
CLASS moonphase(ref="1")/ param=ref;
MODEL complication(event="1") = moonphase gender race age / cl lackfit;
run;
