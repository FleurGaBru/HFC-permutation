- Permutation 100, 1000, 10 000, 50 000, 100 000 SNPs
- Calculate homozygosity values, g2, HHC.
- Repeat 100 times

1. Take random set of 100, 1000, 10 000, 50 000, 100 000 SNPs
a. PLINK --thin 0.2 (a random 20% of SNPs)
b. or something else (R sample)

2. Calculate Froh
  a. PLINK    --homozyg --homozyg-window-snp 5 --homozyg-density 100 --homozyg-gap 1000 --homozyg-kb 100 --homozyg-snp 25 --homozyg-window-het 0 --homozyg-window-missing 2
  b. From the result files Froh = KB/genome size
  c. Needs the chromosomes covered (genome size) in order to calculate Froh, varies from the sampling, if a chromosome is covered by at least 1 SNP, it is covered and added to the genome size

3. Calculate Fhom
a. PLINK --het
b. From the results Fhom = O(HOM)/N(NM)
4. Inbreedr (R based) —> slow for 50000 or 100000
a. Ped-files need to be made ready for Inbreedr
1. *first columns out
2. *0 -> NA
use command line to do the transformation
b. convert_raw
c. g2_snps
d. HHC
 
Plink normal files, chrs as numbers. Chr size file.

final: per 100x permutation average Froh, average Fhom, average g2_snps and HHC
