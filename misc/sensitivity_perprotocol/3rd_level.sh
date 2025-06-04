#!/bin/bash

# Compare change over time between intervention groups (Intervention x Session)

##QSUB
#roi_list=(APsubPP 1 2); for s in ${roi_list[@]}; do qsub -e /project/3011154.01/MJ/logs -o /project/3011154.01/MJ/logs -N randomise_${s} -v roi=${s} -l 'walltime=20:00:00,mem=8gb' ~/scripts/ParkInShape/stats/sensitivity_perprotocol/3rd_level.sh; done

export FSLDIR=/opt/fsl/6.0.3
.  ${FSLDIR}/etc/fslconf/fsl.sh

start=${pwd}
junk=/project/3011154.01/MJ/junk
working=/project/3011154.01/MJ/FC
cd ${working}

flip=0
merge=0
third_level=1
post_hoc=0
baseline=0

mkdir -p $(pwd)/higher_level/3rd_level/randomise

# Specify whether you want 'cope' or 'zstat'
image=zstat

#----------------------------------------------------------#

# Flip stat images

if [ $flip -eq 1 ]; then

subjects=(PS003 PS012 PS014 PS017 PS019 PS021 PS025 PS026 PS027 PS033 PS035 PS038 PS041 PS044 PS046 PS052 PS053 PS002 PS004 PS006 PS011 PS016 PS018 PS020 PS024 PS028 PS029 PS031 PS034 PS036 PS039 PS043 PS047 PS048 PS049 PS054 PS056 PS059 PS060)
MAS=(2 2 2 1 1 2 2 2 2 2 1 1 2 1 2 1 2 1 2 2 1 2 1 1 1 2 2 2 2 1 1 2 2 1 1 1 1 2 1)

for n in ${!subjects[@]}; do

	if [ ${MAS[n]} -eq 2 ]; then

		s=${subjects[n]}
		m=${MAS[n]}
		echo "Left-to-right flipping ${s}, MAS=Left"

		input=$(pwd)/higher_level/2nd_level/${s}/${image}${roi}_std_A
		output=/project/3011154.01/MJ/FC/higher_level/3rd_level/randomise/sensitivity_perprotocol_9-6-2021/data/${image}${roi}_std_A_LtoR
		${FSLDIR}/bin/fslswapdim $input -x y z $output

		input=$(pwd)/higher_level/2nd_level/${s}/${image}${roi}_std_B
		output=/project/3011154.01/MJ/FC/higher_level/3rd_level/randomise/sensitivity_perprotocol_9-6-2021/data//${image}${roi}_std_B_LtoR
		${FSLDIR}/bin/fslswapdim $input -x y z $output

		input=$(pwd)/higher_level/2nd_level/${s}/${image}${roi}_std_BsubA
		output=/project/3011154.01/MJ/FC/higher_level/3rd_level/randomise/sensitivity_perprotocol_9-6-2021/data//${image}${roi}_std_BsubA_LtoR
		${FSLDIR}/bin/fslswapdim $input -x y z $output

	fi

done

