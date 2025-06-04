#!/bin/bash

# Form masks of striatum in anatomical space

##QSUB
#qsub -o /project/3011154.01/MJ/logs -e /project/3011154.01/MJ/logs -N first -l 'walltime=10:00:00,mem=8gb' /project/3011154.01/MJ/scripts/parcellation/parcellation_first.sh

export FSLDIR=/opt/fsl/5.0.11
.  ${FSLDIR}/etc/fslconf/fsl.sh

junk=/project/3011154.01/MJ/junk
working=/project/3011154.01/MJ/FC
#working=/project/3011154.01/MJ/teststuff

cd ${working}

# Segment non-brain extracted anatomical
# Note: For some reason run_first_all does not run correctly on participant-wise job submissions, which is why we make the segmentation into a single job. Takes about 5 min per subject, so this is a time consuming one

list_subjects=()

for i in ${list_subjects[@]}; do
  # Segment subcortical structures
  mkdir -p $(pwd)/${i}/rs/parcellation/first
  ${FSLDIR}/bin/run_first_all \
	-d \
	-s L_Puta,R_Puta,L_Caud,R_Caud,L_Accu,R_Accu \
	-i $(pwd)/${i}/ana/${i}_ana \
	-o $(pwd)/${i}/rs/parcellation/first/highres

  # Create directories for checking segmentation quality
  cd ${working}/${i}/rs/parcellation/first
  ${FSLDIR}/bin/first_roi_slicesdir \
	${working}/${i}/ana/${i}_ana \
	${working}/${i}/rs/parcellation/first/highres_all_fast_firstseg
  cd ${working}
done
