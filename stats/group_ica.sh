#!/bin/bash

##QSUB
#qsub -o /project/3011154.01/MJ/logs -e /project/3011154.01/MJ/logs -N group_melodic -l 'walltime=40:00:00,mem=15gb' ~/scripts/ParkInShape/stats/group_ica.sh 

export FSLDIR=/opt/fsl/6.0.3
.  ${FSLDIR}/etc/fslconf/fsl.sh

junk=/project/3011154.01/MJ/junk
working=/project/3011154.01/MJ/FC

cd ${working}

nl_registration=0
run_melodic=0
run_dual_regression=0
subtract=0
third_level_ica=1
post_hoc=0
copy_data_to_results=0

#----------------------------------------------------------#

list_subjects=(PS002A PS002B PS003A PS003B PS004A PS004B PS006A PS006B PS007A PS007B PS011A PS011B PS012A PS012B PS014A PS014B PS016A PS016B PS017A PS017B PS018A PS018B PS019A PS019B PS020A PS020B PS021A PS021B PS022A PS022B PS024A PS024B PS025A PS025B PS026A PS026B PS027A PS027B PS028A PS028B PS029A PS029B PS031A PS031B PS032A PS032B PS033A PS033B PS034A PS034B PS035A PS035B PS036A PS036B PS037A PS037B PS038A PS038B PS039A PS039B PS041A PS041B PS043A PS043B PS044A PS044B PS045A PS045B PS046A PS046B PS047A PS047B PS048A PS048B PS049A PS049B PS052A PS052B PS053A PS053B PS054A PS054B PS056A PS056B PS057A PS057B PS058A PS058B PS059A PS059B PS060A PS060B)

# Non-linearly register functional data to standard space (90min for 55 ps. With 1mm normalization a lot of memory is required, like 15gb. 1mm normalized images also take a huuuge amount of space)

if [ ${nl_registration} -eq 1 ]
then

for i in ${list_subjects[@]}; do
${FSLDIR}/bin/applywarp \
 	-i $(pwd)/${i}/rs/prepro.feat/${i}_nuireg_hp_addsmth \
 	-o /project/3024006.02/Users/marjoh/intermediate/groupICA/${i}_nuireg_hp_std \
	-r /project/3024006.02/Users/marjoh/intermediate/${i}.feat/reg/standard \
 	-w /project/3024006.02/Users/marjoh/intermediate/${i}.feat/reg/example_func2standard_warp
done

fi

#----------------------------------------------------------#

# Print the normalized images to a list for input into melodic
#cd higher_level/groupICA
cd /project/3024006.02/Users/marjoh/intermediate/groupICA
ls -1 PS*_std.nii.gz > input_list.txt

#----------------------------------------------------------#

# ICA on temporally concatenated functional data (19.5h for 55 ps at d 20)

if [ ${run_melodic} -eq 1 ]
then

${FSLDIR}/bin/melodic -i $(pwd)/input_list.txt \
 	-o $(pwd)/group \
 	--tr=1.1 --nobet -a concat \
 	-m /project/3011154.01/MJ/anatomical_std_template/template_avg_anat_asym_brain.nii.gz  \
 	--report --Oall -d 20

# Split the ICA output into single volumes, each volume corresponding to a comp
#${FSLDIR}/bin/fslsplit $(pwd)/group/melodic_IC $(pwd)/group/comp -t

fi

#----------------------------------------------------------#

# Run dual reg on all components to get subject-specific spatial maps (stage2)
# Recommended that you don't split them (think multiple regression)
# We're not interested in stage3 output now, just stage2, so we set permutations to 0

if [ ${run_dual_regression} -eq 1 ]
then

# First create a new input_list.txt
# This new list is ordered according to group, which is what we need for performing the third-level analysis
new_list_subjects=(PS003 PS012 PS014 PS017 PS019 PS021 PS025 PS026 PS027 PS032 PS033 PS035 PS037 PS038 PS041 PS044 PS045 PS046 PS052 PS053 PS057 PS002 PS004 PS006 PS007 PS011 PS016 PS018 PS020 PS022 PS024 PS028 PS029 PS031 PS034 PS036 PS039 PS043 PS047 PS048 PS049 PS054 PS056 PS058 PS059 PS060)
# Write one textfile each for the A and B sessions, but delete old ones first, then run randomise on each.
rm A_sessions.txt B_sessions.txt
mkdir -p $(pwd)/dual_reg/A $(pwd)/dual_reg/B
session=(A B)
for b in ${session[@]}; do
  for i in ${new_list_subjects[@]}; do
    grep ${i}${b}_nuireg_hp_std input_list.txt >> ${b}_sessions.txt
  done

  ${FSLDIR}/bin/dual_regression group/melodic_IC \
 	1 \
 	-1 \
 	0 \
 	$(pwd)/dual_reg/${b} \
 	`cat ${b}_sessions.txt`

