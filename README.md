# Pipeline is not tested for production yet!

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

With this pipeline you can analyse Illumina single-end reads from transcriptomics data of microbes. This instruction is adjusted to run a metagenomics mode but can be easily modified to run a single microbe, too.

* Fastqc quality check
* Read mapping using Bowtie2 (more options available?)
* Transcript quantification using [RSEM](http://bmcbioinformatics.biomedcentral.com/articles/10.1186/1471-2105-12-323)
* Differential Expression Analysis with [TrinityEmpirical](https://github.com/trinityrnaseq/trinityrnaseq/wiki/Trinity-Differential-Expression). You can choose between different methods:
    * Analysis of Digital Gene Expression Data in R, [EdgeR](https://bioconductor.org/packages/release/bioc/html/edgeR.html)
    * [DESeq2](http://bioconductor.org/packages/release/bioc/html/DESeq2.html)
    * [limma/voom](http://bioconductor.org/packages/release/bioc/html/limma.html)
    * [ROTS](http://www.btk.fi/research/research-groups/elo/software/rots/)

The references used in this pipeline rely on the output of the prokka annotation pipeline [here](https://gitlab.bioinf.nioo.knaw.nl/pipelines/prokka) and optionally on the cog annotation pipeline [here](https://gitlab.bioinf.nioo.knaw.nl/pipelines/cog-assign.git). You have to run these pipelines before you can start your transcriptome analysis. However, this document wille xplain how to concanate and transform the prokka and cog output to meet the requirements for this pipeline.

Login on the server
------------------
##### Your UserID:

userID = your NIOO ID (e.g. fleurg) and password.

##### Make the connection:

for Mac type in the Terminal:

```
ssh userID@nioo0025.nioo.int -X 
```

For Windows PC login via PuTTy or MobaXterm.

After login you are located in your home folder:

`/home/NIOO/<userID>`

##### Enter your project directory

```
cd <your>/<project>/<directory>
```

Copying the pipeline
------------------

To start a new analysis project based on this pipeline, follow the following steps:

- Clone and rename the pipeline-skeleton from our GitLab server by typing in the terminal:

```
git clone git@gitlab.bioinf.nioo.knaw.nl:pipelines/transcriptomics-microbes.git
```

- Enter `transcriptomics-microbes`

```
cd transcriptomics-microbes
```

Directories
--------------------------

##### The toplevel `README` file

This file contains general information about how to run this pipeline

##### The `data` directory

Used to place `samples_contrasts.txt` and `samples_described.txt`.
Contains the subdirectories `ref` and `reads`.

##### The `data/ref` directory

Should contain the concatenated *.ffn files from each single prokka annotation. Even if a species contains of multiple chromosomes, concanate them all. Ensure the ID's are consistent with the locus tags.

##### The `data/reads` directory

This directory contains a link to your raw data (#test if a link will work)

##### The `analysis` directory

This directory will contain all the resuts from this pipeline

##### The `src` directory

Custom scripts are stored here


Prerequisites
------------------

Snakemake runs under its own virtual environment. If you do not have a snakemake virtual environment, create one:

```
# source /data/tools/miniconda/4.2.12/env.sh, on nioo0002 miniconda is installed globally. You do not have to source it then.
conda create -n snake
source activate snake
# conda install snakemake, snakemake is also already installed globally on nioo0002. You do not have to install it again.
conda install biopython
```

if you already have the environment snake, than activate it by

```
source /data/tools/miniconda/4.2.12/env.sh
source activate snake
```

You can deactivate the environment again with 

```
source deactivate
```

The Transcriptomics-pipeline requires a number of installes tools:

* bowtie2
* bowtie
* bwa
* kallisto
* fastqc
* ea-utils
* trinity

Fortunately, those packages are already installed but you have to source them:

```
source env.sh
```

Start the pipeline
------------------

1) Activate the snake environment (see [Prerequisites](#prerequisites) for detailed instructions) and source the env.sh file if you have not done yet.

```
source /data/tools/miniconda/4.2.12/env.sh
source activate snake
source env.sh
```

2) Prepare the reference from prokka output. Concanate all relevant *.ffn files using

```
cat <path>/<to>/prokka/analysis/<file1>.ffn <path>/<to>/prokka/analysis/<file2>.ffn <path>/<to>/prokka/analysis/<...>.ffn > data/ref/reference.fasta
```

Ensure the ID's are consistent with the locus tags:

i.e.:

```
>AD56_00005 Transcriptional repressor NrdR
ATGCATTGCCCTTTCTGCCAGCACGAAGACACCCGCGTGATCGACTCACGCCTGACCGAG
```

3) Place a link to your raw read files. 

example:
```
ln -s <path>/<to>/<your>/<raw>/<reads> ./data/reads
```

4) Edit the config.json file to choose your aligner and define your `data` files.

```
nano ./doc/config.json.template
```

example config:

```
{
    "threads" : 32,
    "aligners" : "bowtie2",
    "reference" : "bAD24_gpAD87.cleaned.fasta",
    "kallisto" : "/data/tools/kallisto/default/bin/kallisto",
    "samples" : ["1",
                 "2",
                 "3",
                 "4",
                 "5",
                 "6",
                 "7",
                 "8",
		      "9"
                 ],
    "data": {
"T4-2-1": { "forward" : ["./data/reads/LN344/I16-1385-01-t4_2-1_S1_L001_R1_001.fastq.gz"]},
"T4-2-2": { "forward" : ["./data/reads/LN344/I16-1385-01-t4_2-1_S1_L001_R1_001.fastq.gz"]}
}
}
```


Close nano using ctrl+x. When saving, remove the current name (doc/config.json.template) and replace it by typing `config.json`. The config file is now saved in your main directory.


5) Make sure you are in the `transcriptomics-microbe` folder and run the RNAseq pipeline by:

```
snakemake -n
snakemake -j 6 (24 cores max)
```

6) Concanate the expression output with the prokka and cog annotations:

First change the prokka .gbk output for every single reference file that you used in the RNAseq pipeline to a tabular format by

```
./src/VDJ_prokka_gbk_to_txt.py -g <path>/<to>/prokka/analysis/<file1>.gbk -o ./analysis/<file1>.tsv
```

and concanate the output using

```
cat analysis/<file1>.tsv analysis/<file2>.tsv ... > ./data/ref/reference.tsv
```

The file has to be modified to meet the requirement of the R script later on:

```
cat ./data/ref/reference.tsv | cut -f1 -d " " > ./data/ref/id.txt
paste ./data/ref/id.txt ./data/ref/reference.tsv > ./data/ref/reference-id.tsv
```

Optional: Run the [cog-annotation pipeline](https://gitlab.bioinf.nioo.knaw.nl/pipelines/cog-assign.git) if you have not done yet. Concanate the output of more reference in one single file:

```
cat <path>/<to>/cog-assign/analysis/<file1>.faa.tab <path>/<to>/cog-assign/<file2>.faa.tab ... > ./data/ref/reference.faa.tab 
```

Run the following R code in R or R studio to merge three files (reference.tsv, reference.faa.tab, diffExpr.P<yourPvalue>_C0.585.matrix):

Read the annotation file generated with the python script

```R
annotation <- read.delim("./data/ref/reference-id.tsv", header=FALSE)
colnames(annotation)<-c("contig", "id", "start", "stop", "strand", "description")

# Optionally attach also the COG annotation:

cog <-read.delim2("./data/ref/reference.faa.tab", header=FALSE, sep="\t", flush=TRUE)
colnames(cog)<-c("id", "description", "cog", "cogdescription", "class", "classdescription")

# This generates the following annotation project:

annotation <- merge(annotation, cog, by="id", all.x=TRUE)

# Read the EdgeR expression data as generated by the workflow and add a column "ID":

diffExpr.P<yourPvalue>_C0.585 <- read.delim("/mnt/data/ngs/ME/garbeva_group/ruths/illumina-microbial-transcriptomics/analysis/rsem_matrix/edgeR/diffExpr.P<yourPvalue>_C0.585.matrix")
colnames(diffExpr.<yourPvalue>_C0.585)[1]<-c("id")

# Merge the annotation and write a file to the EdgeR_matrix folder:

diffExpr.P<yourPvalue>_C0.585 <- merge(diffExpr.<yourPvalue>_C0.585, annotation, by='id', all.x=TRUE)
write.table(diffExpr.P0.<yourPvalue>_C0.585, file = "./analysis/rsem_matrix/edgeR/diffExpr.P<yourPvalue>_C0.585.annotated.matrix", sep="\t", col.names=TRUE)
```

More Reading
------------------

[Kallisto](https://pachterlab.github.io/kallisto/ http://pachterlab.github.io/sleuth)

[https://www.biostars.org/p/143458/#157303](https://www.biostars.org/p/143458/#157303)

About the output use [Trinity](https://github.com/trinityrnaseq/trinityrnaseq/wiki/Trinity-Differential-Expression)


