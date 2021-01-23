// owen ozier and david mckenzie
// Why to use ex-post standard errors and minimum detectable effects
// but why NOT to use the erroneous idea of "ex-post power"
// April-May 2019
// Program 2 of 2: visualize results
version 14.1
clear all

// THREE PARTS:
//  1: PATH SETUP 
//  2: PARAMETERS
//  3: VISUALIZATION

// -------------------------------------------------------------------------
// PART 1: PATH SETUP 
// (customize this yourself before running)
global mydatadir="C:\Users\PUT_YOUR_DIRECTORY_HERE_BEFORE_USING_THIS_PROGRAM"


// -------------------------------------------------------------------------
// PART 2: PARAMETERS

// control flag for whether to save output graphs or just display them.
// 1 = save graph output.  0 = display graphs but don't save output.
local savinggraphs=0
//loopmax: the number of simulations used in the previous program.
// make sure this matches if you change the number of simulations.
// this is only used here for opening the file with the intended filename.
local loopmax=1000


// -------------------------------------------------------------------------
// PART 3: VISUALIZATION

// note that added text is manually arranged,
// so if you change any underlying parameters,
// you will have to adjust the text (and associated values) yourself.


// directory and file
cd "${mydatadir}"
import delimited using "mde-not-expostpower-2019-`loopmax'", clear

// labeling
label var epp1 "Ex-post power using estimated coefficient"
label var b1 "Estimated coefficient"
label var epp2 "Ex-post power using estimated coefficient"
label var b2 "Estimated coefficient"
label var mde "Estimated MDE"

// some notes to self on numbers to put in the figure
sum epp1
sum epp1 if p1<0.05

// ex post power when an effect is present
twoway (scatter epp1 b1 if p1>=0.05, msize(vtiny) mcolor(gs8)) ///
       (scatter epp1 b1 if p1<0.05, msize(vtiny) mcolor(midblue)), ///
	   scheme(s1mono) legend(off) ///
	   text(0.54 -0.05 "{it:Experiment p-values <0.05}", size(small) placement(e) color(midblue)) ///
	   text(0.46 -0.05 "{it:Experiment p-values {&ge}0.05}", size(small) placement(e) color(gs8)) ///
	   text(0.80 0.185 "True power = 0.8    ------", size(small) placement(w) color(midgreen)) ///
	   text(0.83 0.215 "------ Mean ex-post when p<0.05 = 0.83", size(small) placement(e) color(red)) ///
	   text(0.73 0.19 "------ Mean ex-post = 0.73", size(small) placement(e) color(red)) ///
	   subtitle("True power = 0.8, true standardized effect=0.2")
if(`savinggraphs') {
 graph export "mde-not-expostpower-2019-with-effect-`loopmax'.png", replace
 graph export "mde-not-expostpower-2019-with-effect-`loopmax'.pdf", replace
}

// some notes to self on numbers to put in the figure
sum epp2
sum epp2 if p2<0.05

// power is 
di normal(0.05/(1/sqrt(200))-1.96) // 'good' power
di normal(-0.05/(1/sqrt(200))-1.96) // 'bad' power
di normal(0.05/(1/sqrt(200))-1.96) + normal(-0.05/(1/sqrt(200))-1.96) // 'power'

// ex post power when an effect is absent
twoway (scatter epp2 b2 if p2>=0.05, msize(vtiny) mcolor(gs8)) ///
       (scatter epp2 b2 if p2<0.05, msize(vtiny) mcolor(midblue)), ///
	   scheme(s1mono) legend(off) ///
	   text(0.54 0.0 "{it:Experiment p-values <0.05}", size(small) placement(c) color(midblue)) ///
	   text(0.46 0.0 "{it:Experiment p-values {&ge}0.05}", size(small) placement(c) color(gs8)) ///
	   text(0.66 0.18 "------ Mean ex-post when p<0.05 = 0.66", size(small) placement(e) color(red)) ///
	   text(0.21 0.09 "------ Mean ex-post  = 0.21", size(small) placement(e) color(red)) ///
	   subtitle("True power = 0.11, true standardized effect=0.05") xscale(range(-0.25 0.5)) xlabel(-0.2(0.1)0.5)
if(`savinggraphs') {
 graph export "mde-not-expostpower-2019-with-tiny-effect-`loopmax'.png", replace
 graph export "mde-not-expostpower-2019-with-tiny-effect-`loopmax'.pdf", replace
}

// mde in relation to coefficient estimate (no relationship)
twoway (scatter mde b1 if p1>=0.05, msize(vtiny) mcolor(gs8)) ///
       (scatter mde b1 if p1<0.05, msize(vtiny) mcolor(midblue)), /// 
	   subtitle("True MDE=0.2, true power = 0.8, true standardized effect=0.2") ///
	   text(0.17 0.15 "{it:Experiment p-values <0.05}", size(small) placement(e) color(midblue)) ///
	   text(0.17 -0.04 "{it:Experiment p-values {&ge}0.05}", size(small) placement(e) color(gs8)) ///
	   legend(off) yline(0.2, lcolor(gray)) yscale(range(0 0.25)) ylabel(0(0.05)0.25) scheme(s1mono)
if(`savinggraphs') {
 graph export "mde-not-expostpower-2019-`loopmax'.png", replace
 graph export "mde-not-expostpower-2019-`loopmax'.pdf", replace
}

