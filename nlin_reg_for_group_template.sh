#!/bin/bash

#list_subjects=(PS003 PS012 PS014 PS017 PS019 PS021 PS025 PS026 PS027 PS032 PS033 PS035 PS037 PS038 PS041 PS044 PS045 PS046 PS052 PS053 PS057 PS002 PS004 PS006 PS007 PS011 PS016 PS018 PS020 PS022 PS024 PS028 PS029 PS034 PS036 PS043 PS047 PS048 PS049 PS054 PS058 PS059); for s in ${list_subjects[@]}; do qsub -o /project/3011154.01/MJ/anatomical_std_template/logs -e /project/3011154.01/MJ/anatomical_std_template/logs -N templatereg_${s} -v subject=${s} -l 'walltime=01:00:00,mem=2gb' ~/scripts/ParkInShape/nlin_reg_for_group_template.sh; done

# Subject who are left out to make groups even: "PS031" "PS060" "PS056" "PS039"

export FSLDIR=/opt/fsl/6.0.3
.  ${FSLDIR}/etc/fslconf/fsl.sh

separate_sessions=0
avg_sessions=1

if [ $separate_sessions -eq 1 ]; then

sessions=(A_halfwayto_B B_halfwayto_A)
for s in ${sessions[@]}; do

# Set inputs
structimg=/project/3011154.01/MJ/VBM_2/struc/${subject}${s}_ana_struc.nii.gz
betted_structimg=/project/3011154.01/MJ/VBM_2/struc/${subject}${s}_ana_struc_brain.nii.gz
refimg=${FSLDIR}/data/standard/MNI152_T1_2mm_brain
affine_transf=/project/3011154.01/MJ/anatomical_std_template/${subject}${s}_anat2std_affine_transf.mat
nlin_transf=/project/3011154.01/MJ/anatomical_std_template/${subject}${s}_anat2std_nlin_trans
logout=/project/3011154.01/MJ/anatomical_std_template/logs/${subject}${s}_fnirt.log
outimg=/project/3011154.01/MJ/anatomical_std_template/${subject}${s}_warped_ana
#betted_outimg=/project/3011154.01/MJ/anatomical_std_template/${subject}${s}_warped_ana_brain

# Estimate non-linear transformation from halfway anatomicals to standard space
${FSLDIR}/bin/flirt -ref $refimg -in $betted_structimg -omat $affine_transf
${FSLDIR}/bin/fnirt --in=$structimg --aff=$affine_transf --cout=$nlin_transf --config=T1_2_MNI152_2mm

# Apply transformations
${FSLDIR}/bin/applywarp --ref=$refimg --in=$structimg --warp=$nlin_transf --out=$outimg

# Bet
#${FSLDIR}/bin/bet $outimg $betted_outimg -R -f 0.45

done

fi

if [ $avg_sessions -eq 1 ]; then

strucA=/project/3024006.02/ParkInShape_siena/${subject}A_ana2_to_${subject}B_ana2_siena/A_halfwayto_B.nii.gz
strucB=/project/3024006.02/ParkInShape_siena/${subject}A_ana2_to_${subject}B_ana2_siena/B_halfwayto_A.nii.gz
strucAVG=/project/3024006.02/ParkInShape_siena/${subject}A_ana2_to_${subject}B_ana2_siena/halfwayto_avg
${FSLDIR}/bin/fslmaths $strucA -add $strucB -div 2 $strucAVG

strucAVG_brain=${strucAVG}_brain
${FSLDIR}/bin/bet $strucAVG $strucAVG_brain -R

refimg=${FSLDIR}/data/standard/MNI152_T1_2mm_brain
affine_transf=/project/3011154.01/MJ/anatomical_std_template/${subject}_anat2std_affine_transf.mat
${FSLDIR}/bin/flirt -ref $refimg -in $strucAVG_brain -omat $affine_transf

nlin_transf=/project/3011154.01/MJ/anatomical_std_template/${subject}${s}_anat2std_nlin_trans
${FSLDIR}/bin/fnirt --in=$strucAVG --aff=$affine_transf --cout=$nlin_transf --config=T1_2_MNI152_2mm

outimg=/project/3011154.01/MJ/anatomical_std_template/${subject}_ABavg_warped_ana
${FSLDIR}/bin/applywarp --ref=$refimg --in=$strucAVG --warp=$nlin_transf --out=$outimg

fi

