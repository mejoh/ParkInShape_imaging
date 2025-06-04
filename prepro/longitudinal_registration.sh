#!/bin/bash

#list_subjects=(PS003 PS012 PS014 PS017 PS019 PS021 PS025 PS026 PS027 PS032 PS033 PS035 PS037 PS038 PS041 PS044 PS045 PS046 PS052 PS053 PS057 PS002 PS004 PS006 PS007 PS011 PS016 PS018 PS020 PS022 PS024 PS028 PS029 PS031 PS034 PS036 PS039 PS043 PS047 PS048 PS049 PS054 PS056 PS058 PS059 PS060); for s in ${list_subjects[@]}; do qsub -o /project/3024006.02/ParkInShape_siena/logs -e /project/3024006.02/ParkInShape_siena/logs -N siena_${s} -v subject=${s} -l 'walltime=01:30:00,mem=3gb' ~/scripts/ParkInShape/prepro/longitudinal_registration.sh; done

export FSLDIR=/opt/fsl/6.0.3
.  ${FSLDIR}/etc/fslconf/fsl.sh

SIENA=0
voxelwise_siena=0
vbm=0
func=0
fw=0

dSiena="/project/3024006.02/ParkInShape_siena"

if [ $SIENA -eq 1 ]
then

echo "Beginning longitudinal registration"
echo "Locating anatomical images"
ana_t1="/project/3011154.01/MJ/FC/${subject}A/ana/${subject}A_ana2.nii.gz"
if test -f $anat_t1 ; then
	echo "Located T1, copying"
	cp $ana_t1 $dSiena
else
	echo "T1 anatomical not found, exiting..."
	exit
fi
ana_t2="/project/3011154.01/MJ/FC/${subject}B/ana/${subject}B_ana2.nii.gz"
if test -f $anat_t2 ; then
	echo "Located T2, copying"
	cp $ana_t2 $dSiena
else
	echo "T2 anatomical not found, exiting..."
	exit
fi

cd $dSiena

${FSLDIR}/bin/siena ${subject}A_ana2.nii.gz ${subject}B_ana2.nii.gz -B "-R -B -f 0.45" -m -d

fi

if [ $voxelwise_siena -eq 1 ]; then

cd $dSiena/${subject}A_ana2_to_${subject}B_ana2_siena
${FSLDIR}/bin/siena_flow2std A.nii.gz B.nii.gz -s 6

fi

if [ $vbm -eq 1 ]
then

dSiena="/project/3024006.02/ParkInShape_siena/${subject}A_ana2_to_${subject}B_ana2_siena"
dVBM="/project/3011154.01/MJ/VBM_2"

#if test -f $dSiena/A_halfwayto_B.mat && test -f $dSiena/B_halfwayto_A.mat; then
#echo "FLIRTing anatomicals, outputting to VBM dir..."
#	${FSLDIR}/bin/flirt -in $dSiena/A.nii.gz -ref $dSiena/B.nii.gz -out $dVBM/${subject}#A_halfwayto_B_ana -init $dSiena/A_halfwayto_B.mat -applyxfm
#	${FSLDIR}/bin/flirt -in $dSiena/B.nii.gz -ref $dSiena/A.nii.gz -out $dVBM/${subject}#B_halfwayto_A_ana -init $dSiena/B_halfwayto_A.mat -applyxfm
#else
#	echo "Halfway transformations does not exist, exiting..."
#	exit
#fi

cp $dSiena/A_halfwayto_B.nii.gz $dVBM/${subject}_A_halfwayto_B.nii.gz
cp $dSiena/B_halfwayto_A.nii.gz $dVBM/${subject}_B_halfwayto_A.nii.gz

fi