${FSLDIR}/bin/fslmerge \
	-t \
	/project/3011154.01/MJ/FC/higher_level/3rd_level/randomise/sensitivity_perprotocol_2-7-2021/data/${roi}_BsubA_flipped_merged \
	$(pwd)/higher_level/2nd_level/PS003/${image}${roi}_std_BsubA_LtoR \
	$(pwd)/higher_level/2nd_level/PS012/${image}${roi}_std_BsubA_LtoR \
	$(pwd)/higher_level/2nd_level/PS014/${image}${roi}_std_BsubA_LtoR \
	$(pwd)/higher_level/2nd_level/PS017/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS019/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS021/${image}${roi}_std_BsubA_LtoR \
	$(pwd)/higher_level/2nd_level/PS025/${image}${roi}_std_BsubA_LtoR \
	$(pwd)/higher_level/2nd_level/PS026/${image}${roi}_std_BsubA_LtoR \
	$(pwd)/higher_level/2nd_level/PS027/${image}${roi}_std_BsubA_LtoR \
	$(pwd)/higher_level/2nd_level/PS033/${image}${roi}_std_BsubA_LtoR \
	$(pwd)/higher_level/2nd_level/PS035/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS038/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS041/${image}${roi}_std_BsubA_LtoR \
	$(pwd)/higher_level/2nd_level/PS044/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS046/${image}${roi}_std_BsubA_LtoR \
	$(pwd)/higher_level/2nd_level/PS052/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS053/${image}${roi}_std_BsubA_LtoR \
	$(pwd)/higher_level/2nd_level/PS002/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS004/${image}${roi}_std_BsubA_LtoR \
	$(pwd)/higher_level/2nd_level/PS006/${image}${roi}_std_BsubA_LtoR \
	$(pwd)/higher_level/2nd_level/PS011/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS016/${image}${roi}_std_BsubA_LtoR \
	$(pwd)/higher_level/2nd_level/PS018/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS020/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS024/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS028/${image}${roi}_std_BsubA_LtoR \
	$(pwd)/higher_level/2nd_level/PS029/${image}${roi}_std_BsubA_LtoR \
	$(pwd)/higher_level/2nd_level/PS031/${image}${roi}_std_BsubA_LtoR \
	$(pwd)/higher_level/2nd_level/PS034/${image}${roi}_std_BsubA_LtoR \
	$(pwd)/higher_level/2nd_level/PS036/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS039/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS043/${image}${roi}_std_BsubA_LtoR \
	$(pwd)/higher_level/2nd_level/PS047/${image}${roi}_std_BsubA_LtoR \
	$(pwd)/higher_level/2nd_level/PS048/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS049/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS054/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS056/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS059/${image}${roi}_std_BsubA_LtoR \
	$(pwd)/higher_level/2nd_level/PS060/${image}${roi}_std_BsubA

fi

#----------------------------------------------------------#
# Merge stuff

# Merge zstat difference maps of all subjects for each seed region
# This merges patients in group A followed by patients in group B. Patients are ordered within each group

if [ ${merge} -eq 1 ]
then

${FSLDIR}/bin/fslmerge \
	-t \
	/project/3011154.01/MJ/FC/higher_level/3rd_level/randomise/sensitivity_perprotocol_2-7-2021/data/${roi}_BsubA_merged \
	$(pwd)/higher_level/2nd_level/PS003/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS012/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS014/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS017/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS019/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS021/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS025/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS026/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS027/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS033/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS035/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS038/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS041/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS044/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS046/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS052/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS053/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS002/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS004/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS006/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS011/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS016/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS018/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS020/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS024/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS028/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS029/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS031/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS034/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS036/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS039/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS043/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS047/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS048/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS049/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS054/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS056/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS059/${image}${roi}_std_BsubA \
	$(pwd)/higher_level/2nd_level/PS060/${image}${roi}_std_BsubA