done

fi

#----------------------------------------------------------#

# Subtract A from B. Do this for all components

mkdir -p $(pwd)/2nd_level

if [ ${subtract} -eq 1 ]
then

component=(0000 0001 0002 0003 0004 0005 0006 0007 0008 0009 0010 0011 0012 0013 0014 0015 0016 0017 0018 0019)

for y in ${component[@]}; do

  ${FSLDIR}/bin/fslmaths \
	$(pwd)/dual_reg/B/dr_stage2_ic${y} \
	-sub \
	$(pwd)/dual_reg/A/dr_stage2_ic${y} \
	$(pwd)/2nd_level/BsubA_ic${y}
 # ${FSLDIR}/bin/fslmaths \
#	$(pwd)/dual_reg/B/merged_Z/dr_stage2_ic${y}_Z \
#	-sub \
#	$(pwd)/dual_reg/A/merged_Z/dr_stage2_ic${y}_Z \
#	$(pwd)/2nd_level/BsubA_ic${y}_Z

  ${FSLDIR}/bin/fslroi $(pwd)/2nd_level/BsubA_ic${y}_Z $(pwd)/2nd_level/BsubA_ic${y}_exercise 0 21
  ${FSLDIR}/bin/fslroi $(pwd)/2nd_level/BsubA_ic${y}_Z $(pwd)/2nd_level/BsubA_ic${y}_stretch 21 -1

done

fi

#----------------------------------------------------------#

# THIRD LEVEL: ICA

# IF you do multiple components, and run contrasts both ways, then you have to correct p values
# 0.05 / (Nr_of_comps * 2)
# 0.05 / (5 * 2) = 0.005	1-0.005 = 0.995

mkdir -p $(pwd)/3rd_level/masks

if [ ${third_level_ica} -eq 1 ]
then

for z in {1..20}; do
	zstat_img=$(pwd)/group/stats/thresh_zstat${z}.nii.gz
	ic=`expr ${z} - 1`
	output_mask=$(pwd)/3rd_level/masks/ic_${ic}
	${FSLDIR}/bin/fslmaths $zstat_img -thr 3.1 -bin $output_mask
done

#1	DMN
#2	Visual
#3	Visual
#4	Parietal-SMA
#5	DMN
#6**	RFPN
#7**	LFPN
#8*	Parietal-Precuneus-Premotor
#9*	Parietal-Precuneus-PCC
#10*	Prefrontal-Thalamus-Caudate
#11*	Lateral M1
#12*	MPFC-ACC-Caudate-Thalamus
#13**	Premotor-ACC-Caudate-Thalamus (exec)
#14*	M1-S1-SPL
#15**	SMN
#16	Auditory
#17	Visual
#18	Parietal-Premotor (noisy)
#19	Cerebellum
#20	Parietal-Frontal-Visual
#comp_list=(0000 0001 0002 0003 0004 0005 0006 0007 0008 0009 0010 0011 0012 0013 0014 0015 0016 0017 0018 0019)
motor_comp_list=(0014 0013 0010)			# Motor comps
exec_comp_list=(0005 0006 0012 0011 0009)		# Executive function comps
rfpn_comp_list=(0005)					# Only rfpn
parietal_comp_list=(0003 0007 0008 0019)		# Remaining parietal comps

