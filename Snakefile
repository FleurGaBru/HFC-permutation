configfile: "config.yaml"
REPLICATE = config["replicate"]
# SAMPLES = ["cleaned_notstrict_hfc"]
# FORMAT = ["map", "ped"]
#change that name of initial ped/map name is given by the params. Maybe generate it automatically (look for ped/map file pair in data)
# add the second extension (ped) to the input with expand {ext} ext=[]
rule generate_bed:
    input:
        # expand("data/{sample}.{ext}", sample=config["samples"], ext=FORMAT)
        lambda wildcards: config["samples"][wildcards.sample]
    output:
        "permutation/{sample}.bed"
    shell:
        "plink2 --allow-extra-chr --chr-set 33 --file ./data/{wildcards.sample} --make-bed --out ./permutation/{wildcards.sample}"

# change that the number of SNPs is not hardcoded but is given in a param file
# if you want to run this rule, you have to replcae {replicate} by a number!
# a variable in a bash command in python does not require "$"
# a range in python does not include the last number range(1,6)=[1,2,3,4,5]
rule sample_bed:
    input:
        "permutation/{sample}.bed"
    output:
        "permutation/{sample}_1000_{replicate}.bed"
    run:
        for i in {wildcards.replicate}:
            shell("plink2 --allow-extra-chr --chr-set 33 --bfile ./permutation/{wildcards.sample} --thin-count 1000 --make-bed --out ./permutation/{wildcards.sample}_1000_{i}")
