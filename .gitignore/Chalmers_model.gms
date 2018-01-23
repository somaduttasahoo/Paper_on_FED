*CASE WITH ALL ENERGY ALTERNATIVES PRESENT WITHOUT ANY FURTHER CONSTRAINTS**************
set
h                     Number of hours in a year/1*8784/
n                     buildings/1*12/
*m                     number of months of a year/1*12/
tech                  technology used
                                     /HP
                                      CHP
                                      TES
                                      battery
                                      solar_PV
                                     /
head1                 rows for fixed annualised cost and variable cost
                                     /annualised_cost  represents annualised cost for each technology
                                      variable_cost    represents fixed cost for each technology
                                     /
;

option reslim = 1000000;
option threads = -1;

scalar
COP                   Coefficient of performance of the Heat Pump (HP)/3.15/
chr_TES               charging efficiency of TES/0.95/
dis_TES               discharging efficiency of TES/0.95/
max_dis_rate_TES      maximum discharge rate of TES in kWh per h /23000/
max_chr_rate_TES      maximum charge rate of TES in kWh per h/11000/
eta_CHP               efficiency of CHP plant /0.9/
alpha_CHP_low         lower value of ratio between heat and electricity produced /0.3/
alpha_CHP_high        higher value of ratio between electricity and heat produced/0.48/
fuel_price            fuel price for CHP plant in SEK per MWh/220.5/
chr_battery           charging efficiency of battery/0.95/
dis_battery           discharging efficiency of battery/0.95/
max_dis_rate_battery  maximum discharge rate of battery in kWh per h/33000/
max_chr_rate_battery  maximum charge rate of battery in kWh per h/17000/
*DNI_max               irradiance used for standard test conditions to calculate rate power of solar cells
*Power_tariff_dh       power tariff for peak power on district heating side in SEK per MW/35400/
*Power_tariff_elec     power tariff for peak power on electrical side in SEK per MW/35400/
;


PARAMETERS
heat_demand(n,h)      heat demand in buildings as obtained from metrys for 2016
elec_demand(n,h)      electricity demand in buildings as obtained from metrys for 2016
temp(h)               temperature profile of Gothenburg in 2016
elec_price(h)         electricity price by nord pool spot in 2016 for SE3
*DNI(n)                solar irradiance on gothenburg from SMHI.se site
*heat_price1(h)        heat price with daily variations based on weekdays and weekends
*gen_max_heat(o,m)     maximum value of heat power consumed by each building in each month
*gen_max_elec(o,m)     maximum value of electrical power consumed by each building in each month
*z(n,m)                matrix of numbers corresponding months
*value(tech)           annualised investment cost for each technology
DNI_1(h)              electrical energy from sun at 30 degree
heat_price(h)    heat price by Göteborg Energi in 2016 /  1*2184       519
                                                        2185*2904      357
                                                        2905*6576      99
                                                        6577*8040      357
                                                        8041*8784      519
                                                       /
;


PARAMETERS
switch_DR                switch to decide whether to operate demand response or not
switch_HP                switch to decide whether whether to operate HP or not
switch_TES               switch to decide whether whether to operate TES or not
switch_CHP               switch to decide whether to operate CHP or not
switch_battery           switch to decide whether to operate battery or not
switch_solarPV           switch to decide whether to operate PV or not
*switch_trans_DH          switch to decide whether to operate heating transmission or not
*switch_trans_elec        switch to decide whether to operate electrical transmission or not
;

*use of switch to determine whether HP, CHP, TES, transmission heat, transmission electrical should operate or not****************
switch_HP=1;
switch_TES=1;
switch_CHP=1;
switch_battery=1;
switch_solarPV=1;



*DOWNLOADING FILES FROM MATLAB*********************

$GDXIN   D:\masters thesis\codes for thesis\abc1.gdx
$LOAD heat_demand
$LOAD elec_demand
*$LOAD heat_price1
$LOAD temp
$LOAD elec_price
$GDXIN


$GDXIN   D:\masters thesis\codes for thesis\DNI.gdx
$LOAD DNI_1
$GDXIN

*1-maskingränd edit
*2-kemigården 1 fysik origa 3
*3-chalmersplatsen 4 administration
*4-hörsalar hb
*5-hörsalsvägen 7 maskinteknik
*6-hörsalsvägen 11 elteknik
*7-kemigården 1 fysik origa 1
*8-sven hultins gata 6
*9-sven hultins gata 8 väg
*10-tvärgata 1 biblioteket
*11-tvärgata 3 mathematiska
*12-tvärgata 6 lokalkontor