for e in ${rfpn_comp_list[@]}; do

	baseline=$(pwd)/dual_reg/A/dr_stage2_ic${e}
	followup=$(pwd)/dual_reg/B/dr_stage2_ic${e}
	BsubA=$(pwd)/2nd_level/BsubA_ic${e}
	icnr=${e##+(0)}
	icnr=$(echo $e | sed 's/^0*//')

	${FSLDIR}/bin/randomise \
		-i $BsubA \
		-o $(pwd)/3rd_level/all_exec_nets/exec_BsubA_ic${e}_up3ba-only \
		-d /project/3011154.01/MJ/FC/designs/statistics/3rd_level/3rd_level_cov_up3ba_yoe.mat \
		-t /project/3011154.01/MJ/FC/designs/statistics/3rd_level/3rd_level_cov_up3ba_yoe.con \
		-f /project/3011154.01/MJ/FC/designs/statistics/3rd_level/3rd_level_cov_up3ba_yoe.fts \
		-m $(pwd)/3rd_level/masks/ic_${icnr} \
		-n 5000 \
		-T \
		-R \
		--uncorrp
# 	${FSLDIR}/bin/randomise \
#		-i $baseline \
#		-o $(pwd)/3rd_level/exec_A_ic${e}_up3ba-only \
#		-d /project/3011154.01/MJ/FC/designs/statistics/3rd_level/3rd_level_cov_up3ba-only.mat \
#		-t /project/3011154.01/MJ/FC/designs/statistics/3rd_level/3rd_level_cov_up3ba-only.con \
#		-f /project/3011154.01/MJ/FC/designs/statistics/3rd_level/3rd_level_cov_up3ba-only.fts \
#		-m $(pwd)/3rd_level/masks/ic_${icnr} \
#		-n 5000 \
#		-T \
#		-R \
#		--uncorrp
# 	${FSLDIR}/bin/randomise \
#		-i $followup \
#		-o $(pwd)/3rd_level/exec_B_ic${e}_up3ba-only \
#		-d /project/3011154.01/MJ/FC/designs/statistics/3rd_level/3rd_level_cov_up3ba-only.mat \
#		-t /project/3011154.01/MJ/FC/designs/statistics/3rd_level/3rd_level_cov_up3ba-only.con \
#		-f /project/3011154.01/MJ/FC/designs/statistics/3rd_level/3rd_level_cov_up3ba-only.fts \
#		-m $(pwd)/3rd_level/masks/ic_${icnr} \
#		-n 5000 \
#		-T \
#		-R \
#		--uncorrp

#/project/3011154.01/MJ/FC/higher_level/groupICA/group/masks/ic${e}

done

fi

#----------------------------------------------------------#

if [ ${post_hoc} -eq 1 ]
then

mkdir -p $(pwd)/results/ic0006/posthoc

group=(exercise stretch)

for w in ${group[@]}; do

  ${FSLDIR}/bin/fslmaths \
	$(pwd)/results/ic0006/data/${w}/ic0006_BsubA${w} \
	-mul -1 \
	$(pwd)/results/ic0006/data/${w}/ic0006_BsubANeg${w}

contrasts=(BsubA BsubANeg)

  for v in ${contrasts[@]}; do

  ${FSLDIR}/bin/randomise \
	-i $(pwd)/results/ic0006/data/${w}/ic0006_${v}${w} \
	-o $(pwd)/results/ic0006/posthoc/${v}${w} \
	-d ${working}/designs/statistics/3rd_level/PDprog/${w}/3rd_${w}.mat \
	-t ${working}/designs/statistics/3rd_level/PDprog/${w}/3rd_${w}.con \
	-m /project/3011154.01/MJ/FC/higher_level/groupICA/group/masks/ic0006.nii.gz \
	-n 5000 \
	-R \
	-T \
	--uncorrp

#/project/3011154.01/MJ/FC/higher_level/standard

  done

done

fi

if [ $copy_data_to_results -eq 1 ]; then

	ic_nr=5

	cp dual_reg/A/dr_stage2_ic000${ic_nr}.nii.gz 3rd_level/results/ic${ic_nr}/data/ic${ic_nr}_A_merged.nii.gz
	${FSLDIR}/bin/fslroi \
		3rd_level/results/ic${ic_nr}/data/ic${ic_nr}_A_merged.nii.gz \
		3rd_level/results/ic${ic_nr}/data/exercise/ic${ic_nr}_A \
		0 21
	${FSLDIR}/bin/fslroi \
		3rd_level/results/ic${ic_nr}/data/ic${ic_nr}_A_merged.nii.gz \
		3rd_level/results/ic${ic_nr}/data/stretch/ic${ic_nr}_A \
		21 -1

	cp dual_reg/B/dr_stage2_ic000${ic_nr}.nii.gz 3rd_level/results/ic${ic_nr}/data/ic${ic_nr}_B_merged.nii.gz
	${FSLDIR}/bin/fslroi \
		3rd_level/results/ic${ic_nr}/data/ic${ic_nr}_B_merged.nii.gz \
		3rd_level/results/ic${ic_nr}/data/exercise/ic${ic_nr}_B \
		0 21
	${FSLDIR}/bin/fslroi \
		3rd_level/results/ic${ic_nr}/data/ic${ic_nr}_B_merged.nii.gz \
		3rd_level/results/ic${ic_nr}/data/stretch/ic${ic_nr}_B \
		21 -1

	${FSLDIR}/bin/fslmaths \
		3rd_level/results/ic${ic_nr}/data/ic${ic_nr}_B_merged.nii.gz \
		-sub \
		3rd_level/results/ic${ic_nr}/data/ic${ic_nr}_A_merged.nii.gz 3rd_level/results/ic${ic_nr}/data/ic${ic_nr}_BsubA_merged.nii.gz
	${FSLDIR}/bin/fslroi \
		3rd_level/results/ic${ic_nr}/data/ic${ic_nr}_BsubA_merged.nii.gz \
		3rd_level/results/ic${ic_nr}/data/exercise/ic${ic_nr}_BsubA \
		0 21
	${FSLDIR}/bin/fslroi \
		3rd_level/results/ic${ic_nr}/data/ic${ic_nr}_BsubA_merged.nii.gz \
		3rd_level/results/ic${ic_nr}/data/stretch/ic${ic_nr}_BsubA \
		21 -1

fi

