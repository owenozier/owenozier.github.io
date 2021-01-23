// owen ozier and david mckenzie
// Why to use ex-post standard errors and minimum detectable effects
// but why NOT to use the erroneous idea of "ex-post power"
// April-May 2019
// Program 1 of 2: simulate data generating process
version 14.1
clear all


// FOUR PARTS:
//  1: PATH SETUP 
//  2: PARAMETERS OF THE SIMULATION
//  3: BASIC DATA STRUCTURE
//  4: SIMULATIONS

// -------------------------------------------------------------------------
// PART 1: PATH SETUP 
global mydatadir="C:\Users\PUT_YOUR_DIRECTORY_HERE_BEFORE_USING_THIS_PROGRAM"


// -------------------------------------------------------------------------
// PART 2: PARAMETERS OF THE SIMULATION

//loopmax: the number of simulations
// note that there is a dependency here: the visualization file needs to have
// the same parameter value here, because it is used in the filename where
// simulation results are stored.
// 
// in terms of timing, on my laptop of the moment:
// 100 takes a couple of seconds;
// 1000 takes closer to 30 seconds;
// 10000 takes about 250 seconds.
local loopmax=1000

//obsno: the number of observations in total
local obsno 800

//trueeffect: this is the larger effect we'll try to detect.
local trueeffect=0.2

//tinyeffect: this is the smaller effect we'll try to detect.
local tinyeffect=0.05

//halfobs: this is half the number of observations, which are the ones to be "treated"
// currently automatically calculated from the total number of observations.
local halfobs=`obsno'/2


// -------------------------------------------------------------------------
// PART 3: BASIC DATA STRUCTURE
set obs `obsno'
gen idno=_n
gen t=cond(idno<=`halfobs',1,0)
label var t "Treatment"
 
version 14.1: set seed 20190426
// ---
// MAKING SURE SEED IS WHAT WE THINK IT IS:
//  (we do this for replicability of results.
//   if you are interested to see what issues sometimes arise in random number
//   generation, and/or how generators have changed over time, read here:
//   http://documents.worldbank.org/curated/en/369471468333566549/Perils-of-simulation-parallel-streams-and-the-case-of-statas-rnormal-command )
//
local seed_start=substr(c(seed),1,30)
local planned_seed_start="XAA00000000013414da635d9c6be76"
local seed_end=strreverse(substr(strreverse(c(seed)),1,30))
local planned_seed_end="6ab09bce15792e00010000013809e3"
di "`seed_start'" _newline "`planned_seed_start'"
assert "`seed_start'"=="`planned_seed_start'"
di "`seed_end'" _newline "`planned_seed_end'"
assert "`seed_end'"=="`planned_seed_end'"
// ---

// CALCULATING CRITICAL VALUE TO BE USED LATER:
local normcrit5=invnorm(0.975)
di `normcrit5'

// For reference, though it will not be used in data simulation,
// calculating the usual "2.8" number
// as seen in slide 7 of this 2016 set of lecture notes:
// http://economics.ozier.com/econ626/lec/econ626lecture7_handout.pdf
local MDEcrit80=`normcrit5'+invnorm(0.8)
di `MDEcrit80'

// For reference, though it will not be used in data simulation,
// thinking through anticipated standard errors and power
// expected (approx) SE
local expse=(sqrt((1/`halfobs')*1+(1/`halfobs')*1))
di `expse'
// expected MDE:
di `MDEcrit80'*`expse'
// expected power
local exppower=normal(`trueeffect'/`expse'-`normcrit5')
di `exppower'



// -------------------------------------------------------------------------
// PART 4: SIMULATIONS

// Start timer
timer clear 1
timer on 1

// move to the output directory.
cd "${mydatadir}"

// open the file that will record simulation results
cap file close fp
file open fp using "mde-not-expostpower-2019-`loopmax'.csv", write replace

// write headers.
//  Iteration number
//  Standard error from regression
//  Minimum detectable effect using this standard error
//  first regression: beta hat
//  first regression: p value
//  first regression: erroneous "ex post power"
//  second regression: beta hat
//  second regression: p value
//  second regression: erroneous "ex post power"
file write fp "iteration,se,mde,b1,p1,epp1,b2,p2,epp2" _newline

// loop
forvalues iter=1/`loopmax' {
 di "-----------iteration `iter'"

 // generate random error
 cap drop e1
 qui gen e1=invnorm(uniform())
 // generate outcomes incorporating error and effects
 cap drop y1
 qui gen y1=e1+`trueeffect'*t
 cap drop y2
 qui gen y2=e1+`tinyeffect'*t

 // regress outcome on treatment (scenario 1)
 qui reg y1 t
 // capture results from regression
 local b1=_b[t]
 mat rr1=r(table)
 local p1=rr1[4,1]
 // note that the stanard error will be the same in scenarios 1 and 2 with this data generating process, so only recording it once.
 local se=_se[t]
 // see the p values scroll by if you are interested
 di "`p1'"

 // MDE (depends on the SE, doesn't vary between scenarios 1 and 2 with this data generating process)
 local mde=`MDEcrit80'*_se[t]

 // erroneous "ex-post power" 1
 local epp1=normal(abs(_b[t])/_se[t]-`normcrit5') + normal(-abs(_b[t])/_se[t]-`normcrit5')

 // regress outcome on treatment (scenario 2)
 qui reg y2 t
 // capture results from regression
 local b2=_b[t]
 mat rr2=r(table)
 local p2=rr2[4,1]
 // see the p values scroll by if you are interested
 di "`p2'"

 // erroneous "ex-post power" 2
 local epp2=normal(abs(_b[t])/_se[t]-`normcrit5') + normal(-abs(_b[t])/_se[t]-`normcrit5')
 
 // WRITE ALL TO ONE LINE OF THE FILE
 file write fp "`iter',`se',`mde',`b1',`p1',`epp1',`b2',`p2',`epp2'" _newline
 
}

// close the file
file close fp

// report the time used
timer off 1
timer list 1


