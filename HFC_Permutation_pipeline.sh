#!/bin/bash
# 2017-06-21
# Author: Fleur Gawehns, f.gawehns-bruning@nioo.knaw.nl; Veronika Laine, v.laine@nioo.knaw.nl
# Title: HFC-permutation
# Project: 2017-015
#==========================================================================================
# workdir should be the project dir
workdir=$(pwd)
# the data dir cotains the original ped and map file and the chromosome-size file

mkdir $workdir/permutation
mkdir $workdir/Froh
mkdir $workdir/Fhom
mkdir $workdir/inbreedR

data=$workdir/data
permutation=$workdir/permutation
Froh=$workdir/Froh
Fhom=$workdir/Fhom
inbreedR=$workdir/inbreedR

# Enter the number of sampled SNPs
echo "Please enter the number of random sampled SNPs followed by [ENTER]:"
read n

# First generate bed file for all permutations. this saves a lot of time in the nect step.
plink2 --allow-extra-chr --chr-set 33 --file $data/cleaned_notstrict_hfc --make-bed --out $permutation/plink

for i in {1..100}
do
  # sample a --thin-count number of SNPs
  plink2 --allow-extra-chr --chr-set 33 --bfile $permutation/plink --thin-count $n --make-bed --out ./permutation/plink_${n}_${i}
  # output is bed, bim, fam and log file

  plink2 --allow-extra-chr --chr-set 33 --bfile $permutation/plink_${n}_${i} --recode --out $permutation/plink_recode_${n}_${i}
  # output is a map, ped and log file

  plink2 --allow-extra-chr --chr-set 33 --file $permutation/plink_recode_${n}_${i} --homozyg --homozyg-window-snp 5 --homozyg-density 100 --homozyg-gap 1000 --homozyg-kb 100 --homozyg-snp 25 --homozyg-window-het 0 --homozyg-window-missing 2 --out $Froh/ROH_files_${n}_${i}
  # output is hom, hom.indiv and summary file

  # get the chromsome names of covered chromosomes
  chr=$(cat ./permutation/plink_100_recode.map | cut -f 1 | sort | uniq | sed 's/^/chr/g')
  touch ./Froh/chr_sizes_${n}_${i}.txt
  # get the chromsome sizes of covered chromosomes
  for k in $chr
  do
      cat data/chr_size_gtgenome1.1_.txt | sed 's/\t/ /g' | grep "$k " >> ./Froh/chr_sizes_${n}_${i}.txt
  done

  # sum up the chromosome sizes
  size=$(cat ./Froh/chr_sizes_${n}_${i}.txt | cut -f2 -d " "| awk '{s+=$1} END {print s}')

  # remove the white spaces in the hom.indiv file and replace by tabs
  cat $Froh/ROH_files_${n}_${i}.hom.indiv | sed 's/^ \+ //g' | sed 's/^ //g'| sed 's/ \+ /\t/g' | sed 's/ /\t/g' > $Froh/ROH_files_${n}_${i}.hom.indiv.fixed

  # Devide KB by Size of the genome
  cat $Froh/ROH_files_${n}_${i}.hom.indiv.fixed | awk -v x="$size" '{print $5/x}' - > $Froh/Froh_temp_${n}_${i}.txt

  # Paste the Froh values to the ROH output and remove the temporary file
  paste $Froh/ROH_files_${n}_${i}.hom.indiv.fixed $Froh/Froh_temp_${n}_${i}.txt | sed '1 s/0/FROH/' > $Froh/Froh_${n}_${i}.txt
  rm ./Froh/Froh_temp_${n}_${i}.txt

  # Calculate Fhom
  plink2 --allow-extra-chr --chr-set 33 --file $permutation/plink_recode_${n}_${i} --het --out $Fhom/HET_files_${n}_${i}
  # output .HET and .log file

  # Remove the white spaces from Plink output and devide O(HOM) by N(HOM)
  cat $Fhom/HET_files_${n}_${i}.het | sed 's/^ \+ //g' | sed 's/^ //g'| sed 's/ \+ /\t/g' | sed 's/ /\t/g' > $Fhom/HET_files_${n}_${i}.het.fixed
  cat $Fhom/HET_files_${n}_${i}.het.fixed | sed '1d' | awk '{print $3/$5}' | sed '1s/^/FHOM\n/' > $Fhom/Fhom_temp_${n}_${i}.txt

  # Paste Fhom values to the Plink output and remove the temp file
  paste $Fhom/HET_files_${n}_${i}.het.fixed $Fhom/Fhom_temp_${n}_${i}.txt > $Fhom/Fhom_${n}_${i}.txt
  rm $Fhom/Fhom_temp_${n}_${i}.txt

  # inbreedR
  # keep all columns from 7 on and replace 0 by NA
   cat $permutation/plink_recode_${n}_${i}.ped | cut -d " " -f 7- | sed 's/0/NA/g' > $inbreedR/input_${n}_${i}.txt
   ./script.R $inbreedR/input_${n}_${i}.txt $inbreedR/out_${n}_${i}.txt
done
