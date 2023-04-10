# Owen Ozier
# 2023-04-10
# based on example by Nick Huntington-Klein

# packages that may need to be installed
packagestocheck <- c('modelsummary','fixest','readstata13')

# install if packages
install.packages(setdiff(packagestocheck, rownames(installed.packages())))

library(modelsummary)
library(fixest)
library(readstata13)

# choose your directory
setwd("C:/Users/oweno/Dropbox/00/tmp/2023-04/out")

# load data
tsdf <- read.dta13("https://owenozier.github.io/files/resource/exampledata/testscore-example.dta")

# estimate three specifications with homoskedasticity based SEs
m1 <- lm(testscore ~ cmsch, data = tsdf)
m2 <- lm(testscore ~ cmsch + age, data = tsdf)
m3 <- lm(testscore ~ cmsch + age + dtm, data = tsdf)

# estimate three specifications with clustered SEs
m4 <- feols(testscore ~ cmsch, cluster = ~cid, data = tsdf)
m5 <- feols(testscore ~ cmsch + age, cluster = ~cid, data = tsdf)
m6 <- feols(testscore ~ cmsch + age + dtm, cluster = ~cid, data = tsdf)

# prepare to format output table
gm <- modelsummary::gof_map

# format the bottom of the output table
gm <- tibble::tribble(
  ~raw,        ~clean,          ~fmt,
  "nobs",      "Observations",             0,
  "r.squared", "R<sup>2</sup>", 3)

# format variable names
cm <- c('cmsch'    = 'Parent schooling (avg)',
        'age'    = 'Age (years)',
        'dtm'    = 'Distance to market (km)',
        '(Intercept)' = 'Constant')

# put everything in the table, annotate significance levels, save
msummary(list(m1, m2, m3, m4, m5, m6),
         stars=c('*' = .1, '**' = .05, '***' = .01),
         output= 'testscore_output_r.html',
         fmt="%.3f",
         gof_map = gm, escape=FALSE,
         coef_map = cm,
         notes = "Standard errors in parentheses")
