#!/bin/bash

#cd /project/3024006.02/Data/intermediate/DAC/mri/derivatives/vbm/input_halfway_images; list_subjects=`find PS0* -maxdepth 0 | cut -c -6`; for s in ${list_subjects[@]}; do qsub -o $(pwd) -e $(pwd) -N deface_${s} -v subject=${s} -l 'walltime=00:30:00,mem=6gb' ~/scripts/ParkInShape-scripts/deface_anat.sh; done

#subject=PS060B

module add bidscoin
export BIDSCOIN=/opt/bidscoin/bin/
module add fsl
export FSLDIR=/opt/fsl/6.0.5
.  ${FSLDIR}/etc/fslconf/fsl.sh

cd /project/3024006.02/Data/intermediate/DAC/mri/derivatives/vbm/input_halfway_images
outputdir=/project/3024006.02/Data/intermediate/DAC/mri/derivatives/vbm/input_halfway_images

#mkdir -p ${outputdir}/${subject}/ana
#img1=/project/3011154.01/MJ/FC/${subject}/ana/${subject}_ana.nii.gz
img1=`ls ${outputdir}/${subject}_halfwayto_*_ana.nii.gz`
name=`basename $img1`

#if gzip -t $img1; then
#	echo '$s file is ok'
	$BIDSCOIN/pydeface $img1 --outfile ${outputdir}/deface/${name} --verbose
#else 
#	echo 'file has had a .gz extension tagged on... fixing'
#	cp $img1 ${outputdir}/${subject}/ana/tmp${subject}_ana.nii
#	gzip ${outputdir}/${subject}/ana/tmp${subject}_ana.nii
#	$BIDSCOIN/pydeface ${outputdir}/${subject}/ana/tmp${subject}_ana.nii.gz --outfile ${outputdir}/${subject}/ana/${subject}_ana.nii.gz --verbose
#	rm ${outputdir}/${subject}/ana/tmp${subject}_ana.nii.gz
#fi




