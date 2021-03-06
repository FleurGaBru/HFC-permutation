# 2017-08-15
# Author: Fleur Gawehns, f.gawehns-bruning@nioo.knaw.nl; Veronika Laine, V.Laine@nioo.knaw.nl
# Title: HFC-permutation pipeline
#==========================================================================================

## New version because {prefix} in v2 expects a prefix being invoked via the set output file on the command line. This approache crashes when adding a rule all.
##SNAKEMAKE DOES NOT LIKE "" IN SHELL COMMANDS!!!!!!!!
##Naming a params "input" delivers a syntax error
configfile: "config.yaml"
SNP = str(config["snp"])
PREFIX = config["prefix"]
RANGE = map(str, range(1,config["range"]))
RANGE_INT = range(1,config["range"])
END= str(config["range"]-1)

import os

rule all:
    input:
        expand("scratch/Froh.temp.{prefix}.{snp}.{range}.txt", prefix=PREFIX, snp=SNP, range=RANGE),
        expand("results/Froh.{prefix}.{snp}.{end}.txt", prefix=PREFIX, snp=SNP, end=END),
        expand("scratch/Fhom.temp.{prefix}.{snp}.{range}.txt", prefix=PREFIX, snp=SNP, range=RANGE),
        expand("results/Fhom.{prefix}.{snp}.{end}.txt", prefix=PREFIX, snp=SNP, end=END),
        expand("inbreedR/output.{prefix}.{snp}.{range}.txt", prefix=PREFIX, snp=SNP, range=RANGE),
        expand("results/inbreedR.{prefix}.{snp}.{end}.txt", prefix=PREFIX, snp=SNP, end=END)

rule generate_bed:
    input:
        ped= os.path.join("data", PREFIX + ".ped"),
        map= os.path.join("data", PREFIX + ".map")
    output:
        expand("permutation/{prefix}.{ext}", prefix=PREFIX, ext=["bed", "bim", "fam"])
    params:
        os.path.join("permutation", PREFIX)
    shell:
        "plink2 --allow-extra-chr --chr-set 33 --ped {input.ped} --map {input.map} --make-bed --out {params[0]}"

# Range in loop has to be a list of integers!
rule create_thinned_plink:
    input:
        bed= os.path.join("permutation", PREFIX + ".bed"),
        bim= os.path.join("permutation", PREFIX + ".bim"),
        fam= os.path.join("permutation", PREFIX + ".fam")
    output:
        "permutation/{prefix}.ped", "permutation/{prefix}.map"
    params:
        "permutation/{prefix}"
    run:
        for i in RANGE_INT:
          shell("plink2 --allow-extra-chr --chr-set 33 --bed {input.bed} --bim {input.bim} --fam {input.fam} --thin-count {SNP} --make-bed --out ./permutation/{PREFIX}.{SNP}.{i}")
          shell("plink2 --allow-extra-chr --chr-set 33 --bfile ./permutation/{PREFIX}.{SNP}.{i} --recode --out ./permutation/{PREFIX}.{SNP}.{i}")

rule make_ROH:
    input:
        map= "permutation/{prefix}.map",
        ped= "permutation/{prefix}.ped"
    output:
        "Froh/ROH.{prefix}.fixed.hom.indiv"
    params:
        "Froh/ROH.{prefix}"
    shell:"""
        plink2 --allow-extra-chr --chr-set 33 --ped {input.ped} --map {input.map} --homozyg --homozyg-window-snp 5 --homozyg-density 100 --homozyg-gap 1000 --homozyg-kb 100 --homozyg-snp 25 --homozyg-window-het 0 --homozyg-window-missing 2 --out {params}
        cat {params}.hom.indiv | sed 's/^ \+ //g' | sed 's/^ //g'| sed 's/ \+ /\t/g' | sed 's/ /\t/g' > {output}
        """

