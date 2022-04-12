// demonstration of changing beta-hat as function of changed y values.
// owen ozier 2022
clear all
set seed 123

// make up some data
set obs 1000
gen xa=runiform()
gen xb=runiform()
gen y=xa+xb+rnormal()

// recover regression coefficients using matrices
gen ones=1
mkmat xa xb ones, matrix(xmat)
matrix xtxixt=invsym(xmat'*xmat)*xmat'
mkmat y, matrix(ymat)
mat b=xtxixt*ymat
mat list b
reg y xa xb
// these last two commands should give the same beta-hats

// let's say we care about changing the 100th y obs.
// myderivatives: derivatives of the beta-hats with respect to the 100th y obs
mat myderivatives=xtxixt[1..3,100]
mat list myderivatives

// now let's change it.
gen newy=y
replace newy=newy+2 in 100
list y in 100
list newy in 100

// show two ways of obtaining new beta hats. one using the matrix we made.
mat newb=b+2*myderivatives
mat list newb

// the other using regress command
*reg y xa xb
reg newy xa xb