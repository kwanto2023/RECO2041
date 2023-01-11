clear all
set more off

import excel using "http://web.hku.hk/~kwanto/TKS_97_17.xlsx", firstrow clear

/* relabel the date information in monthly interval */
gen idate2=mofd(idate)
format idate2 %tm

gen bcomp2=mofd(bcomp)
format bcomp2 %tm

drop idate bcomp
rename idate2 idate
rename bcomp2 bcomp

save "TKS_97_17.dta", replace

/* produce price index using mean and median in the each month */
bysort idate: egen meanP=mean(log(P))
bysort idate: egen medP=median(log(P))

summarize meanP if idate==tm(2000m1)
gen mP_2000m1=meanP/`r(mean)'*100

summarize medP if idate==tm(2000m1)
gen medP_2000m1=medP/`r(mean)'*100

collapse (mean)mP_2000m1 (mean) medP_2000m1, by(idate)

save "mean_2001m1_TKS.dta", replace

mkmat idate mP_2000m1 medP_2000m1, mat(mean)

mat list mean

/* produce hedonic price index*/
use "TKS_97_17.dta", clear

gen lnP=ln(P)
gen age=(idate-bcomp)/12

local indep c.age##c.age c.FL##c.FL c.GFA##c.GFA 

reg lnP `indep' i.idate

mat b=e(b)'

mat list b

mat a=(0)
mat rownames a="444"

mat define H_index=a\b["445.idate".."695.idate",1]

mat list H_index

local rname: rowfullnames H_index
mat rownames H_index=`rname'

drop _all

svmat2 double H_index, name(dummies) r(time)
gen Time=substr(time,1,3)
destring Time, replace
drop time

format Time %tm
summarize dummies if Time==tm(2000m1)

gen H_index=100*exp(dummies)/exp(`r(mean)')
drop dummies

svmat2 double mean, name(time meanP medianP)

drop time

twoway line H_index mean median Time, ///
ylabel(40(20)500, angle(horizontal)) ///
ytitle("Index") ///
xtitle("Time") ///
title("Hedonic Residential Price Index") ///
ttick(1997m1(12)2018m1) ///
subtitle("Tai Koo Shing, 1997-2017 (2000m1=100)") ///
note("Source: Selected sample from EPRC")

mkmat Time H_index mean median, mat(index)

mat list index


/* produce repeat sales price index*/
use "TKS_97_17.dta", clear

drop FL GFA

tab tc

sort id idate
by id: gen idate2=idate[_n+1]
format idate2 %tm

by id: gen P2=P[_n+1]
rename P P1
rename idate idate1

gen lr=ln(P2)-ln(P1)

gen hold_m=idate2-idate1

summarize idate1 
summarize idate2
summarize hold_m

tab idate1
tab idate2

drop if hold_m==0 |P2==.

forval m = `=m(1997m1)'/`=m(2017m12)' { 
    gen d`m'=0
	replace d`m'=-1 if idate1==`m'
	replace d`m'=1 if idate2==`m'
	summarize d`m'
	if `r(Var)'==0 {
	drop d`m'
	} 
}

save "TKS_97_17_rs.dta", replace

di tm(2000m1)

reg lr d444-d479 d481-d695, noconstant

reg lr d444-d479 d481-d693 if idate2<=693, noconstant
reg lr d444-d479 d481-d694 if idate2<=694, noconstant
reg lr d444-d479 d481-d695 if idate2<=695, noconstant

corr d693-d695
/*
predict resid, re

gen resid2=resid^2

reg resid2 hold_m

predict pred, xb

reg lr d444-d695 [aweight=1/pred], noconstant
*/

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

gen RS_index=100*exp(dummies)

tsset time3, monthly

svmat2 double index, name(time H_index meanP medianP)


twoway line meanP medianP H_index RS_index time3, ///
ylabel(50(50)500, angle(horizontal)) ///
xlabel(`=m(1997m1)' (36) `=m(2017m12)' ,angle(-90)) /// 
ytitle("Index") ///
xtitle("Time") ///
title("Repeat Sales Residential Price Index") ///
ttick(1997m1(12)2018m1) ///
subtitle("Tai Koo Shing, 1997-2017 (2000m1=100)") ///
note("Source: Selected sample from EPRC") ///
legend(label(1 "Mean Price") label(2 "Median Price") label(3 "Hedonic Price") label(4 "Repeat Sales Price"))


/* ten-year interval */
use "TKS_97_17_rs.dta", clear

reg lr d445-d563 if idate2>=444 & idate2<=563, noconstant
mat define b=0
mat define b=b\e(b)'
mata: st_matrix("index", exp(st_matrix("b")))
mat colnames index=563
mat list index
scalar c1=index[120,1]


forval m = 445/576 { 
    local n=`m'+119
	local k=`m'+1
	local j=`m'-444
	qui reg lr d`k'-d`n' if idate2>=`m' & idate2<=`n', noconstant
	/*mat a=0
	mat a=a \e(b)'
	mat colnames a=`n'
	mat b=b,a
	*/
	mat b=e(b)'
	mata: st_matrix("bb", exp(st_matrix("b")))
	mat bb=bb[118..119,1]
	scalar c2=c1/bb[1,1]
	scalar c1=c2*bb[2,1]
	mat b=c1*bb[2,1]
	
	mat index=index \b
 }

 mat list index
 drop _all
 
 svmat2 double index, name(RSI) 

 gen time=_n+443
 format time %tm
 
 summarize RSI if time==tm(2000m1)
 
 gen index_2000m1=100*RSI/`r(mean)'
