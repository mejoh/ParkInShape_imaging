#!/bin/bash

# This script contains control analyses
# 1. AP vs PP pre intervention: Cortico-striatal remapping
# 2. Session A vs Session B for AP and PP: PD progression in cortico-striatal circuitry
# 3. Session A vs Session B for SMN: PD progression in SMN

#qsub -e /project/3011154.01/MJ/logs -o /project/3011154.01/MJ/logs -e /project/3011154.01/MJ/logs -N control -l 'walltime=10:00:00,mem=8gb' /project/3011154.01/MJ/scripts/stats/control_analyses.sh

export FSLDIR=/opt/fsl/5.0.11
.  ${FSLDIR}/etc/fslconf/fsl.sh

start=$(pwd)
working=/project/3011154.01/MJ/FC
cd ${working}

image=zstat
session=(A B)
roi_list=(2)
group=(exercise stretch)

merge=1
ap_vs_pp=0
PDprog_striatum=0
PDprog_smn=0

mkdir -p /project/3011154.01/MJ/FC/higher_level/control

#----------------------------------------------------------#

# Merge normalized statistical images for each seed. Split into separate groups. Merge the sessions of each group.

if [ ${merge} -eq 1 ]
then

for t in ${session[@]}; do

  for roi in ${roi_list[@]}; do
    ${FSLDIR}/bin/fslmerge \
	-t \
	$(pwd)/higher_level/control/${image}${t}${roi}_merged \
	$(pwd)/PS003${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS012${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS014${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS017${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS019${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS021${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS025${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS026${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS027${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS032${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS033${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS035${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS037${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS038${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS041${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS044${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS045${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS046${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS052${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS053${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS057${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS002${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS004${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS006${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS007${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS011${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS016${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS018${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS020${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS022${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS024${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS028${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS029${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS031${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS034${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS036${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS039${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS043${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS047${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS048${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS049${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS054${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS056${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS058${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS059${t}/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS060${t}/rs/stats/1st_level/${image}${roi}_std

	# Split the merged file above into Exercise and Stretching groups.
	mkdir -p $(pwd)/higher_level/control/exercise $(pwd)/higher_level/control/stretch	
	${FSLDIR}/bin/fslroi \
	$(pwd)/higher_level/control/${image}${t}${roi}_merged \
	$(pwd)/higher_level/control/exercise/${image}${t}${roi}_exercise \
	 0 21

	${FSLDIR}/bin/fslroi \
	$(pwd)/higher_level/control/${image}${t}${roi}_merged \
	$(pwd)/higher_level/control/stretch/${image}${t}${roi}_stretch \
	21 -1

  done
done

#for l in ${roi_list[@]}; do
#  for z in ${group[@]}; do
#  ${FSLDIR}/bin/fslmerge \
#	-t \
#	$(pwd)/higher_level/control/${z}/${image}${l}_${z} \
#	$(pwd)/higher_level/control/${z}/${image}A${l}_${z} \
#	$(pwd)/higher_level/control/${z}/${image}B${l}_${z}
#  done
#done

fi

#--------------------------------------------------------------------#

# One-sample t-test for investigating longitudinal change in cortico-striatal circuits at a whole-group level. We run the test on A1sub2 to get AP > PP and ANeg1sub2 to get PP > AP

if [ ${ap_vs_pp} -eq 1 ]
then

mkdir -p $(pwd)/higher_level/control/APvsPP

# Subtract PP from AP
${FSLDIR}/bin/fslmaths \
	$(pwd)/higher_level/control/${image}A1_merged \
	-sub \
	$(pwd)/higher_level/control/${image}A2_merged \
	$(pwd)/higher_level/control/${image}A1sub2_merged

# Multiply by -1 to reverse the contrast
${FSLDIR}/bin/fslmaths \
	$(pwd)/higher_level/control/${image}A1sub2_merged \
	-mul -1 \
	$(pwd)/higher_level/control/${image}A1sub2Neg_merged

input=(A1sub2 A1sub2Neg)

# One-sample t-test to see whether AP - PP (A1sub2) and PP - AP (A1sub2Neg) is significantly different from zero
for y in ${input[@]}; do
#  ${FSLDIR}/bin/randomise \
#	-i $(pwd)/higher_level/control/${image}${y}_merged \
#	-o $(pwd)/higher_level/control/APvsPP/${image}${y} \
#	-m /project/3011154.01/MJ/FC/designs/statistics/biIPC_mask \
#	-n 5000 \
#	-1 \
#	-R \
#	-T \
#	--uncorrp

  ${FSLDIR}/bin/randomise \
	-i $(pwd)/higher_level/control/${image}${y}_merged \
	-o $(pwd)/higher_level/control/APvsPP/${image}${y}_SMN \
	-m /project/3011154.01/MJ/FC/designs/statistics/smn_mask \
	-n 5000 \
	-1 \
	-R \
	-T \
	--uncorrp

done

# /project/3011154.01/MJ/FC/designs/statistics/biIPC_mask
# /project/3011154.01/MJ/FC/designs/statistics/smn_mask

fi

#--------------------------------------------------------------------#

# One-sample t-test for investigating longitudinal change related to PD progression at a whole-group level. We run the test on B - A to look for increases and A - B to look for decreases

if [ ${PDprog_striatum} -eq 1 ]
then

mkdir -p $(pwd)/higher_level/control/PDprog_striatum/biIPC $(pwd)/higher_level/control/PDprog_striatum/smn $(pwd)/higher_level/control/PDprog_striatum/whole_brain

for x in ${roi_list[@]}; do

  for v in ${group[@]}; do


  ${FSLDIR}/bin/fslmaths \
	$(pwd)/higher_level/control/${v}/${image}B${x}_${v} \
	-sub \
	$(pwd)/higher_level/control/${v}/${image}A${x}_${v} \
	$(pwd)/higher_level/control/${v}/${image}BsubA${x}_${v}

  ${FSLDIR}/bin/fslmaths \
	$(pwd)/higher_level/control/${v}/${image}BsubA${x}_${v} \
	-mul -1 \
	$(pwd)/higher_level/control/${v}/${image}BsubA${x}Neg_${v}

  input=(BsubA${x} BsubA${x}Neg)

# /project/3011154.01/MJ/FC/designs/statistics/biIPC_mask
mask=biIPC
# /project/3011154.01/MJ/FC/designs/statistics/smn_mask
#mask=smn
# /project/3011154.01/MJ/FC/higher_level/standard
#mask=whole_brain

    for u in ${input[@]}; do

    ${FSLDIR}/bin/randomise \
	-i $(pwd)/higher_level/control/${v}/${image}${u}_${v} \
	-o $(pwd)/higher_level/control/PDprog_striatum/${mask}/${image}${u}_${v} \
	-d $(pwd)/designs/statistics/3rd_level/PDprog/stretch/3rd_stretch.mat \
	-t $(pwd)/designs/statistics/3rd_level/PDprog/stretch/3rd_stretch.con \
	-m /project/3011154.01/MJ/FC/designs/statistics/biIPC_mask \
	-n 5000 \
	-R \
	-T \
	--uncorrp

  done

done

done

fi

#--------------------------------------------------------------------#

# One-sample paired t-test for investigating longitudinal change in SMN at a whole-group level

if [ ${PDprog_smn} -eq 1 ]
then

mkdir -p $(pwd)/higher_level/control/PDprog_smn

smn_list=(0010 0012 0013 0014)
contrasts=(BsubA BsubANeg)

for w in ${smn_list[@]}; do

  ${FSLDIR}/bin/fslmaths \
	$(pwd)/higher_level/groupICA/2nd_level/BsubA_ic${w} \
	-mul -1 \
	$(pwd)/higher_level/groupICA/2nd_level/BsubANeg_ic${w}

  for v in ${contrasts[@]}; do

  ${FSLDIR}/bin/randomise \
	-i $(pwd)/higher_level/groupICA/2nd_level/${v}_ic${w} \
	-o $(pwd)/higher_level/control/PDprog_smn/${v}_ic${w} \
	-m $(pwd)/higher_level/mask_final \
	-n 5000 \
	-1 \
	-R \
	-T \
	--uncorrp

# /project/3011154.01/MJ/FC/designs/statistics/biIPC_mask
# /project/3011154.01/MJ/FC/higher_level/mask_final
# /project/3011154.01/MJ/FC/designs/statistics/smn_mask

  done

done

fi
