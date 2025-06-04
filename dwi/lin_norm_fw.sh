#!/bin/bash

export FSLDIR=/opt/fsl/6.0.1
.  ${FSLDIR}/etc/fslconf/fsl.sh

Subjects=(PS002A PS002B PS003A PS003B)

for i in ${Subjects[@]}; do

ana=/project/3011154.01/MJ/DWI/processed/${i}/PATCH/${i}_ana.nii
b0=/project/3011154.01/MJ/DWI/processed/${i}/PATCH/first_b0.nii.gz
fw=/project/3011154.01/MJ/DWI/processed/FW/tmp/Edit/${i}_FW_edit.nii.gz
RefImg=${FSLDIR}/data/standard/MNI152_T1_2mm_brain
#RefImg=/project/3011154.01/MJ/DWI/avg152T2.nii.gz

# Estimate linear: dwi to mni
${FSLDIR}/bin/flirt \
-in ${b0} \
-ref ${RefImg} \
-omat /project/3011154.01/MJ/DWI/processed/${i}/PATCH/dwi2mni.mat \

# Apply linear: b0 to mni
${FSLDIR}/bin/flirt \
-in ${b0} \
-ref ${RefImg} \
-out /project/3011154.01/MJ/DWI/processed/FW/tmp/${i}_b0_norm \
-init /project/3011154.01/MJ/DWI/processed/${i}/PATCH/dwi2mni.mat \
-applyxfm

# Apply linear: FW to mni
${FSLDIR}/bin/flirt \
-in ${fw} \
-ref ${RefImg} \
-out /project/3011154.01/MJ/DWI/processed/FW/tmp/${i}_FW_norm \
-init /project/3011154.01/MJ/DWI/processed/${i}/PATCH/dwi2mni.mat \
-applyxfm

done