table technology(tech,head1) technology with annualised investment cost and variable cost
                            annualised_cost          variable_cost
HP                          280.8                    0.084
CHP                         2398.5                   0.02
TES                         1.11                     0
battery                     836.15                   0.053
Solar_PV                    575.33                   0

variable
TC                   total cost
P_DH(h)            heat power input from grid in MWh
P_elec(h)          electrical power input from grid in MWh
cost_el(n,h)         price of electrical energy
capa_HP              capacity of HP in MW
capa_TES             maximum value of charge for a building in MW
P_CHP_fuel(h)        power available in CHP
P_CHP_el(h)          electrical power in kW from CHP plant
P_CHP_heat(h)        heat power in kW from CHP plant
capa_CHP_el          maximum capacity of CHP plant in MW
capa_battery         maximum capacity of battery in MW
capa_solarPV         maximum capacity of a solar PV in MW
*P_DH_max(o,m)        maximum power from district heating network in a year
*P_elec_max(o,m)      maximum power from electrical grid network in a year
;

positive variable
P_chr_TES(h)       charge power from TES
P_dis_TES(h)       discharge power from TES
P_TES(h)           power available in TES
E_TES(h)           energy content of TES at any instant
P_HP(h)            power available in HP
P_chr_battery(h)   charge power from battery
P_dis_battery(h)   discharge power from battery
P_battery(h)       power available in TES
E_battery(h)       energy content of TES at any instant
P_PV(h)            electrical power input from solar panel
*gen_solarPV(h)     generation from solar PV
;

equation
total_cost               with aim to minimize total cost
heating                  heating supply-demand balance
electrical               electrical supply-demand balance
capacity_HP              for determining capacity of HP
power_CHP                electricity and heat balance for CHP
alpha_CHP1               higher limit of alpha equation
alpha_CHP2               lower limit of alpha equation
capacity_CHP             for determining the capacity of CHP
capacity_TES             for determining the capacity of TES
Energy_TES               Amount of energy contained in TES at any instant
Energy1_TES              Amount of energy at first and last hour is same
discharge_TES            instantaneous discharge from TES
charge_TES               instantaneous charge to TES
capacity_battery         for determining the capacity of TES
Energy_battery           Amount of energy contained in TES at any instant
Energy1_battery          Amount of energy at first and last hour is same
discharge_battery1       instantaneous discharge from battery is less than energy available
*discharge_battery2       instantaneous discharge from battery is less than discharge rate
charge_battery1          instantaneous charge to battery is less than difference of available energy and capacity
*charge_battery2          instantaneous charge is less than its max discharge rate
Energy_PV                power from solar cells
*Energy_PV1               power from solar cells is less than capacity
*trans1                   transmission of heat is one direction is negative of transmission in other direction
*trans2                   transmission of electricity is one direction is negative of transmission in other direction
*max_dheq                 to determine peak value of district heating from grid for every month
*max_eleq                 to determine peak value of electrical power from grid every month
;

total_cost..
TC     =e=     sum(h, P_DH(h)*heat_price(h)+P_elec(h)*(elec_price(h)+31+325)+P_CHP_fuel(h)*fuel_price)
               + switch_HP*(capa_HP*technology('HP','annualised_cost')+sum(h,P_HP(h)*technology('HP','variable_cost')))
               +switch_CHP*(capa_CHP_el*technology('CHP','annualised_cost')+sum(h,P_CHP_el(h)*technology('CHP','variable_cost')))
               +switch_TES*(capa_TES*technology('TES','annualised_cost')+sum(h,E_TES(h)*technology('TES','variable_cost')))
               +switch_battery*(capa_battery*technology('battery','annualised_cost')+sum(h,E_battery(h)*technology('battery','variable_cost')))
               +switch_solarPV*(capa_solarPV*technology('Solar_PV','annualised_Cost')+sum(h,P_PV(h)*technology('solar_PV','variable_cost')))
             ;

*             + sum((o,m), p_DH_max(o,m)*Power_tariff_dh+p_elec_max(o,m)*Power_tariff_elec)
*demand supply balance for electrical and heating side*******
heating(h)..
sum(n,heat_demand(n,h)) =e= P_DH(h)
                           +P_HP(h)*switch_HP
                           +(dis_TES*P_dis_TES(h)-P_chr_TES(h)/chr_TES)*switch_TES
                           +(P_CHP_heat(h))*switch_CHP
                           ;

