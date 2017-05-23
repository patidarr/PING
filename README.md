PING (Pushing Immunogenomics to the Next Generation)

Please see the included manual for an in depth overview of how these scripts are used and what they require.

YouTube tutorial on installing PING dependencies:
https://www.youtube.com/watch?v=YsX6gtJBkp8

How to run:

`module load R`  
`module load bowtie2`  
`./PING_run_all.R --threads=10 --location="Sample_XXXXX/" --R1="_R1.fastq.gz" --R2="_R2.fastq.gz" --out=/projects/scratch/PING3/`  
For any questions or bug reports, please email me at Wesley.Marin@ucsf.edu.
