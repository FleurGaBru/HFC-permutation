#!/bin/bash
# 2017-06-21
# Author: Fleur Gawehns, f.gawehns-bruning@nioo.knaw.nl; Veronika Laine, v.laine@nioo.knaw.nl
# Title: HFC-permutation
# Project: 2017-015
#==========================================================================================

# workdir should be the project dir
workdir=$(pwd)
# the data dir cotains the original ped and map file and the chromosome-size file

#mkdir $workdir/permutation
#mkdir $workdir/Froh
#mkdir $workdir/Fhom
#mkdir $workdir/inbreedR
#mkdir $workdir/results
data=$workdir/data
permutation=$workdir/permutation
Froh=$workdir/Froh
Fhom=$workdir/Fhom
inbreedR=$workdir/inbreedR
results=$workdir/results


# Enter the number of sampled SNPs
echo "Please enter the number of random sampled SNPs followed by [ENTER]:"
read n

# First generate bed file for all permutations. this saves a lot of time in the next step.
plink2 --allow-extra-chr --chr-set 33 --file $data/cleaned_notstrict_hfc --make-bed --out $permutation/plink

foo () {
  i=$1
  n=$2
  workdir=$3
  data=$workdir/data
  permutation=$workdir/permutation
  Froh=$workdir/Froh
  Fhom=$workdir/Fhom
  inbreedR=$workdir/inbreedR
  results=$workdir/results

  # sample a --thin-count number of SNPs
  plink2 --allow-extra-chr --chr-set 33 --bfile $permutation/plink --thin-count $n --make-bed --out ./permutation/plink_${n}_${i}
  # output is bed, bim, fam and log file

  plink2 --allow-extra-chr --chr-set 33 --bfile $permutation/plink_${n}_${i} --recode --out $permutation/plink_recode_${n}_${i}
  # output is a map, ped and log file
	
  #Calculate Froh
  plink2 --allow-extra-chr --chr-set 33 --file $permutation/plink_recode_${n}_${i} --homozyg --homozyg-window-snp 5 --homozyg-density 100 --homozyg-gap 1000 --homozyg-kb 100 --homozyg-snp 25 --homozyg-window-het 0 --homozyg-window-missing 2 --out $Froh/ROH_files_${n}_${i}
  # output is hom, hom.indiv and summary file

  # get the chromsome names of covered chromosomes
  chr=$(cat ./permutation/plink_recode_${n}_${i}.map | cut -f 1 | sort | uniq | sed 's/^/chr/g')
  touch ./Froh/chr_sizes_${n}_${i}.txt

  # get the chromsome sizes of covered chromosomes
  for k in $chr
  do
      cat data/chr_size_gtgenome1.1_.txt | sed 's/\t/ /g' | grep "$k " >> ./Froh/chr_sizes_${n}_${i}.txt
  done

  # sum up the chromosome sizes
  size=$(cat ./Froh/chr_sizes_${n}_${i}.txt | cut -f2 -d " "| awk '{s+=$1} END {print s}')
  
  # Later the genome size has to be devided by the KB column of the ROH file. Change the genome size to KB
  # sizeKB=$(($size/1000)) , and change $size to $sizeKB in the script below

  # remove the white spaces in the hom.indiv file and replace by tabs
  cat $Froh/ROH_files_${n}_${i}.hom.indiv | sed 's/^ \+ //g' | sed 's/^ //g'| sed 's/ \+ /\t/g' | sed 's/ /\t/g' > $Froh/ROH_files_${n}_${i}.hom.indiv.fixed

  # Devide KB by Size of the genome
  cat $Froh/ROH_files_${n}_${i}.hom.indiv.fixed | awk -v x="$size" '{print $5/x}' | sed '1 s/0/'$i'/'  > $Froh/Froh_temp_${n}_${i}.txt

  # Paste the Froh values to the ROH output
  paste $Froh/ROH_files_${n}_${i}.hom.indiv.fixed $Froh/Froh_temp_${n}_${i}.txt | sed '1 s/'$i'/FROH/' > $Froh/Froh_${n}_${i}.txt

  # Calculate Fhom
  plink2 --allow-extra-chr --chr-set 33 --file $permutation/plink_recode_${n}_${i} --het --out $Fhom/HET_files_${n}_${i}
  # output .HET and .log file

  # Remove the white spaces from Plink output and devide O(HOM) by N(HOM)
  cat $Fhom/HET_files_${n}_${i}.het | sed 's/^ \+ //g' | sed 's/^ //g'| sed 's/ \+ /\t/g' | sed 's/ /\t/g' > $Fhom/HET_files_${n}_${i}.het.fixed
  cat $Fhom/HET_files_${n}_${i}.het.fixed | sed '1d' | awk '{print $3/$5}' | sed '1s/^/'$i'\n/' > $Fhom/Fhom_temp_${n}_${i}.txt

  # Paste Fhom values to the Plink output
  paste $Fhom/HET_files_${n}_${i}.het.fixed $Fhom/Fhom_temp_${n}_${i}.txt > $Fhom/Fhom_${n}_${i}.txt

  # inbreedR
  # keep all columns from 7 on and replace 0 by NA
   cat $permutation/plink_recode_${n}_${i}.ped | cut -d " " -f 7- | sed 's/0/NA/g' > $inbreedR/input_${n}_${i}.txt
   /usr/bin/Rscript ./script-p.r $inbreedR/input_${n}_${i}.txt $inbreedR/out_${n}_${i}.txt ${i}
   sed -i 's/x/'$i'/' $inbreedR/out_${n}_${i}.txt
}
parallel --record-env
export -f foo
echo  {1..100} | tr " " "\n" | parallel --env _ -j5  "foo {} $n $workdir" 

paste $results/out.tmp $inbreedR/out_${n}_* > $results/inbreedR_${n}.txt
paste $results/Fhom.tmp $Fhom/Fhom_temp_${n}_* > $results/Fhom_${n}.txt
paste $results/Froh.tmp $Froh/Froh_temp_${n}_* > $results/Froh_${n}.txt
