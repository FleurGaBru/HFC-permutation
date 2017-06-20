- Permutation 100, 1000, 10 000, 50 000, 100 000 SNPs
- Calculate homozygosity values, g2, HHC.
- Repeat 100 times

1. Take random set of 100, 1000, 10 000, 50 000, 100 000 SNPs
    * PLINK --thin 0.2 (a random 20% of SNPs)
    * or something else (R sample)

```
plink2 --allow-extra-chr --chr-set 33 --file ./data/cleaned_notstrict_hfc --thin-count 100 --make-bed --out ./analysis/plink_100

1031971 MB RAM detected; reserving 515985 MB for main workspace.
.ped scan complete (for binary autoconversion).
Performing single-pass .bed write (446699 variants, 2143 samples).
--file: ./analysis/plink_100-temporary.bed + ./analysis/plink_100-temporary.bim
+ ./analysis/plink_100-temporary.fam written.
446699 variants loaded from .bim file.
2143 samples (0 males, 2143 females) loaded from .fam.
2143 phenotype values loaded from .fam.
--thin-count: 446599 variants removed (100 remaining).
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 2143 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.995964.
100 variants and 2143 samples pass filters and QC.
Phenotype data is quantitative.
--make-bed to ./analysis/plink_100.bed + ./analysis/plink_100.bim +
./analysis/plink_100.fam ... done.

plink2 --bfile binary_fileset --recode --out new_text_fileset
```

2. Calculate Froh
  * PLINK    --homozyg --homozyg-window-snp 5 --homozyg-density 100 --homozyg-gap 1000 --homozyg-kb 100 --homozyg-snp 25 --homozyg-window-het 0 --homozyg-window-missing 2
  * From the result files Froh = KB/genome size
  * Needs the chromosomes covered (genome size) in order to calculate Froh, varies from the sampling, if a chromosome is covered by at least 1 SNP, it is covered and added to the genome size

3. Calculate Fhom
    * PLINK --het
    * From the results Fhom = O(HOM)/N(NM)

4. Inbreedr (R based) —> slow for 50000 or 100000
    * Ped-files need to be made ready for Inbreedr:
        * *first columns out
        * *0 -> NA

5. use command line to do the transformation
    * convert_raw
    * g2_snps
    * HHC
 
Plink normal files, chrs as numbers. Chr size file.

#### final: per 100x permutation average Froh, average Fhom, average g2_snps and HHC
