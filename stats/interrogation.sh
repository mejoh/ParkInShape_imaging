#!/bin/bash

# Generate stats and such

#qsub -e /project/3011154.01/MJ/logs -o /project/3011154.01/MJ/logs -N interrogation -l 'walltime=00:10:00,mem=2gb' ~/scripts/stats/interrogation.sh

export FSLDIR=/opt/fsl/5.0.11
.  ${FSLDIR}/etc/fslconf/fsl.sh

start=$(pwd)
junk=/project/3011154.01/MJ/junk
working=/project/3011154.01/MJ/FC

query=0
split=0
clust=1
local_max=0

cd ${working}

# Define which a list of participants and the statistical images you want to report on
# Note that this list will determine the shape of the final compiled reports
list_subjects=()

#---------------------------------------------------------#
if [ ${query} -eq -1 ]
then

stat_images=(zstat1 zstat2)
# Remove older compiled report
rm $(pwd)/higher_level/results/stats/${stat_images[0]}.txt
rm $(pwd)/higher_level/results/stats/${stat_images[1]}.txt
# Run featquery for each element in the list of subjects
for s in ${list_subjects[@]}; do
	# Remove any prior featquery directory
if [ -d $(pwd)/${s}/rs/stats/1st_level/1st_level.feat/featquery ]
then
rm -r $(pwd)/${s}/rs/stats/1st_level/1st_level.feat/featquery
fi
	# Produce reports of test stat values
  ${FSLDIR}/bin/featquery \
	1 \
	$(pwd)/${s}/rs/stats/1st_level/1st_level.feat \
	2 \
	$(pwd)/${s}/rs/stats/1st_level/1st_level.feat/stats/${stat_images[0]} \
	$(pwd)/${s}/rs/stats/1st_level/1st_level.feat/stats/${stat_images[1]} \
	featquery \
	-s \
	$(pwd)/designs/statistics/biIPC_mask
	# Print the report as one row for each participant. These can be imported into excel and delimited with space
  for i in ${stat_images[@]}; do
    grep ${i} $(pwd)/${s}/rs/stats/1st_level/1st_level.feat/featquery/report.txt >> $(pwd)/higher_level/results/stats/${i}.txt
  done
done
# Split the text files according to group. 1-21=Group A Pre, 22-46=Group B Pre, 47-67=Group A Post, 68-92=Group B Post


# Format from FEAT documentation: cat report.txt | grep stats/pe1 | awk '{print $1 " " $7}
# This line of code prints the first and seventh element, if you think of the report as a matrix. The seventh element here corresponds to the median


fi

#--------------------------------------------------------------------#

# Split stuff
# Take concatenated dual_reg file and splits it into groups. Output is placed in results-folder. 

if [ ${split} -eq 1 ]
then

# Define comp of interest
comp=ic0006
ses=(A B)

mkdir -p $(pwd)/higher_level/groupICA/results/${comp}/data/exercise $(pwd)/higher_level/groupICA/results/${comp}/data/stretch

# Split files
for r in ${ses[@]}; do

  ${FSLDIR}/bin/fslroi $(pwd)/higher_level/groupICA/dual_reg/${r}/dr_stage2_${comp}.nii.gz $(pwd)/higher_level/groupICA/results/${comp}/data/exercise/${comp}_${r}exercise 0 21

  ${FSLDIR}/bin/fslroi $(pwd)/higher_level/groupICA/dual_reg/${r}/dr_stage2_${comp}.nii.gz $(pwd)/higher_level/groupICA/results/${comp}/data/stretch/${comp}_${r}stretch 21 25

done

# Take difference between sessions
${FSLDIR}/bin/fslmaths $(pwd)/higher_level/groupICA/results/${comp}/data/exercise/${comp}_Bexercise -sub $(pwd)/higher_level/groupICA/results/${comp}/data/exercise/${comp}_Aexercise $(pwd)/higher_level/groupICA/results/${comp}/data/exercise/${comp}_BsubAexercise

${FSLDIR}/bin/fslmaths $(pwd)/higher_level/groupICA/results/${comp}/data/stretch/${comp}_Bstretch -sub $(pwd)/higher_level/groupICA/results/${comp}/data/stretch/${comp}_Astretch $(pwd)/higher_level/groupICA/results/${comp}/data/stretch/${comp}_BsubAstretch

fi

#--------------------------------------------------------------------#

# Extract data for plotting and for correlations

if [ ${clust} -eq 1 ]
then

# Define the images you want to interrogate
# The following 4 variables must be set manually
#seed=4
#roi=new_ex
# image_path=$(pwd)/higher_level/groupICA/results/${seed}/posthoc/BsubAexercise
image_path=/project/3011154.01/MJ/FC/higher_level/3rd_level/randomise/sensitivity_perprotocol_2-7-2021/FC/SMN/followup/results/PP/
p_image=/project/3011154.01/MJ/FC/higher_level/3rd_level/randomise/sensitivity_perprotocol_2-7-2021/FC/SMN/followup/results/PP/2_up3ba-only_tfce_corrp_tstat2.nii.gz
t_image=/project/3011154.01/MJ/FC/higher_level/3rd_level/randomise/sensitivity_perprotocol_2-7-2021/FC/SMN/followup/results/PP/2_up3ba-only_tfce_tstat2.nii.gz

