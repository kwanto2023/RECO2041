/* Housing Prices and Distance From an Incinerator */

clear all

set more off

use "http://web.hku.hk/~kwanto/HPRICE3.DTA"

twoway scatter price dist || lfit price dist

reg lprice ldist

reg lprice ldist larea
local r2: display %5.4f = e(r2)
scatter lprice ldist, msymbol(oh) ||lfit lprice ldist, saving(ldist, replace) note("R-square (%): `r2'")

twoway scatter lprice larea, msymbol(oh)  ||lfit lprice larea, saving(larea, replace)

graph combine ldist.gph larea.gph, saving(graph, replace)


/* Effects of Pollution on Housing Prices */

clear all

set more off

use "http://web.hku.hk/~kwanto/HPRICE2.DTA"

reg price nox crime  rooms dist stratio

reg price nox crime  rooms dist stratio, beta

gen ldist=log(dist)
reg lprice lnox ldist c.rooms stratio
reg lprice lnox ldist c.rooms##c.rooms stratio

mat table=r(table)
mat list table
scalar tcrit=table[8,1]

predict resid, resid
hist resid, normal

swilk resid
sfrancia resid

predict p, xb
predict stdp, stdp // SE of linear prediction
predict stdf, stdf // SE of the forcast

*compute CI for conditional mean
generate lowerp=p-tcrit*stdp
generate upperp=p+tcrit*stdp

*compute CI for individual prediction
generate lowerf=p-tcrit*stdf
generate upperf=p+tcrit*stdf

scatter lprice ldist || line p lowerp upperf ldist, pstyle(p2 p3 p3) sort

graph twoway lfitci lprice ldist, stdf ciplot(rline) ///
 || lfitci lprice ldist, lpattern(solid) ///
 || scatter lprice ldist, ytitle("ln price") xtitle("ln distance") 
 
 graph export "graph_p_d.png", as(png) replace


di _b["rooms"]/(2*_b["c.rooms#c.rooms"])

margins, dydx(rooms) at(rooms=(2(0.5)8))
margins, at(rooms=(2(0.5)8))
margins, dydx(rooms) atmeans

twoway scatter lprice rooms, msymbol(oh)  ||lfit lprice rooms, saving(rooms, replace)
twoway scatter lprice rooms, msymbol(oh)  ||qfit lprice rooms, saving(rooms2, replace)
graph combine rooms.gph rooms2.gph, ycommon 

/* Housing Price Regression, Qualitative Binary variable: Colonial style */
clear all

set more off

use "http://web.hku.hk/~kwanto/HPRICE1.DTA"

reg lprice llotsize lsqrft bdrms colonia


/* additional materials on heteroskedaasticity */
clear all

set more off

use "http://web.hku.hk/~kwanto/NYSE.DTA"

tsset t

twoway (tsline price) ||lfit price t, ylabel(50(25)200)

reg return return_1
predict p, xb
predict resid, r

imtest

ovtest

hettest


corrgram resid, lags(5)
corr resid L.resid
ac resid, lags(5)
pac resid

rvfplot, yline(0)

scatter resid p, msymbol(oh) ||lowess resid p, bw(.3) yline(0)

gen r2=resid^2

reg r2 return_1

gen r2_l=r2[_n-1]

reg r2 r2_l

/* linear trend */

clear all

set more off

use "http://web.hku.hk/~kwanto/HSEINV.DTA"

reg linvpc lprice

reg linvpc lprice t