# Merge A
${FSLDIR}/bin/fslmerge \
	-t \
	/project/3011154.01/MJ/FC/higher_level/3rd_level/randomise/sensitivity_perprotocol_2-7-2021/data/${roi}_A_merged \
	$(pwd)/higher_level/2nd_level/PS003/${image}${roi}_std_A \
	$(pwd)/higher_level/2nd_level/PS012/${image}${roi}_std_A \
	$(pwd)/higher_level/2nd_level/PS014/${image}${roi}_std_A \
	$(pwd)/higher_level/2nd_level/PS017/${image}${roi}_std_A \
	$(pwd)/higher_level/2nd_level/PS019/${image}${roi}_std_A \
	$(pwd)/higher_level/2nd_level/PS021/${image}${roi}_std_A \
	$(pwd)/higher_level/2nd_level/PS025/${image}${roi}_std_A \
	$(pwd)/higher_level/2nd_level/PS026/${image}${roi}_std_A \
	$(pwd)/higher_level/2nd_level/PS027/${image}${roi}_std_A \
	$(pwd)/higher_level/2nd_level/PS033/${image}${roi}_std_A \
	$(pwd)/higher_level/2nd_level/PS035/${image}${roi}_std_A \
	$(pwd)/higher_level/2nd_level/PS038/${image}${roi}_std_A \
	$(pwd)/higher_level/2nd_level/PS041/${image}${roi}_std_A \
	$(pwd)/higher_level/2nd_level/PS044/${image}${roi}_std_A \
	$(pwd)/higher_level/2nd_level/PS046/${image}${roi}_std_A \
	$(pwd)/higher_level/2nd_level/PS052/${image}${roi}_std_A \
	$(pwd)/higher_level/2nd_level/PS053/${image}${roi}_std_A \
	$(pwd)/higher_level/2nd_level/PS002/${image}${roi}_std_A \
	$(pwd)/higher_level/2nd_level/PS004/${image}${roi}_std_A \
	$(pwd)/higher_level/2nd_level/PS006/${image}${roi}_std_A \
	$(pwd)/higher_level/2nd_level/PS011/${image}${roi}_std_A \
	$(pwd)/higher_level/2nd_level/PS016/${image}${roi}_std_A \
	$(pwd)/higher_level/2nd_level/PS018/${image}${roi}_std_A \
	$(pwd)/higher_level/2nd_level/PS020/${image}${roi}_std_A \
	$(pwd)/higher_level/2nd_level/PS024/${image}${roi}_std_A \
	$(pwd)/higher_level/2nd_level/PS028/${image}${roi}_std_A \
	$(pwd)/higher_level/2nd_level/PS029/${image}${roi}_std_A \
	$(pwd)/higher_level/2nd_level/PS031/${image}${roi}_std_A \
	$(pwd)/higher_level/2nd_level/PS034/${image}${roi}_std_A \
	$(pwd)/higher_level/2nd_level/PS036/${image}${roi}_std_A \
	$(pwd)/higher_level/2nd_level/PS039/${image}${roi}_std_A \
	$(pwd)/higher_level/2nd_level/PS043/${image}${roi}_std_A \
	$(pwd)/higher_level/2nd_level/PS047/${image}${roi}_std_A \
	$(pwd)/higher_level/2nd_level/PS048/${image}${roi}_std_A \
	$(pwd)/higher_level/2nd_level/PS049/${image}${roi}_std_A \
	$(pwd)/higher_level/2nd_level/PS054/${image}${roi}_std_A \
	$(pwd)/higher_level/2nd_level/PS056/${image}${roi}_std_A \
	$(pwd)/higher_level/2nd_level/PS059/${image}${roi}_std_A \
	$(pwd)/higher_level/2nd_level/PS060/${image}${roi}_std_A

