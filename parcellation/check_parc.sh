#!/bin/bash

# Inspect segmentation and seed definition

subject=$1

export FSLDIR=/opt/fsl/5.0.11
.  ${FSLDIR}/etc/fslconf/fsl.sh

start=${pwd}
junk=/project/3011154.01/MJ/junk
working=/project/3011154.01/MJ/FC

cd ${working}/${subject}/rs/parcellation

# Create a html log file to check registration of highres anatomical to standard space
${FSLDIR}/bin/slicesdir \
	-p ${FSLDIR}/data/standard/MNI152_T1_2mm.nii.gz \
	${working}/${subject}/ana/${subject}_ana_to_std_sub.nii.gz
mv slicesdir slicesdir_reg

# Create a html log file to check segmentation
${FSLDIR}/bin/first_roi_slicesdir \
	${working}/${subject}/ana/${subject}_ana \
	$(pwd)/first/*all_fast_firstseg
mv slicesdir slicesdir_seg

# Print contents of error logfile
cat $(pwd)/first/${subject}_first.logs/*.e*

# Open firefox and fslview for inspection of...
# Registration and segmentation
#firefox $(pwd)/slicesdir_reg/index.html $(pwd)/slicesdir_seg/index.html &
# Registration in fslview
#fslview ${working}/${subject}/ana/${subject}_ana_to_std_sub ${FSLDIR}/data/standard/MNI152_T1_2mm &
# Segmentation in fslview
#fslview ${working}/${subject}/ana/${subject}_ana $(pwd)/intermediate/${subject}_first_all_none_firstseg -l Yellow &

cd ${start}







	
