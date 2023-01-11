clear all

set more off

import excel "http://web.hku.hk/~kwanto/RepeatSales_500.xlsx", sheet("EViews") firstrow clear

drop if OBS==.
drop G

gen asp1=date(ASP1, "DMY")
format asp1 %td

gen asp2=date(ASP2, "DMY")
format asp2 %td

gen asp1_m=mofd(asp1)
format asp1_m %tm

gen asp2_m=mofd(asp2)
format asp2_m %tm

gen hold_m=asp2_m-asp1_m
gen hold_d=asp2-asp1

gen lr=ln(P2)-ln(P1)

summarize asp1_m 
summarize asp2_m

tab asp1_m
tab asp2_m

forval m = `=m(1996m9)'/`=m(2013m8)' { 
    gen d`m'=0
	replace d`m'=-1 if asp1_m==`m'
	replace d`m'=1 if asp2_m==`m'
	summarize d`m'
	if `r(Var)'==0 {
	drop d`m'
	} 
}
/*
gen c=-1
reg lr c.c#i.asp1_m i.asp2_m
*/
reg lr d440-d638, noconstant
reg lr d440-d639, noconstant
reg lr d440-d640, noconstant


reg lr d440-d638 if asp2_m<=638, noconstant
reg lr d440-d639 if asp2_m<=639, noconstant
reg lr d440-d640 if asp2_m<=640, noconstant

corr d638-d640


/* two stage construction */
reg lr d440-d643, noconstant

predict resid, re

gen resid2=resid^2

reg resid2 hold_m

predict pred, xb

reg lr d440-d643 [aweight=1/pred], noconstant

mat define b=e(b)'
local rname: rowfullnames b
mat rownames b=`rname'

mat list b

*mat define index=b[1, "d440".."d643"]

drop _all

svmat2 double b, name(dummies) r(time)
destring time, gen(time2) i(d o.d)

gen time3=time2
format time3 %tm

drop time

gen index=100*exp(dummies)

tsset time3, monthly

twoway line index time3, ///
ylabel(40(20)300, angle(horizontal)) ///
ytitle("Index (2001May=100)") ///
title("Repeat Sales Residential Price Index") ///
ttick(1995m1(12)2016m1) ///
subtitle("Hong Kong, 1995-2015") ///
note("Source: Selected sample from EPRC")
