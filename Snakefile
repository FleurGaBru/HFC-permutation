rule generate_bed:
    input:
        "/home/NIOO.INT/fleurg/projects/2017-015/HFC_permutation/data/cleaned_notstrict_hfc.map"
    output:
        "permutation/cleaned_notstrict_hfc.bed"
    shell:
        "plink2 --allow-extra-chr --chr-set 33 --file /home/NIOO.INT/fleurg/projects/2017-015/HFC_permutation/data/cleaned_notstrict_hfc --make-bed --out ./permutation/cleaned_notstrict_hfc"
