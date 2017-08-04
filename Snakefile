REPLICATE = range(1, 6)
SAMPLES = ["cleaned_notstrict_hfc"]
#change that name of initial ped/map name is given by the params. Maybe generate it automatically (look for ped/map file pair in data)
# add the second extension (ped) to the input with expand {ext} ext=[]
rule generate_bed:
    input:
        "/home/NIOO.INT/fleurg/projects/2017-015/HFC_permutation/data/{sample}.map"
    output:
        "permutation/{sample}.bed"
    shell:
        "plink2 --allow-extra-chr --chr-set 33 --file /home/NIOO.INT/fleurg/projects/2017-015/HFC_permutation/data/{wildcards.sample} --make-bed --out ./permutation/{wildcards.sample}"

# change that the number of SNPs is not hardcoded but is given in a param file
# if you want to run this rule, you have to replcae {replicate} by a number!
# a variable in a bash command in python does not require "$"
# a range in python does not include the last number range(1,6)=[1,2,3,4,5]
rule sample_bed:
    input:
        "permutation/cleaned_notstrict_hfc.bed"
    output:
        "permutation/cleaned_notstrict_hfc_1000_{replicate}.bed"
    run:
        for i in range(1,6):
            shell("plink2 --allow-extra-chr --chr-set 33 --bfile ./permutation/cleaned_notstrict_hfc --thin-count 1000 --make-bed --out ./permutation/cleaned_notstrict_hfc_1000_{i}")
