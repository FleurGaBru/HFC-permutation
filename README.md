- Permutation 100, 1000, 10 000, 50 000, 100 000 SNPs
- Calculate homozygosity values, g2, HHC.
- Repeat 100 times

1. Take random set of 100, 1000, 10 000, 50 000, 100 000 SNPs
    * PLINK --thin 0.2 (a random 20% of SNPs)
    * or something else (R sample)

```bash

# First generate bed file for all permutations. this saves a lot of time in the nect step.
plink2 --allow-extra-chr --chr-set 33 --file ./data/cleaned_notstrict_hfc --make-bed --out ./permutation/plink

# sample a --thin-count number of SNPs
plink2 --allow-extra-chr --chr-set 33 --bfile ./permutation/plink --thin-count 100 --make-bed --out ./permutation/plink_100
# output is bed, bim, fam and log file

# 1031971 MB RAM detected; reserving 515985 MB for main workspace.
# .ped scan complete (for binary autoconversion).
# Performing single-pass .bed write (446699 variants, 2143 samples).
# --file: ./analysis/plink_100-temporary.bed + ./analysis/plink_100-temporary.bim
# + ./analysis/plink_100-temporary.fam written.
# 446699 variants loaded from .bim file.
# 2143 samples (0 males, 2143 females) loaded from .fam.
# 2143 phenotype values loaded from .fam.
# --thin-count: 446599 variants removed (100 remaining).
# Using 1 thread (no multithreaded calculations invoked).
# Before main variant filters, 2143 founders and 0 nonfounders present.
# Calculating allele frequencies... done.
# Total genotyping rate is 0.995964.
# 100 variants and 2143 samples pass filters and QC.
# Phenotype data is quantitative.
# --make-bed to ./analysis/plink_100.bed + ./analysis/plink_100.bim +
# ./analysis/plink_100.fam ... done.

plink2 --allow-extra-chr --chr-set 33 --bfile ./permutation/plink_100 --recode --out ./permutation/plink_100_recode
# output is a map, ped and log file

```

2. Calculate Froh
  * PLINK    --homozyg --homozyg-window-snp 5 --homozyg-density 100 --homozyg-gap 1000 --homozyg-kb 100 --homozyg-snp 25 --homozyg-window-het 0 --homozyg-window-missing 2

```bash
plink2 --allow-extra-chr --chr-set 33 --file ./permutation/plink_100_recode  --homozyg --homozyg-window-snp 5 --homozyg-density 100 --homozyg-gap 1000 --homozyg-kb 100 --homozyg-snp 25 --homozyg-window-het 0 --homozyg-window-missing 2 --out ./Froh/ROH_files_100
# output is hom, hom.indiv and summary file

# 1031971 MB RAM detected; reserving 515985 MB for main workspace.
# .ped scan complete (for binary autoconversion).
# Performing single-pass .bed write (100 variants, 2143 samples).
# --file: ./analysis/ROH_files_100-temporary.bed +
# ./Froh/ROH_files_100-temporary.bim + ./Froh/ROH_files_100-temporary.fam
# written.
# 100 variants loaded from .bim file.
# 2143 samples (0 males, 2143 females) loaded from .fam.
# 2143 phenotype values loaded from .fam.
# Using 1 thread (no multithreaded calculations invoked).
# Before main variant filters, 2143 founders and 0 nonfounders present.
# Calculating allele frequencies... done.
# Total genotyping rate is 0.995964.
# 100 variants and 2143 samples pass filters and QC.
# Phenotype data is quantitative.
# --homozyg: Scan complete, found 0 ROH.
# Results saved to ./analysis/ROH_files_100.hom +
# ./Froh/ROH_files_100.hom.indiv + ./Froh/ROH_files_100.hom.summary .
```

  * From the result files Froh = KB/genome size
  * Needs the chromosomes covered (genome size) in order to calculate Froh, varies from the sampling, if a chromosome is covered by at least 1 SNP, it is covered and added to the genome size

