## HFC-permutation pipeline

#### Authors: Fleur Gawehns, Veronika Laine

------------------------------------------

### How to run the pipeline
```bash
# replace <user-name> by your own NIOO login-name, e.g FleurG
git clone https://<user-name>@gitlab.bioinf.nioo.knaw.nl/pipelines/HFC-permutation.git

# create a conda environment for plink2
conda create -n plink2
source activate plink2
conda install -c bioconda plink2=1.90b3.35

# 