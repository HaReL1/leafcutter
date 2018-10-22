#!/bin/bash

# Manually working through the differential splicing pipeline. 

# wget bam files (4Gb!)
wget https://www.dropbox.com/s/8mxmkoa09p24k1g/example_geuvadis.tar.gz?dl=0 -O example_geuvadis.tar.gz
tar -xvf example_geuvadis.tar.gz

# Convert bam to junction files
if [ -e test_juncfiles.txt ]; then rm test_juncfiles.txt; fi

for bamfile in `ls example_geuvadis/*chr1.bam`; do
    echo Converting $bamfile to $bamfile.junc
    sh ../scripts/bam2junc.sh $bamfile $bamfile.junc
    echo $bamfile.junc >> test_juncfiles.txt
done

# Finds intron clusters and quantifies junction usage within them. 
python ../clustering/leafcutter_cluster.py -j test_juncfiles.txt -m 50 -o testYRIvsEU -l 500000

# Differential splicing analysis. 
../scripts/leafcutter_ds.R --num_threads 4 ../example_data/testYRIvsEU_perind_numers.counts.gz example_geuvadis/groups_file.txt

# Plot differentially spliced clusters.
../scripts/ds_plots.R -e ../leafcutter/data/gencode19_exons.txt.gz ../example_data/testYRIvsEU_perind_numers.counts.gz example_geuvadis/groups_file.txt leafcutter_ds_cluster_significance.txt -f 0.05