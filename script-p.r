#!/usr/bin/Rscript
arg <- commandArgs(trailingOnly=TRUE)
system("defaults write org.R-project.R force.LANG en_US.UTF-8")
#install.packages("inbreedR")
library(inbreedR)
# read input file
data <- read.table(arg[1])
# convert input to binary file
inbreedr_snps <- convert_raw(data)
# calculate g2
g2_inbreedr_snps <- g2_snps(inbreedr_snps, nperm = 100, nboot = 10, CI = 0.95, parallel = TRUE, ncores = 8)
# calculate HHC
HHC_inbreedr_snps <- HHC(inbreedr_snps, reps = 100)
# calculate the mean of all HHC values
mean_HCC <- mean(HHC_inbreedr_snps$HHC_vals)
#  calculate the standard deviation of HHC
sd_HCC <- sd(HHC_inbreedr_snps$HHC_vals)
# calculate the standarderror of HHC
#sd(HHC_inbreedr_snps$HHC_vals)/sqrt(length(HHC_inbreedr_snps$HHC_vals))
g2 <- g2_inbreedr_snps$g2
g2_p_val <- g2_inbreedr_snps$p_val
g2_se <- g2_inbreedr_snps$g2_se
x <- c(g2, g2_p_val, g2_se, mean_HCC, sd_HCC)
table <- data.frame(x, row.names=c("g2", "g2_p_val", "g2_se", "mean_HCC", "sd_HCC"))
write.table(table, file=arg[2], sep="\t", row.names = FALSE, quote = FALSE)
