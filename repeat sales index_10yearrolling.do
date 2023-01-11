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
