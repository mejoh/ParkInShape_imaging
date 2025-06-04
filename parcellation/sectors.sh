#!/bin/bash

# Create a posterior and an anterior quadrant separated by a 4mm gap at the anterior commisure for use when dividing putamen into posterior and anterior sections. This is done simply by multiplying a putamen mask with one of the quadrants. More is removed from the anterior than the posterior because or relative size differences

export FSLDIR=/opt/fsl/5.0.11
.  ${FSLDIR}/etc/fslconf/fsl.sh

start=${pwd}
junk=/project/3011154.01/MJ/junk
working=/project/3011154.01/MJ/FC
cd ${working}/designs/parcellation

# -1mm from the AC
fslmaths ${FSLDIR}/data/standard/MNI152_T1_2mm_brain \
	-mul 0 \
	-add 1 \
	-roi 0 -1 0 125 0 -1 0 1 \
	posterior \
	-odt float

# +2mm from the AC
fslmaths ${FSLDIR}/data/standard/MNI152_T1_2mm_brain \
	-mul 0 \
	-add 1 \
	-roi 0 -1 129 90 0 -1 0 1 \
	anterior \
	-odt float

# Settings for MNI152_1mm
# 0 125
# 129 90
# For 2mm
# 0 63
# 65 108

cd ${start}