```bash
# get the chromsome names of covered chromosomes
chr=$(cat ./permutation/plink_100_recode.map | cut -f 1 | sort | uniq | sed 's/^/chr/g')
touch ./Froh/chr_sizes.txt
# get the chromsome sizes of covered chromosomes
for i in $chr
do
    cat data/chr_size_gtgenome1.1_.txt | sed 's/\t/ /g' | grep "$i " >> ./Froh/chr_sizes.txt
done

# sum up the chromosome sizes
size=$(cat ./Froh/chr_sizes.txt | cut -f2 -d " "| awk '{s+=$1} END {print s}')

# remove the white spaces in the hom.indiv file and replace by tabs
cat ./Froh/ROH_files_100.hom.indiv | sed 's/^ \+ //g' | sed 's/^ //g'| sed 's/ \+ /\t/g' | sed 's/ /\t/g' > ./Froh/ROH_files_100.hom.indiv.fixed

# Devide KB by Size of the genome
cat ./Froh/ROH_files_100.hom.indiv.fixed | awk -v x="$size" '{print $5/x}' - > ./Froh/Froh_100_temp.txt

# Paste the Froh values to the ROH output and remove the temporary file
paste ./Froh/ROH_files_100.hom.indiv.fixed ./Froh/Froh_100_temp.txt | sed '1 s/0/FROH/' > ./Froh/Froh_100.txt
rm ./Froh/Froh_100_temp.txt

```
3. Calculate Fhom
    * PLINK --het

```bash
plink2 --allow-extra-chr --chr-set 33 --file ./permutation/plink_100_recode --het --out ./Fhom/HET_files_100
# output .HET and .log file

# 1031971 MB RAM detected; reserving 515985 MB for main workspace.
# .ped scan complete (for binary autoconversion).
# Performing single-pass .bed write (100 variants, 2143 samples).
# --file: ./Fhom/HET_files_100-temporary.bed + ./Fhom/HET_files_100-temporary.bim
# + ./Fhom/HET_files_100-temporary.fam written.
# 100 variants loaded from .bim file.
# 2143 samples (0 males, 2143 females) loaded from .fam.
# 2143 phenotype values loaded from .fam.
# Using 1 thread (no multithreaded calculations invoked).
# Before main variant filters, 2143 founders and 0 nonfounders present.
# Calculating allele frequencies... done.
# Total genotyping rate is 0.995964.
# 100 variants and 2143 samples pass filters and QC.
# Phenotype data is quantitative.
# --het: 100 variants scanned, report written to ./Fhom/HET_files_100.het .

```

    * From the results Fhom = O(HOM)/N(NM)

```bash
# Remove the white spaces from Plink output and devide O(HOM) by N(HOM)
cat ./Fhom/HET_files_100.het | sed 's/^ \+ //g' | sed 's/^ //g'| sed 's/ \+ /\t/g' | sed 's/ /\t/g' > ./Fhom/HET_files_100.het.fixed
cat ./Fhom/HET_files_100.het.fixed | sed '1d' | awk '{print $3/$5}' | sed '1s/^/FHOM\n/' > ./Fhom/Fhom_100_temp.txt

# Paste Fhom values to the Plink output and remove the temp file
 paste ./Fhom/HET_files_100.het.fixed ./Fhom/Fhom_100_temp.txt > Fhom/Fhom_100.txt
rm Fhom/Fhom_100_temp.txt
```

4. Inbreedr (R based) —> slow for 50000 or 100000
    * Ped-files need to be made ready for Inbreedr:
        * *first columns out
        * *0 -> NA

```bash
# keep all columns from 7 on and replace 0 by NA
 cat ./permutation/plink_100_recode.ped | cut -d " " -f 7- | sed 's/0/NA/g' > ./inbreedr/input_100.txt
```

5. use command line to do the transformation
    * convert_raw
    * g2_snps
    * HHC
 
Plink normal files, chrs as numbers. Chr size file.

#### final: per 100x permutation average Froh, average Fhom, average g2_snps and HHC