# Create a mask from thresholded p-image
mask=${image_path}/mask
${FSLDIR}/bin/fslmaths \
	${p_image} \
	-thr 0.95 \
	-bin \
	${mask}

# Mask the t-stat image. This is what you present
t_mask=${image_path}/t
${FSLDIR}/bin/fslmaths \
	${t_image} \
	-mas ${mask} \
	${t_mask}

# Define cluster mask
cluster_stats=${image_path}/cluster.txt
${FSLDIR}/bin/cluster \
	-i ${p_image} \
	-t 0.95 \
	-o ${image_path}/cluster_index \
	> ${cluster_stats}
cluster_index=${image_path}/cluster_index

# Write list of subjects, ordered according to intervention. Same as stats
exercise_sub_list=(PS003 PS012 PS014 PS017 PS019 PS021 PS025 PS026 PS027 PS032 PS033 PS035 PS037 PS038 PS041 PS044 PS045 PS046 PS052 PS053 PS057)
stretching_sub_list=(PS002 PS004 PS006 PS007 PS011 PS016 PS018 PS020 PS022 PS024 PS028 PS029 PS031 PS034 PS036 PS039 PS043 PS047 PS048 PS049 PS054 PS056 PS058 PS059 PS060)
all_sub_list=(${exercise_sub_list[@]} ${stretching_sub_list[@]})
sublist=${image_path}/subjects.txt

rm $sublist
touch $sublist
for n in ${all_sub_list[@]}; do
echo $n >> $sublist
done

# Set group and session to what you need to interrogate
# Extract stats for plotting and doing correlations

group=(exercise stretch)
ses=(B)
for t in ${group[@]}; do
  for i in ${ses[@]}; do
#data=/project/3011154.01/MJ/FC/higher_level/3rd_level/2_${i}_${t}_merged.nii.gz
#data=/project/3024006.02/Users/marjoh/intermediate/groupICA/2nd_level/BsubA_ic0005_${t}.nii.gz
data=/project/3011154.01/MJ/FC/higher_level/3rd_level/randomise/sensitivity_perprotocol_2-7-2021/data/2_${i}_merged.nii.gz
#data=/project/3024006.02/Users/marjoh/intermediate/groupICA/dual_reg/${i}/dr_stage2_ic0005_${t}.nii.gz
stats=${image_path}/${i}_${t}.txt
stats2=${image_path}/${i}_${t}_temp.txt
stats3=${image_path}/${i}_${t}_temp_r.txt

  ${FSLDIR}/bin/fslstats \
	-K ${cluster_index} \
	${data} \
	-M -S > ${stats}

  ${FSLDIR}/bin/fslstats \
	-t \
	-K ${cluster_index} \
	${data} \
	-M > ${stats2}

awk '
{ 
    for (i=1; i<=NF; i++)  {
        a[NR,i] = $i
    }
}
NF>p { p = NF }
END {    
    for(j=1; j<=p; j++) {
        str=a[1,j]
        for(i=2; i<=NR; i++){
            str=str" "a[i,j];
        }
        print str
    }
}' ${stats2} | tr -s '[:blank:]' ',' > ${stats3}

  done
done

nclust=`${FSLDIR}/bin/fslstats $cluster_index -R | cut -c 10-`
nclust=`seq $nclust`
echo "Number of clusters: ${nclust[@]}"
clustdir=`dirname $cluster_index`
for n in ${nclust[@]}; do

	${FSLDIR}/bin/fslmaths $cluster_index -thr $n -uthr $n -bin $clustdir/cluster_${n}.nii.gz
	touch $clustdir/cluster_${n}.txt
	${FSLDIR}/bin/atlasquery -a 'Juelich Histological Atlas' -m $clustdir/cluster_${n}.nii.gz >> $clustdir/cluster_${n}.txt

# For motor: 'Juelich Histological Atlas'
# For frontal: 'Sallet Dorsal Frontal connectivity-based parcellation'

done

fi

#---------------------------------------------------------#

# Print the local max of each significant cluster

comp=ic0006

if [ ${local_max} -eq 1 ]
then

mask=$(pwd)/higher_level/groupICA/results/${comp}/cluster_index.nii.gz
t_image=$(pwd)/higher_level/groupICA/results/${comp}/t.nii.gz
output=$(pwd)/higher_level/groupICA/results/${comp}/local_max_t.txt

${FSLDIR}/bin/fslstats \
	-K \
	${mask} \
	${t_image} \
	-x > ${output}

fi

#---------------------------------------------------------#

# Get location of cluster(s). Run this manually, just copy paste and write down what comes up in the terminal.

#fslmaths cluster_index -thr X -uthr X clusterX
#atlasquery -a 'Juelich Histological Atlas' -m clusterX
#atlasquery -a 'Harvard-Oxford Cortical Structural Atlas' -m clusterX





