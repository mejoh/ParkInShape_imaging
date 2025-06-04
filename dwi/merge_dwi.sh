#!/bin/bash

export FSLDIR=/opt/fsl/6.0.0
.  ${FSLDIR}/etc/fslconf/fsl.sh

Session=(A B)

Aerobic=(PS003 PS012 PS014 PS017 PS019 PS021 PS025 PS026 PS027 PS032 PS033 PS035 PS037 PS038 PS044 PS045 PS046 PS052 PS057)

Control=(PS002 PS004 PS006 PS007 PS011 PS018 PS020 PS022 PS024 PS028 PS029 PS031 PS034 PS036 PS039 PS042 PS043 PS047 PS048 PS049 PS054 PS056 PS058 PS059 PS060) 

Subjects=(PS003 PS012 PS014 PS017 PS019 PS021 PS025 PS026 PS027 PS032 PS033 PS035 PS037 PS038 PS044 PS045 PS046 PS052 PS057 PS002 PS004 PS006 PS007 PS011 PS018 PS020 PS022 PS024 PS028 PS029 PS031 PS034 PS036 PS039 PS042 PS043 PS047 PS048 PS049 PS054 PS056 PS058 PS059 PS060)

FWDir=/project/3011154.01/MJ/DWI/processed/FW/Normalised
cd ${FWDir}

for s in ${Session[@]}; do
	${FSLDIR}/bin/fslmerge \
	-t \
	${FWDir}/All_${s}_merged \
	"${Subjects[@]/%/${s}_FW_norm.nii.gz}"	# This line lists all elements of the Subjects array,
						# then uses /%/ to tag on stuff to each element
	${FSLDIR}/bin/fslmerge \
	-t \
	${FWDir}/AE_${s}_merged \
	"${Aerobic[@]/%/${s}_FW_norm.nii.gz}"

	${FSLDIR}/bin/fslmerge \
	-t \
	${FWDir}/AC_${s}_merged \
	"${Control[@]/%/${s}_FW_norm.nii.gz}"
done						

${FSLDIR}/bin/fslmaths ${FWDir}/All_B_merged -sub ${FWDir}/All_A_merged ${FWDir}/All_BsubA_merged
${FSLDIR}/bin/fslmaths ${FWDir}/AE_B_merged -sub ${FWDir}/AE_A_merged ${FWDir}/AE_BsubA_merged
${FSLDIR}/bin/fslmaths ${FWDir}/AC_B_merged -sub ${FWDir}/AC_A_merged	${FWDir}/AC_BsubA_merged

${FSLDIR}/bin/fslmaths ${FWDir}/All_BsubA_merged -Tmean ${FWDir}/All_BsubA_Tmean
${FSLDIR}/bin/fslmaths ${FWDir}/AE_BsubA_merged -Tmean ${FWDir}/AE_BsubA_Tmean
${FSLDIR}/bin/fslmaths ${FWDir}/AC_BsubA_merged -Tmean ${FWDir}/AC_BsubA_Tmean
