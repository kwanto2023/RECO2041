/* Housing Prices and Distance From an Incinerator */
/* a new incinerator would be built in North Andover, Massachusetts in 1981 */

clear all

set more off

use "http://web.hku.hk/~kwanto/HPRICE3.DTA"

twoway scatter price dist || lfit price dist

reg lprice ldist

reg lprice ldist
local r2: display %5.4f = e(r2)
scatter lprice ldist, msymbol(oh) ||lfit lprice ldist, saving(ldist, replace) note("R-squared: `r2'")

reg lprice larea
local r2: display %4.3f = e(r2)
twoway scatter lprice larea, msymbol(oh)  ||lfit lprice larea, saving(larea, replace) note("R-squared: `r2'")

graph combine ldist.gph larea.gph, saving(graph, replace)

gen nearinc= dist<=15840

reg price nearinc if y81==1

reg price nearinc if y81==0

reg price i.nearinc##i.y81

/* Effects of Pollution on Housing Prices */
/* a sample of 506 communities in the boston area */

clear all

set more off

use "http://web.hku.hk/~kwanto/HPRICE2.DTA", clear

gen ldist=ln(dist)

scatter lprice ldist, msymbol(oh) ytitle("ln price") xtitle("ln distance") 

graph twoway lfitci lprice ldist, lpattern(solid) ///
|| scatter lprice ldist, msymbol(oh) ytitle("ln price") xtitle("ln distance") 

graph twoway lfitci lprice ldist, lpattern(solid) ///
|| scatter lprice ldist, msymbol(oh) ///
|| lfitci lprice ldist, stdf ciplot(rline) , ytitle("ln price") xtitle("ln distance") 

twoway scatter lprice rooms, msymbol(oh)  ||lfit lprice rooms, saving(rooms, replace)
twoway scatter lprice rooms, msymbol(oh)  ||qfit lprice rooms, saving(rooms2, replace)
graph combine rooms.gph rooms2.gph, ycommon 
 
graph export "graph_p_d.png", as(png) replace

graph export "graph_p_d.pdf", as(pdf) replace

reg price nox crime  rooms dist stratio

reg price nox crime  rooms dist stratio, beta

reg lprice lnox ldist c.rooms stratio

/* check normality on the error terms */
predict resid, resid
hist resid, normal

swilk resid
sfrancia resid

/* the quadratic term in number of rooms */
reg lprice lnox ldist c.rooms##c.rooms stratio

test rooms c.rooms#c.rooms

di -_b[rooms]/(2*_b[c.rooms#c.rooms])

margins, dydx(rooms) atmeans

margins, dydx(rooms) at(rooms=(2(0.5)8))

margins, at(rooms=(2(0.5)8))
marginsplot

/* Housing Price Regression, Qualitative Binary variable: Colonial style */
clear all

set more off

use "http://web.hku.hk/~kwanto/hprice1.dta", clear

reg lprice lsqrft colonia llotsize

gen p8=_b[_cons]+_b[colonia]*colonia+_b[lsqrft]*lsqrft+_b[llotsize]*8

twoway scatter lprice lsqrft, msymbol(oh)||line p8 lsqrft if colonia==0, sort ///
|| line p8 lsqrft if colonia==1, sort ///
legend(lab(1 "ln(price)") lab(2 "colonia=0") lab(3 "colonia=1"))


reg lprice lsqrft i.colonia##c.llotsize

gen p8=_b[_cons]+_b[colonia]*colonia+_b[lsqrft]*lsqrft+_b[llotsize]*8

twoway scatter lprice lsqrft, msymbol(oh)||line p8 lsqrft if colonia==0, sort ///
|| line p8 lsqrft if colonia==1, sort ///
legend(lab(1 "ln(price)") lab(2 "colonia=0") lab(3 "colonia=1"))

/* additional materials on heteroskedaasticity */
clear all

set more off

use "http://web.hku.hk/~kwanto/NYSE.DTA", clear
/*The weekly returns in NYSE.RAW are computed using data from January 1976 
through March 1989*/

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
pac resid, lags(5)

rvfplot, yline(0)

scatter resid p, msymbol(oh) ||lowess resid p, bw(.3) yline(0)

gen r2=resid^2

reg r2 return_1

gen r2_l=r2[_n-1]

reg r2 r2_l

/* linear trend */

clear all

set more off

use "http://web.hku.hk/~kwanto/HSEINV.DTA", clear
/* annual observations on housing investment and a housing 
price index in the United States for 1947 through 1988 */


reg linvpc lprice

tsset t

tsline lprice

tsline linvpc

/* ssc install multiline*/

multiline lprice linvpc t, recast(connected)

reg linvpc lprice t