${FSLDIR}/bin/fslmerge \
	-t \
	/project/3011154.01/MJ/FC/higher_level/3rd_level/randomise/sensitivity_perprotocol_2-7-2021/data/${roi}_B_merged \
	$(pwd)/higher_level/2nd_level/PS003/${image}${roi}_std_B \
	$(pwd)/higher_level/2nd_level/PS012/${image}${roi}_std_B \
	$(pwd)/higher_level/2nd_level/PS014/${image}${roi}_std_B \
	$(pwd)/higher_level/2nd_level/PS017/${image}${roi}_std_B \
	$(pwd)/higher_level/2nd_level/PS019/${image}${roi}_std_B \
	$(pwd)/higher_level/2nd_level/PS021/${image}${roi}_std_B \
	$(pwd)/higher_level/2nd_level/PS025/${image}${roi}_std_B \
	$(pwd)/higher_level/2nd_level/PS026/${image}${roi}_std_B \
	$(pwd)/higher_level/2nd_level/PS027/${image}${roi}_std_B \
	$(pwd)/higher_level/2nd_level/PS033/${image}${roi}_std_B \
	$(pwd)/higher_level/2nd_level/PS035/${image}${roi}_std_B \
	$(pwd)/higher_level/2nd_level/PS038/${image}${roi}_std_B \
	$(pwd)/higher_level/2nd_level/PS041/${image}${roi}_std_B \
	$(pwd)/higher_level/2nd_level/PS044/${image}${roi}_std_B \
	$(pwd)/higher_level/2nd_level/PS046/${image}${roi}_std_B \
	$(pwd)/higher_level/2nd_level/PS052/${image}${roi}_std_B \
	$(pwd)/higher_level/2nd_level/PS053/${image}${roi}_std_B \
	$(pwd)/higher_level/2nd_level/PS002/${image}${roi}_std_B \
	$(pwd)/higher_level/2nd_level/PS004/${image}${roi}_std_B \
	$(pwd)/higher_level/2nd_level/PS006/${image}${roi}_std_B \
	$(pwd)/higher_level/2nd_level/PS011/${image}${roi}_std_B \
	$(pwd)/higher_level/2nd_level/PS016/${image}${roi}_std_B \
	$(pwd)/higher_level/2nd_level/PS018/${image}${roi}_std_B \
	$(pwd)/higher_level/2nd_level/PS020/${image}${roi}_std_B \
	$(pwd)/higher_level/2nd_level/PS024/${image}${roi}_std_B \
	$(pwd)/higher_level/2nd_level/PS028/${image}${roi}_std_B \
	$(pwd)/higher_level/2nd_level/PS029/${image}${roi}_std_B \
	$(pwd)/higher_level/2nd_level/PS031/${image}${roi}_std_B \
	$(pwd)/higher_level/2nd_level/PS034/${image}${roi}_std_B \
	$(pwd)/higher_level/2nd_level/PS036/${image}${roi}_std_B \
	$(pwd)/higher_level/2nd_level/PS039/${image}${roi}_std_B \
	$(pwd)/higher_level/2nd_level/PS043/${image}${roi}_std_B \
	$(pwd)/higher_level/2nd_level/PS047/${image}${roi}_std_B \
	$(pwd)/higher_level/2nd_level/PS048/${image}${roi}_std_B \
	$(pwd)/higher_level/2nd_level/PS049/${image}${roi}_std_B \
	$(pwd)/higher_level/2nd_level/PS054/${image}${roi}_std_B \
	$(pwd)/higher_level/2nd_level/PS056/${image}${roi}_std_B \
	$(pwd)/higher_level/2nd_level/PS059/${image}${roi}_std_B \
	$(pwd)/higher_level/2nd_level/PS060/${image}${roi}_std_B

fi

#----------------------------------------------------------#

# THIRD LEVEL: whole-brain
# 'Member: Make a design in the GLM gui

if [ ${third_level} -eq 1 ]
then

#roi=APsubPP

#${FSLDIR}/bin/randomise \
#	-i $(pwd)/higher_level/control/zstatB${roi}_merged \
#	-o $(pwd)/higher_level/followup/${roi}_smn \
#	-d $(pwd)/designs/statistics/3rd_level/3rd_level_cov.mat \
#	-t $(pwd)/designs/statistics/3rd_level/3rd_level_cov.con \
#	-f $(pwd)/designs/statistics/3rd_level/3rd_level_cov.fts \
#	-m /project/3011154.01/MJ/FC/designs/statistics/masks/smn15.nii.gz \
#	-n 5000 \
#	-R \
#	-T \
#	--uncorrp
#fi

icnr=14
network=SMN
up3ba=up3ba-only
outputdir=/project/3011154.01/MJ/FC/higher_level/3rd_level/randomise/sensitivity_perprotocol_2-7-2021/FC/${network}
mkdir -p ${outputdir}
mask=/project/3024006.02/Users/marjoh/intermediate/groupICA/3rd_level/masks/ic_${icnr}.nii.gz

cp /home/sysneu/marjoh/scripts/ParkInShape/stats/sensitivity_perprotocol/3rd_level_cov_up3ba-only.con /project/3011154.01/MJ/FC/higher_level/3rd_level/randomise/sensitivity_perprotocol_2-7-2021/FC/con_${up3ba}.txt
cp $mask /project/3011154.01/MJ/FC/higher_level/3rd_level/randomise/sensitivity_perprotocol_2-7-2021/FC