# use \\ as escape with "", otherwise snakemake gives an syntax error
rule covered_chr:
    input:
        chr= "data/chr_size_gtgenome1.1_.txt",
        map= "permutation/{prefix}.map"
    output:
        "scratch/chrsizes.{prefix}.txt"
    shell:"""
        chr=$(cat {input.map} | cut -f 1 | sort | uniq | sed 's/^/chr/g')
        touch {output}
        for k in $chr
        do
          cat {input.chr} | sed 's/\t/ /g' | grep \"$k \" >> {output}
        done
        """

rule calculate_Froh:
    input:
        chr= "scratch/chrsizes.{prefix}.txt",
        ROH= "Froh/ROH.{prefix}.fixed.hom.indiv"
    output:
        temp= "scratch/Froh.temp.{prefix}.txt"
    params:
        header= "{prefix}"
    shell:"""
        size=$(cat {input.chr} | cut -f2 -d \" \"| awk '{{s+=$1}} END {{print s}}')
        sizeKB=$(($size/1000))
        cat {input.ROH} | awk -v x="$sizeKB" '{{print $5/x}}' | sed '1 s/0/{params.header}/'  > {output.temp}
        """

# here range has to be integers! Otherwise input will not be recognized. This rule needs the Froh.temp output. This one also has to go to the rule all!
rule concanate_Froh:
    input:
        expand("scratch/Froh.temp.{prefix}.{snp}.{range}.txt", prefix=PREFIX, snp=SNP, range=RANGE_INT)
    output:
        expand("results/Froh.{prefix}.{snp}.{end}.txt", prefix=PREFIX, snp=SNP, end=END)
    params:
        "docs/Froh.tmp"
    shell:"""
        paste {params} {input} > {output}
        """

rule get_HET_files:
    input:
        map= "permutation/{prefix}.map",
        ped= "permutation/{prefix}.ped"
    output:
        "Fhom/HET_files.{prefix}.fixed.het"
    params:
        "Fhom/HET_files.{prefix}"
    shell:"""
        plink2 --allow-extra-chr --chr-set 33 --ped {input.ped} --map {input.map} --het --out {params}
        cat {params}.het | sed 's/^ \+ //g' | sed 's/^ //g'| sed 's/ \+ /\t/g' | sed 's/ /\t/g' > {output}
        """

#sed statement needs \ in front of \n as an escape. Otherwise shell command is split and does not work.
rule calculate_Fhom:
    input:
        "Fhom/HET_files.{prefix}.fixed.het"
    output:
        temp= "scratch/Fhom.temp.{prefix}.txt"
    params:
        header= "{prefix}"
    shell:"""
        cat {input} | sed '1d' | awk '{{print $3/$5}}' | sed '1s/^/{params.header}\\n/' > {output.temp}
        """

rule concanate_Fhom:
    input:
        expand("scratch/Fhom.temp.{prefix}.{snp}.{range}.txt", prefix=PREFIX, snp=SNP, range=RANGE_INT)
    output:
        expand("results/Fhom.{prefix}.{snp}.{end}.txt", prefix=PREFIX, snp=SNP, end=END)
    params:
        "docs/Fhom.tmp"
    shell:"""
        paste {params} {input} > {output}
        """

rule run_inbreedR:
    input:
        "permutation/{prefix}.ped"
    output:
        "inbreedR/output.{prefix}.txt"
    params:
        inR= "inbreedR/input.{prefix}.txt",
        header= "{prefix}"
    shell:"""
        cat {input} | cut -d \" \" -f 7- | sed 's/0/NA/g' > {params.inR}
        /usr/bin/Rscript ./script-p.r {params.inR} {output}
        sed -i 's/x/{params.header}/' {output}
        """

rule concanate_inbreedR:
    input:
        expand("inbreedR/output.{prefix}.{snp}.{range}.txt", prefix=PREFIX, snp=SNP, range=RANGE_INT)
    output:
        expand("results/inbreedR.{prefix}.{snp}.{end}.txt", prefix=PREFIX, snp=SNP, end=END)
    params:
        "docs/inbreedR.tmp"
    shell:"""
        paste {params} {input} > {output}
        """
