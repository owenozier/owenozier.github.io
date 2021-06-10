// -----------------------------------------------------------------------------
// owen ozier
// 2021-06-10

// -----------------------------------------------------------------------------
// This (a) demonstrates Stata's dfbeta command:
// Calculates what happens when each observation is dropped (influence)
// and (b) shows what the derivative of each coefficient is w.r.t. observations,
// using matrices.

// -----------------------------------------------------------------------------
// PART 1
// set up data
clear all
// 800 obs in three strata:
set obs 800
gen row=_n
recode row 1/100=1 101/300=2 301/800=3, gen(stratid)
label var stratid "Identifier for strata"
// indicators for each
tab stratid, gen(dstrat)
// treatment probabilities in each
recode stratid 1=0.5 2=0.8 3=0.90001, gen(tprob) 
label var tprob "Treatment probability"

// some useful variables: stratum size, within-stratum row
sort stratid row
by stratid: gen stratsize=_N
by stratid: gen withinrow=_n

// generate "treatment" variable
gen t=cond(withinrow<=tprob*stratsize,1,0)
// residual
gen e=invnorm(uniform())
// y as a function of treatment and strata 
gen y=250-80*stratid + 10*t*(1+stratid) + 1*e
// interact "treatment" variable with strata, for separate estimation if desired
forvalues i=1/3 {
	gen t`i'=t*dstrat`i'
}

// -----------------------------------------------------------------------------
// PART 2: confirm that regressions are as expected.
// confirming things are as we expect
reg y t if stratid==1
reg y t if stratid==2
reg y t if stratid==3
// no stratum control yields inconsistent estimates,
// (in this case negative even though all treatment effects are positive)
reg y t
// with controls we do get an estimate of an average treatment effect
reg y t dstrat1 dstrat2

// -----------------------------------------------------------------------------
// PART 3: (a) now for influence of observations.
// estimate three different treatment effects, one within each of the strata
reg y t1 t2 t3 dstrat1 dstrat2
// create variables containing what happens to coeffs when each obs is left out
dfbeta
// which observations relate to which coefficients?
// (I use 1e-12 rather than zero since there can be
//  floating point precision issues with exact numbers)
tab stratid if abs(_dfbeta_1)>1e-12
tab stratid if abs(_dfbeta_2)>1e-12
tab stratid if abs(_dfbeta_3)>1e-12

// -----------------------------------------------------------------------------
// PART 4: (b) since we are doing OLS, here is the matrix way of doing it.
// set up the regression in matrices.
matrix accum allmult = y t1 t2 t3 dstrat1 dstrat2
matrix xpx = allmult[2..7, 2..7]
matrix xpy = allmult[2..7, 1]
matrix xpxi = syminv(xpx)
// confirm we can get the original coefficients back this way.
matrix b= xpxi*xpy
matrix list b
// great. now set up the x matrix alone
gen mycons=1
mkmat t1 t2 t3 dstrat1 dstrat2 mycons, matrix(thex)
// now get the ((x'x)-1 x')' = x (x'x)-1 matrix 
matrix myproj=xpxi * thex'
matrix myprojt=myproj'
svmat myprojt
desc mypr*
// now we see what each y value is multiplied by when creating the ols estimate
// of each coefficient, including which observations matter at all:
// (again I use 1e-12 rather than zero since there can be
//  floating point precision issues with exact numbers)
tab stratid if abs(myprojt1)>1e-12
tab stratid if abs(myprojt2)>1e-12
tab stratid if abs(myprojt3)>1e-12
tab stratid myprojt1
tab stratid myprojt2
tab stratid myprojt3


/*
more on matrices in Stata is here:
 https://blog.stata.com/2015/11/17/programming-an-estimation-command-in-stata-using-stata-matrix-commands-and-functions-to-compute-ols-objects/

 */
 