# BsubA
${FSLDIR}/bin/randomise \
	-i /project/3011154.01/MJ/FC/higher_level/3rd_level/randomise/sensitivity_perprotocol_2-7-2021/data//${roi}_BsubA_merged \
	-o ${outputdir}/${roi}_${up3ba} \
	-d /home/sysneu/marjoh/scripts/ParkInShape/stats/sensitivity_perprotocol/3rd_level_cov_up3ba-only.mat \
	-t /home/sysneu/marjoh/scripts/ParkInShape/stats/sensitivity_perprotocol/3rd_level_cov_up3ba-only.con \
	-f /home/sysneu/marjoh/scripts/ParkInShape/stats/sensitivity_perprotocol/3rd_level_cov_up3ba-only.fts \
	-m ${mask} \
	-n 5000 \
	-R \
	-T \
	--uncorrp

# A
mkdir -p ${outputdir}/followup
${FSLDIR}/bin/randomise \
	-i /project/3011154.01/MJ/FC/higher_level/3rd_level/randomise/sensitivity_perprotocol_2-7-2021/data//${roi}_A_merged \
	-o ${outputdir}/baseline/${roi}_${up3ba} \
	-d /home/sysneu/marjoh/scripts/ParkInShape/stats/sensitivity_perprotocol/3rd_level_cov_up3ba-only.mat \
	-t /home/sysneu/marjoh/scripts/ParkInShape/stats/sensitivity_perprotocol/3rd_level_cov_up3ba-only.con \
	-f /home/sysneu/marjoh/scripts/ParkInShape/stats/sensitivity_perprotocol/3rd_level_cov_up3ba-only.fts \
	-m ${mask} \
	-n 5000 \
	-R \
	-T \
	--uncorrp

# B
mkdir -p ${outputdir}/followup
${FSLDIR}/bin/randomise \
	-i /project/3011154.01/MJ/FC/higher_level/3rd_level/randomise/sensitivity_perprotocol_2-7-2021/data/${roi}_B_merged \
	-o ${outputdir}/followup/${roi}_${up3ba} \
	-d /home/sysneu/marjoh/scripts/ParkInShape/stats/sensitivity_perprotocol/3rd_level_cov_up3ba-only.mat \
	-t /home/sysneu/marjoh/scripts/ParkInShape/stats/sensitivity_perprotocol/3rd_level_cov_up3ba-only.con \
	-f /home/sysneu/marjoh/scripts/ParkInShape/stats/sensitivity_perprotocol/3rd_level_cov_up3ba-only.fts \
	-m ${mask} \
	-n 5000 \
	-R \
	-T \
	--uncorrp

fi

# Below you will find a list of masks that can be inserted behind the '-m' option in the randomise script just above

#Whole-brain
#$(pwd)/higher_level/standard 
#ROI: IPC
#/project/3011154.01/MJ/FC/designs/statistics/masks/biIPC.nii.gz
#ROI: SMN
#/project/3011154.01/MJ/FC/designs/statistics/masks/smn11.nii.gz
#/project/3011154.01/MJ/FC/designs/statistics/masks/smn14.nii.gz
#/project/3011154.01/MJ/FC/designs/statistics/masks/smn15.nii.gz	<<< The main one
#/project/3011154.01/MJ/FC/designs/statistics/masks/smn.nii.gz
#ROI: Exec
#/project/3011154.01/MJ/FC/designs/statistics/masks/vispar3.nii.gz
#/project/3011154.01/MJ/FC/designs/statistics/masks/rfpn6.nii.gz
#/project/3011154.01/MJ/FC/designs/statistics/masks/lfpn7.nii.gz
#/project/3011154.01/MJ/FC/designs/statistics/masks/ex12.nii.gz

# NEW MASKS following new normalization procedure
#/project/3024006.02/Users/marjoh/intermediate/groupICA/3rd_level/masks/ic_14.nii.gz	SMN
#/project/3024006.02/Users/marjoh/intermediate/groupICA/3rd_level/masks/ic_5.nii.gz	RFPN
#/project/3024006.02/Users/marjoh/intermediate/groupICA/3rd_level/masks/ic_6.nii.gz	LFPN
#/project/3024006.02/Users/marjoh/intermediate/groupICA/3rd_level/masks/ic_12.nii.gz	EXEC