electrical(h)..
sum(n,elec_demand(n,h)) =e= P_elec(h)
                           +(dis_battery*P_dis_battery(h)-P_chr_battery(h)/chr_battery)*switch_battery
                           +(P_CHP_el(h))*switch_CHP
                           -P_HP(h)/COP*switch_HP
                           +P_PV(h)*switch_solarPV
                           ;

*max_dheq(o,m,n)..
*P_DH_max(o,m) =G= P_DH(o,n)*z(n,m);

*max_eleq(o,m,n)..
*P_elec_max(o,m) =G= P_elec(o,n)*z(n,m);


*HP equations**************
capacity_HP(h)$(switch_HP eq 1) ..
P_HP(h) =l= capa_HP;


*TES equations*************
Energy_TES(h)$(switch_TES eq 1)..
E_TES(h+1) =e= E_TES(h)+P_chr_TES(h+1)-P_dis_TES(h+1);

Energy1_TES(h)$(switch_TES eq 1)..
E_TES('1') =e= 0;

discharge_TES(h)$(switch_TES eq 1)..
P_dis_TES(h) =l= max_dis_rate_TES;

charge_TES(h)$(switch_TES eq 1)..
P_chr_TES(h) =l= max_chr_rate_TES;

capacity_TES(h)$(switch_TES eq 1)..
E_TES(h) =l= capa_TES;

*CHP equations*************
power_CHP(h)$(switch_CHP eq 1)..
P_CHP_fuel(h)*eta_CHP =e= P_CHP_el(h)+P_CHP_heat(h);

alpha_CHP1(h)$(switch_CHP eq 1)..
P_CHP_el(h) =g= alpha_CHP_low*P_CHP_heat(h);

alpha_CHP2(h)$(switch_CHP eq 1)..
P_CHP_el(h) =l= alpha_CHP_high*P_CHP_heat(h);

capacity_CHP(h)$(switch_CHP eq 1)..
P_CHP_el(h) =l= capa_CHP_el;

*Battery equations*************
Energy_battery(h)$(switch_battery eq 1)..
E_battery(h+1) =e= E_battery(h)+P_chr_battery(h+1)-P_dis_battery(h+1);

Energy1_battery(h)$(switch_battery eq 1)..
E_battery('1') =e= 0;

discharge_battery1(h)$(switch_battery eq 1)..
P_dis_battery(h) =l= E_battery(h);

*discharge_battery2(h)$(switch_battery eq 1)..
*P_dis_battery(h) =l= max_dis_rate_battery;

charge_battery1(h)$(switch_battery eq 1)..
P_chr_battery(h) =l= capa_battery-E_battery(h);

*charge_battery2(h)$(switch_battery eq 1)..
*P_chr_battery(h) =l= max_chr_rate_battery;

capacity_battery(h)$(switch_battery eq 1)..
E_battery(h) =l= capa_battery;

*solar cells equations***********
Energy_PV(h)$(switch_solarPV eq 1)..
*P_PV(o,n) =e= (DNI(n)/DNI_max)*gen_solarPV(o,n);
P_PV(h) =e= DNI_1(h)*capa_solarPV;

*Energy_PV1(o,n)$(switch_solarPV eq 1)..
*gen_solarPV(o,n) =l= capa_solarPV(o);


model total
/
ALL
/;

SOLVE total using LP minimizing TC;

display
P_DH.l
P_elec.l
*P_DH_max.l
*P_elec_max.l
TC.l
P_HP.l
E_TES.l
P_dis_TES.l
P_chr_TES.l
P_CHP_el.l
E_battery.l
P_dis_battery.l
P_chr_battery.l
P_PV.l
capa_HP.l
capa_TES.l
capa_CHP_el.l
capa_battery.l
capa_solarPV.l
;

execute_unload "power_technologies2.gdx" TC, P_DH, P_elec, P_HP, P_CHP_el, P_CHP_heat, P_dis_TES, P_chr_TES, E_TES, P_PV, P_chr_battery, P_dis_battery, E_battery;
execute_unload "capacity2.gdx" capa_HP, capa_TES, capa_CHP_el, capa_battery, capa_solarPV;

*execute 'gdxxrw.exe power_technologies.gdx var=P_DH.l P_elec.l P_HP.l P_CHP.l P_dis_TES.l P_chr_TES.l E_TES.l P_PV.l P_chr_battery.l P_dis_battery.l E_battery.l rng=power_technologies:sheet1!A1:K8784'

*execute " gdxxrw.exe power_technologies1.gdx var=P_DH.l ";
*execute " gdxxrw.exe power_technologies1.gdx var=P_elec.l ";

