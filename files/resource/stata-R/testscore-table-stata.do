// Owen Ozier
// 2023-04-10

* install esttab if needed, it is part of the estout package
capture which esttab
if _rc!=0 {
  ssc install estout, replace
}

* get to output directory
cd "C:\Users\oweno\Dropbox\00\tmp\2023-04\out"

* load data
// IF SAVED LOCALLY:
// use "testscore-example.dta", clear 
use "https://owenozier.github.io/files/resource/exampledata/testscore-example.dta", clear

* estimate three specifications with homoskedasticity based SEs
reg testscore cmsch
estimates store m1
reg testscore cmsch age
estimates store m2
reg testscore cmsch age dtm
estimates store m3

* estimate three specifications with clustered SEs
reg testscore cmsch, vce(cluster cid)
estimates store m4
reg testscore cmsch age, vce(cluster cid)
estimates store m5
reg testscore cmsch age dtm, vce(cluster cid)
estimates store m6

* put everything in the table, annotate significance levels, save
esttab m1 m2 m3 m4 m5 m6 using testscore-output-stata.html, se(%5.3f) b(%5.3f) replace r2 label nomtitles star(* 0.10 ** 0.05 *** 0.01) 