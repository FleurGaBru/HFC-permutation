#!/usr/bin/Rscript
#install.packages("inbreedR")
library(inbreedR)
# read input file
data <- read.table(args[1])
# convert input to binary file
inbreedr_snps <- convert_raw(data)
# calculate g2
g2_inbreedr_snps <- g2_snps(inbreedr_snps, nperm = 100, nboot = 10, CI = 0.95, parallel = FALSE, ncores = NULL)
str(g2_inbreedr_snps)
# calculate HHC
HHC_inbreedr_snps <- HHC(data, reps = 100)
str(HHC_inbreedr_snps)
mean(HHC_inbreedr_snps$HHC_vals)
sd(HHC_inbreedr_snps$HHC_vals)/sqrt(length(HHC_inbreedr_snps$HHC_vals))
# merge output and write it to args[2]