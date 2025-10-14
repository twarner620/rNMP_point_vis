#!usr/bin/env bash

bin=100 #bin size to be used
hggenome='/storage/home/hcoda1/5/dkundnani3/p-fstorici3-0/rich_project_bio-storici/reference/hg38/filtered_hg38-nucleus-noXY.fa.fai' #genome size file
bw='/storage/coda1/p-fstorici3/0/shared/WGBS_dist/bw' #location of bigwig files to be used, make sure they have _pos.bw and _neg.bw as extensions
files='/storage/coda1/p-fstorici3/0/shared/WGBS_dist/files' #Same file provided
ref='/storage/home/hcoda1/5/dkundnani3/p-fstorici3-0/rich_project_bio-storici/reference/hg38/ranges/distribution_ranges/center_run/hg38_cpg_islands_3kb_TSSonly_nooverlap.bed' #Reference bed file with chr,start,stop
bref=$(basename $ref); base="${bref%.*}" #defining base from reference file for naming output files
grouplist='WT KO-T3-8' #List of celllines to be visualized, matches the identifiers in files
out='/storage/coda1/p-fstorici3/0/shared/WGBS_dist/meth_dist' #Output directory
scripts='/storage/home/hcoda1/5/dkundnani3/p-fstorici3-0/rich_project_bio-storici/bin/GIT/rNMP_point_vis/rNMP_point_vis' #your github folder

#first step to activet enviroment with Deeptools and python
conda activate conda-env
mkdir -p $out
cd $bw

################### DONOT EDIT beyond this point #########################################3

#Defining function using Deeptools to get distribution data on center of a range, e.g. CpG ranges, replication origins etc.
function deeptoolscen {
file=$(grep $group $files | cut -f1 | tr '\n' ' ')
color=$(grep $group $files | cut -f3 | uniq | tr '\n' ' ')
computeMatrix reference-point -R $ref -a 3000 -b 3000 -S $file --referencePoint center -o $out/${base}_${group}_cen.gz --outFileSortedRegions $out/${base}_${group}_cen.bed --numberOfProcessors max -bs $bin 
plotProfile -m  $out/${base}_${group}_cen.gz -out $out/${base}_${group}_cen.png --outFileNameData $out/${base}_${group}_cen.tab --numPlotsPerRow 1 --perGroup --yMin -0  --yMax 100 --legendLocation upper-right --endLabel center  --yAxisLabel "Methylation" 
python $scripts/ind_celltype_vis.py $out/${base}_${group}_cen.tab 100 '3.0Kb' cntr $color nolegend nosep nopub
}

#running the function in parallel for all celltypes
cd $bw
for group in $grouplist; do
deeptoolscen &
done
#Also visualizing using python script for individual celltypes and all celltypes together

cd $out
cp $base*tab tab/
python $scripts/all_celltypes_vis.py "$(echo "tab/$base"'*tab')" 100 '3.0Kb' cntr '#E377C2,#D62728' nolegend nosep nopub & #The colors are defined based on alphabetical order of sample names (KO will be before WT), check 'files for respective color code'



 


