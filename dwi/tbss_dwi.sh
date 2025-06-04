#!/bin/bash

#qsub -o /project/3011154.01/MJ/DWI/logs -e /project/3011154.01/MJ/DWI/logs -N TBSS -l 'walltime=05:00:00,mem=16gb' ~/scripts/dwi/tbss_dwi.sh

#####		  Description	              ####
##### A script for running TBSS on two groups ####
#####					      ####
#####					      ####

export FSLDIR=/opt/fsl/6.0.0
.  ${FSLDIR}/etc/fslconf/fsl.sh

CopyImgs=0
RunFullTBSS=0
GenerateDiffs=1

ROOTdir=/project/3011154.01/MJ				# Directories
DWIdir=${ROOTdir}/DWI
DWIPROCdir=${DWIdir}/processed				
TBSSdir=${DWIPROCdir}/TBSS
FAdir=${TBSSdir}/FA					# Directory is created during TBSS
DIFFdir=${TBSSdir}/BsubA
FAimg=b0/dti_FA.nii.gz					# Result of DTIFIT (see eddy.sh), stored in DWIPROCdir
SKELETONimg=${TBSSdir}/stats/all_FA_skeletonised.nii.gz

Session=(A B)
Aerobic=(PS003 PS012 PS014 PS017 PS019 PS021 PS025 PS026 PS027 PS032 PS033 PS035 PS037 PS038 PS044 PS045 PS046 PS052 PS057)
Control=(PS002 PS004 PS006 PS007 PS011 PS018 PS020 PS022 PS024 PS028 PS029 PS031 PS034 PS036 PS039 PS042 PS043 PS047 PS048 PS049 PS054 PS056 PS058 PS059 PS060)

if [ ${CopyImgs} -eq 1 ]; then
	mkdir -p ${TBSSdir}				# Copy FA images to TBSS directory
	for s in ${Session[@]}; do
		for n in ${Aerobic[@]}; do
			cp ${DWIPROCdir}/${n}${s}/${FAimg} ${TBSSdir}/AE_${n}${s}_rawFA.nii.gz
		done
	done
	for s in ${Session[@]}; do
		for n in ${Control[@]}; do
			cp ${DWIPROCdir}/${n}${s}/${FAimg} ${TBSSdir}/CON_${n}${s}_rawFA.nii.gz
		done
	done
fi

if [ ${RunFullTBSS} -eq 1 ]; then
	cd ${TBSSdir}
	${FSLDIR}/bin/tbss_1_preproc *.nii.gz		# Prepares FA images and folders
	${FSLDIR}/bin/tbss_2_reg -T 			# Registers to FMRIB58_FA
	${FSLDIR}/bin/tbss_3_postreg -S			# Applies non-linear transform. Generates mean FA and skeletonised mean FA from subjects data (-S option)
	${FSLDIR}/bin/tbss_4_prestats 0.3		# Thresholds mean FA skeleton. Generates distance map for projecting FA data onto the mean FA skeleton
fi

if [ ${GenerateDiffs} -eq 1 ]; then

mkdir -p ${DIFFdir}				# Subtract Skeletonised FA between sessions.

Counter=0
Subject=0
NAE=36		# 2 less than the real number because volumes start at 0
until [ ${Counter} -gt ${NAE} ]; do
	${FSLDIR}/bin/fslroi \
	${SKELETONimg} \
	${DIFFdir}/intermediate_diff \
	`echo ${Counter}` \
	`echo ${Counter} | awk '{ print $1 + 2}'`

	${FSLDIR}/bin/fslroi \
	${DIFFdir}/intermediate_diff \
	${DIFFdir}/intermediate_diff_A \
	0 \
	1

	${FSLDIR}/bin/fslroi \
	${DIFFdir}/intermediate_diff \
	${DIFFdir}/intermediate_diff_B \
	1 \
	1	

	${FSLDIR}/bin/fslmaths \
	${DIFFdir}/intermediate_diff_B \
	-sub \
	${DIFFdir}/intermediate_diff_A \
	${DIFFdir}/AE_${Aerobic[${Subject}]}_SkelFA_BsubA

	Counter=`echo ${Counter} | awk '{ print $1 + 2}'`
	Subject=`echo ${Subject} | awk '{ print $1 + 1}'`
done
Counter=0
Subject=0
NAC=48		# 2 less than the real number because volumes start at 0
until [ ${Counter} -gt ${NAC} ]; do
	${FSLDIR}/bin/fslroi \
	${SKELETONimg} \
	${DIFFdir}/intermediate_diff \
	`echo ${Counter}` \
	`echo ${Counter} | awk '{ print $1 + 2}'`

	${FSLDIR}/bin/fslroi \
	${DIFFdir}/intermediate_diff \
	${DIFFdir}/intermediate_diff_A \
	0 \
	1

	${FSLDIR}/bin/fslroi \
	${DIFFdir}/intermediate_diff \
	${DIFFdir}/intermediate_diff_B \
	1 \
	1	

	${FSLDIR}/bin/fslmaths \
	${DIFFdir}/intermediate_diff_B \
	-sub \
	${DIFFdir}/intermediate_diff_A \
	${DIFFdir}/CON_${Control[${Subject}]}_SkelFA_BsubA

	Counter=`echo ${Counter} | awk '{ print $1 + 2}'`
	Subject=`echo ${Subject} | awk '{ print $1 + 1}'`
done

rm ${DIFFdir}/intermediate_diff.nii.gz ${DIFFdir}/intermediate_diff_A.nii.gz ${DIFFdir}/intermediate_diff_B.nii.gz

cd ${DIFFdir}
${FSLDIR}/bin/fslmerge \
-t \
AE_SkelFA_merged \
`imglob AE*.nii.gz`

${FSLDIR}/bin/fslmerge \
-t \
CON_SkelFA_merged \
`imglob CON*.nii.gz`

${FSLDIR}/bin/fslmerge \
-t \
All_SkelFA_merged \
${DIFFdir}/AE_SkelFA_merged ${DIFFdir}/CON_SkelFA_merged

fi



#for n in ${Aerobic[@]}; do
#	${FSLDIR}/bin/fslmaths \
#	${FAdir}/AE_${n}B_rawFA_FA_to_target.nii.gz \
#	-sub \
#	${FAdir}/AE_${n}A_rawFA_FA_to_target.nii.gz \
#	${DIFFdir}/AE_${n}BsubA_FA
#done
#for n in ${Control[@]}; do
#	${FSLDIR}/bin/fslmaths \
#	${FAdir}/CON_${n}B_rawFA_FA_to_target.nii.gz \
#	-sub \
#	${FAdir}/CON_${n}A_rawFA_FA_to_target.nii.gz \
#	${DIFFdir}/CON_${n}BsubA_FA
#done

#cd ${DIFFdir}
#${FSLDIR}/bin/fslmerge \
#-t \
#AE_FA_merged \
#`imglob AE*.nii.gz`

#${FSLDIR}/bin/fslmerge \
#-t \
#CON_FA_merged \
#`imglob CON*.nii.gz`

#${FSLDIR}/bin/fslmerge \
#-t \
#All_FA_merged \
#${DIFFdir}/AE_FA_merged ${DIFFdir}/CON_FA_merged

