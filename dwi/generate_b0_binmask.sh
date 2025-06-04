#!/bin/bash

export FSLDIR=/opt/fsl/6.0.1
.  ${FSLDIR}/etc/fslconf/fsl.sh

ROOTdir=/project/3011154.01/MJ/DWI

Subjects=(PS030A PS055A PS010A PS023A PS040A PS051A PS041A PS053A)
for i in ${Subjects[@]}; do

RAWimg=${ROOTdir}/didi/${i}/FDT_Data/data.nii.gz
OUTdir=${ROOTdir}/processed/${i}/PATCH

${FSLDIR}/bin/fslroi \
${RAWimg} \
${OUTdir}/first_b0 \
0 \
1

${FSLDIR}/bin/bet \
${OUTdir}/first_b0 \
${OUTdir}/first_b0_brain \
-m \
-n \
-f 0.2 \
-g 0.1

done
