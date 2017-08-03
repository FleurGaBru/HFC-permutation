#change that name of initial ped/map name is given by the params. Maybe generate it automatically (look for ped/map file pair in data)
rule generate_bed:
    input:
        "/home/NIOO.INT/fleurg/projects/2017-015/HFC_permutation/data/cleaned_notstrict_hfc.map"
    output:
        "permutation/cleaned_notstrict_hfc.bed"
    shell:
        "plink2 --allow-extra-chr --chr-set 33 --file /home/NIOO.INT/fleurg/projects/2017-015/HFC_permutation/data/cleaned_notstrict_hfc --make-bed --out ./permutation/cleaned_notstrict_hfc"

# change that the number of SNPs is not hardcoded but is given in a param file
rule sample_bed:
    input:
        "permutation/cleaned_notstrict_hfc.bed"
    output:
        expand("permutation/cleaned_notstrict_hfc_1000_{replicate}.bed", replicate=range(1, 6))
    run:
        for i in range(1,6):
            shell("plink2 --allow-extra-chr --chr-set 33 --bfile ./permutation/cleaned_notstrict_hfc --thin-count 1000 --make-bed --out ./permutation/cleaned_notstrict_hfc_1000_{i}")
