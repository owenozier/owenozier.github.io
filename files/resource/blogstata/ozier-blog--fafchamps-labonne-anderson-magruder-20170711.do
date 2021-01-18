// Owen Ozier
// Stata notes to accompany blog post
// 2017.07.11



// NOTE
// Throughout, I use a specific notation for clarity when
// computing critical values from the normal distribution:
//    invnorm(1 - [test size]/([tails * bonferroni#]) )
// So, to get the critical value for a conventional
// 2-sided 1-hypothesis test at the 5 pct level,
// instead of writing the relatively compact expression
//    invnorm(1 - 0.025)
// I instead write
//    invnorm(1 - 0.05/(2*1))
// to make clearer the features of the intended test:
//      the level is 0.05;
//      the number of sides is 2;
//      the number of tests is 1 (no Bonferroni adjustment in this example).




// ------------------------------------------------------------------------
// Fafchamps and Labonne

// start with 4.29, standardized effeect size for which power is 0.99
local standardizedEffectPower99=invnorm(0.975)+invnorm(0.99)
di `standardizedEffectPower99'

// confirm power in full sample
di normal(`standardizedEffectPower99'-invnorm(1-0.05/(2*1)))

// power in half sample? standardized effect cut by sqrt(1/2)
di normal(`standardizedEffectPower99'*sqrt(1/2)-invnorm(1-0.05/(2*1)))

// squared power in half sample:
di normal(`standardizedEffectPower99'*sqrt(1/2)-invnorm(1-0.05/(2*1)))^2



// ------------------------------------------------------------------------
// Anderson and Magruder

// Let's start with 2.8, the effect size, in terms of standard errors,
// for which power is 0.80. (for example, see
// http://economics.ozier.com/econ626/lec/econ626lecture7_handout.pdf )
local standardizedEffectPower80=invnorm(0.975)+invnorm(0.80)
di `standardizedEffectPower80'

// confirm power in full sample
local unaccompaniedMainPower=normal(`standardizedEffectPower80'-invnorm(1-0.05/(2*1)))
di `unaccompaniedMainPower'

// Bonferroni: p-value changes by factor of two.
local bonferroniMainPower=normal(`standardizedEffectPower80'-invnorm(1-0.05/(2*2)))
di `bonferroniMainPower'

// Detect in 30 percent sample, at threshold of 1.2
local firstStagePower=normal(`standardizedEffectPower80'*sqrt(0.3)-1.2)
di `firstStagePower'

// probability of false rejection under the null
local falseScreening = 2*(1-normal(1.2))
di `falseScreening'

// likelihood of unaccompanied main hypothesis:
local probabilityUnaccompanied=0.1*(1-`firstStagePower')+0.9*(1-`falseScreening')
di `probabilityUnaccompanied'

// resulting main power in expectation
local resultingMainPower=`probabilityUnaccompanied'*`unaccompaniedMainPower' + (1-`probabilityUnaccompanied')*`bonferroniMainPower' 
di `resultingMainPower'

// Detect in 70 percent sample, at 5 percent threshold, one-sided but Bonferroni adjusted by 2
local secondStagePower=normal(`standardizedEffectPower80'*sqrt(0.7)-invnorm(1-0.05/(1*2)))
di `secondStagePower'

// Total expected rejections:
di `resultingMainPower' + (0.1*`firstStagePower'*`secondStagePower')





// ------------------------------------------------------------------------
// Anderson and Magruder's literature statistics

// T of 2.6
di normal(2.6-invnorm(1-0.05/(2*1)))

// with 128 tests, Bonferroni
di normal(2.6-invnorm(1-0.05/(2*128)))



