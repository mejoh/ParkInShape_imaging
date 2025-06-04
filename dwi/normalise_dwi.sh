#!/bin/bash

#list_subjects=(PS002A PS002B PS003A PS003B PS004A PS004B PS006A PS006B PS007A PS007B PS011A PS011B PS012A PS012B PS014A PS014B PS017A PS017B PS018A PS018B PS019A PS019B PS020A PS020B PS021A PS021B PS022A PS022B PS024A PS024B PS025A PS025B PS026A PS026B PS027A PS027B PS028A PS028B PS029A PS029B PS031A PS031B PS032A PS032B PS033A PS033B PS034A PS034B PS035A PS035B PS036A PS036B PS037A PS037B PS038A PS038B PS039A PS039B PS042A PS042B PS043A PS043B PS044A PS044B PS045A PS045B PS046A PS046B PS047A PS047B PS048A PS048B PS049A PS049B PS052A PS052B PS054A PS054B PS056A PS056B PS057A PS057B PS058A PS058B PS059A PS059B PS060A PS060B); for s in ${list_subjects[@]}; do qsub -o /project/3011154.01/MJ/DWI/logs -e /project/3011154.01/MJ/DWI/logs -N norm_${s} -v subject=${s} -l 'walltime=00:30:00,mem=2gb' ~/scripts/dwi/normalise_dwi.sh; done

#list_subjects=(PS002A PS002B PS003A PS003B PS004A PS004B PS006A PS006B PS007A PS007B); for s in ${list_subjects[@]}; do qsub -o /project/3011154.01/MJ/DWI/logs -e /project/3011154.01/MJ/DWI/logs -N norm_${s} -v subject=${s} -l 'walltime=00:30:00,mem=2gb' ~/scripts/dwi/normalise_dwi.sh; done

export FSLDIR=/opt/fsl/6.0.3
.  ${FSLDIR}/etc/fslconf/fsl.sh

### DESCRIPTION ###
# Goal: Normlisation of B0 and FW images
# Estimate linear transformations from DWI to T1, and from T1 to MNI.
# Use estimated T1>MNI to estimate non-linear transformation
# Apply non-linear transformation to B0 and FW images (FW images are first masked)

LinTrans=0
NonLinTrans=1

DWIDir=/project/3011154.01/MJ/DWI/processed/${subject}/b0
# B0
B0Img=${DWIDir}/dti_S0
B0OutImg=${DWIDir}/S0_norm
# FA
FAImg=${DWIDir}/dti_FA
FAOutImg=${DWIDir}/FA_norm
# MD
MDImg=${DWIDir}/dti_MD
MDOutImg=${DWIDir}/MD_norm
# T1
FCDir=/project/3011154.01/MJ/FC/${subject}/ana
BetAnatImg=${FCDir}/${subject}_ana_brain
RegAnatImg=${FCDir}/${subject}_ana
# Normalisation
mkdir -p ${DWIDir}/normalisation
NORMDir=${DWIDir}/normalisation
# FW
FWDir=/project/3011154.01/MJ/DWI/processed/FW/Edit
FWImg=${FWDir}/${subject}_FW_edit.nii.gz
Mask=${DWIDir}/avg_mask.nii.gz
FWImgMasked=${FWDir}/${subject}_FW_edit_mask
FWOutDir=/project/3011154.01/MJ/DWI/processed/FW/Normalised
FWOutImg=${FWOutDir}/${subject}_FW_norm

#------------------------------------------#
# Linear transformation to MNI space

if [ ${LinTrans} -eq 1 ]; then

RefImg=${FSLDIR}/data/standard/MNI152_T1_2mm_brain
#RefImg=/project/3011154.01/MJ/DWI/avg152T2.nii.gz

# Estimate linear: dwi to mni
${FSLDIR}/bin/flirt \
-in ${B0Img} \
-ref ${RefImg} \
-omat ${NORMDir}/dwi2mni.mat \

# Apply linear: b0 to mni
${FSLDIR}/bin/flirt \
-in ${B0Img} \
-ref ${RefImg} \
-out ${B0OutImg} \
-init ${NORMDir}/dwi2mni.mat \
-applyxfm

# Apply linear: FA to mni
${FSLDIR}/bin/flirt \
-in ${FAImg} \
-ref ${RefImg} \
-out ${FAOutImg} \
-init ${NORMDir}/dwi2mni.mat \
-applyxfm

# Apply linear: MD to mni
${FSLDIR}/bin/flirt \
-in ${MDImg} \
-ref ${RefImg} \
-out ${MDOutImg} \
-init ${NORMDir}/dwi2mni.mat \
-applyxfm

# Mask: FW
${FSLDIR}/bin/fslmaths \
${FWImg} \
-mul \
${Mask} \
${FWImgMasked}

# Apply linear: FW to mni
${FSLDIR}/bin/flirt \
-in ${FWImgMasked} \
-ref ${RefImg} \
-out ${FWOutImg} \
-init ${NORMDir}/dwi2mni.mat \
-applyxfm

fi

#------------------------------------------#
# Non-linear transformation to MNI space

if [ ${NonLinTrans} -eq 1 ]; then

# Estimate linear: DWI to T1
${FSLDIR}/bin/flirt \
-ref ${BetAnatImg} \
-in ${B0Img} \
-dof 12 \
-omat ${NORMDir}/dwi2struct.mat

# Estimate linear: T1 to MNI
${FSLDIR}/bin/flirt \
-ref ${FSLDIR}/data/standard/MNI152_T1_2mm_brain \
-in ${BetAnatImg} \
-dof 12 \
-omat ${NORMDir}/affine_transf.mat

# Estimate non-linear: T1 to MNI
${FSLDIR}/bin/fnirt \
--in=${RegAnatImg} \
--aff=${NORMDir}/affine_transf.mat \
--cout=${NORMDir}/nonlinear_transf \
--config=T1_2_MNI152_2mm

# Apply non-linear: DWI to MNI
${FSLDIR}/bin/applywarp \
--ref=${FSLDIR}/data/standard/MNI152_T1_2mm \
--in=${B0Img} \
--warp=${NORMDir}/nonlinear_transf \
--premat=${NORMDir}/dwi2struct.mat \
--out=${B0OutImg}

# Mask: FW
${FSLDIR}/bin/fslmaths \
${FWImg} \
-mul \
${Mask} \
${FWImgMasked}

# Apply non-linear: DWI to MNI
${FSLDIR}/bin/applywarp \
--ref=${FSLDIR}/data/standard/MNI152_T1_2mm \
--in=${FWImgMasked} \
--warp=${NORMDir}/nonlinear_transf \
--premat=${NORMDir}/dwi2struct.mat \
--out=${FWOutImg}

fi






