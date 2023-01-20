// Owen Ozier 2023
// (after some back-and-forth with ChatGPT)

// This uses recursion to calculate Fibonacci numbers in Stata.

cap program drop fibonacci 
program define fibonacci, rclass
  syntax , n(integer)
  if `n' <= 2 {
    return local fib = `n'-1
  }
  else {
  	local nm1=`n'-1
  	local nm2=`n'-2
    fibonacci, n(`nm1')
    local fib1 = r(fib)
    fibonacci, n(`nm2')
    local fib2 = r(fib)
    return local fib = `fib1' + `fib2'
  }
end

// demonstration, calculating first 20 Fibonacci numbers.
forvalues i = 1/20 {
  fibonacci, n(`i')
  di r(fib)
}


// A faster approach is a simple loop:
forvalues i = 0/29 {
	local n1 = 0
	local n2 = 1
	local temp = 0
	forvalues j = 1/`i' {
		local temp = `n1' + `n2'
		local n1 = `n2'
		local n2 = `temp'
	}
	di "Fibonacci number `i' is `n1'"
}

	
// Recursion is extremely inefficient programming in Stata, it turns out.
// Other ways of calculating Fibonacci numbers would be better, as shown in
// the simple loop above.
// Where this recursive solution breaks down: note what happens when we try
// calculating, say, the 100th Fibonacci number, or how long it takes to
// calculate even the 25th. This is now how Stata expects programs to work.
fibonacci, n(25)
di r(fib)

fibonacci, n(100)
di r(fib)
