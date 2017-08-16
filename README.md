Contents
========

* [How to use this file](#how-to-use-this-file)
* [Introduction](#introduction)
* [Login on the server](#login-on-the-server)
* [Copying the pipeline](#copying-the-pipeline)
* [Directories](#directories)
* [Prerequisites](#prerequisites)
* [Start the pipeline](#start-the-pipeline)
* [More Reading](#more-reading)


How to use this file
---------------------

This README file gives a global introduction on how to work on the server, cloning the pipeline repository and how to run the pipeline. We tried to be as complete and precise as possible.
If you have any question, comment, complain or suggestion or if you encounter any conflicts or errors in this document or the pipeline, please contact your Bioinformatics Unit (Bioinformatics-support@nioo.knaw.nl) or open an `Issue`!

###### Enjoy your analysis and happy results!

```
Text written in boxes is code, which usually can be executed in your Linux terminal. You can just copy/paste it.
Sometimes it is "special" code for R or any other language. If this is the case, it will be explicitly mentioned in the instructions.
```

`Text in a red box indicates directory or file names`

Text in brackets "<>" indicates that you have to replace it and the brackets by your own appropiate text.

Introduction
------------

With this pipeline you perform a permutation analysis of the heterozygosity–fitness correlation (HFC) of a population. This pipeline was generated to serve the analysis of a great tit population and to sample a x number of SNPs randomly for a 100 times from .map and .ped input files. The pipeline results in three main output tables:
1. Plink generated Froh values for each SNP sample of size x
2. Plink generated Fhom values for each SNP sample of size x
3. inbreedR generated values for each SNP sample of size x. You can check the invoked R file script `script-p.r` for more details.

Login on the server
------------------

If you will login to the bioinformatics server for the first time, please contact the BU or refer to the tutorial on gitlab (https://gitlab.bioinf.nioo.knaw.nl/tutorials/server-login) or download the corresponding .pdf from the left hand site on the intranet (https://intranet.nioo.knaw.nl/en/bioinformatics-unit).

Copying the pipeline
------------------

To start a new analysis project based on this pipeline, follow the following steps:

- Clone and rename the pipeline-skeleton from our GitLab server by typing in the terminal. Replace <name> by your NIOO login-name. Cloning will only work, if you have logged in to gitlab at least once before:

```
git clone https://<name>@gitlab.bioinf.nioo.knaw.nl/pipelines/HFC-permutation.git
```

- Enter `HFC-permutation`

```
cd HFC-permutation
```

Directories
--------------------------

##### The toplevel `README` file

This file contains this file with general information about how to run this pipeline.

##### The `data` directory

Place your plink .ped and .map file here. Also contains a file with the length of all chromosomes. If you do not use great tip, please replace it by the appropriate values but save the file under the same name.

##### The `docs` directory

Contains templates for the concatenated results file. Templates for the Froh and Fhom output `Froh.tmp` and `Fhom.tmp` contain a single column with all family ID names. The template for inbreedR `inbreedR.tmp` contains a single column with all values calculated by the package (g2, g2_p_val, g2_se, mean_HCC, sd_HCC). Please adjust the files appropriately, before running the pipeline.

##### The `docs` directory

Originally, this pipeline was written in pure bash code and parallelized with gnu parallels. The original scripts are stored in a sub-directory. All older versions of the snakemake pipeline (work-in-progress) are also deposited here.

##### The `results, permutation, Froh, Fhom, inbreedR, scratch` directories

These directories are not copied by cloning but will be produced during execution of the pipeline. Your final results will be found in `results` all other intermediate results will be stored in one of the corresponding directories.

Prerequisites
------------------

You have to install `plink` using conda before starting the pipeline:

```
conda create -n plink2
source activate plink2
conda install -c bioconda plink2=1.90b3.35
```

if you already have created the environment `plink2`, than activate it by

```
source activate plink2
```

You can deactivate the environment after pipeline execution with

```
source deactivate
```

Start the pipeline
------------------

1. Activate the snake environment (see [Prerequisites](#prerequisites) for detailed instructions).

```
source activate plink2
```

2. Adjust or create input files in the `data` directory.

see [Directories](#directories)

3. Adjust `config.yaml`

Open and adjust the config file, appropriately:

```
nano config.yaml
```

prefix: The basename of your .ped and .map files in data
snp: The number of SNP's you want to sample, randomly.
range: The number of times you want to sample. 

4. Execute the pipeline

Make sure that you are in the executive directory `HFC-permutation` and perform a dry run:

```
snakemake -np
```

If everything looks fine, run the pipeline with:

```
snakemake -p
```

More Reading
------------------

[PLINK 2.0 alpha](https://www.cog-genomics.org/plink/2.0/)
