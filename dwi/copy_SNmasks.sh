#!/bin/bash

#cd /project/3011154.01; list_subjects=`ls -d PS*`; for s in ${list_subjects[@]}; do qsub -o /project/3024006.02/Data/intermediate/DAC/RSFMRI/ -e /project/3024006.02/Data/intermediate/DAC/RSFMRI/ -N cp_${s} -v subject=${s} -l 'walltime=00:30:00,mem=3gb' ~/scripts/ParkInShape-scripts/dwi/copy_SNmasks.sh; done

outputdir=/project/3024006.02/Data/intermediate/DAC/mri/derivatives/diffusion_metrics/
#outputdir=/project/3022026.01/tmp/Martin/ParkInShape_raw

cd /project/3011154.01/MJ/DWI/didi
subject=`ls -d PS0*`
#echo $subjects
#subject=(PS002A)

for s in ${subject[@]}; do

	echo "Copying $s"
	#id=sub-${s:0:5}
	#ses=ses-${s:5:6}

	##### Dicoms
	#img_list=`ls /project/3011154.01/${s}/*/*.IMA`
	#echo "`ls /project/3011154.01/${s}/*/*.IMA | wc -l` dicom files found in sub-folder"
	#mkdir -p ${outputdir}/${s}
	#for n in ${img_list[@]}; do
	#	cp ${n} ${outputdir}/${s}
	#done

	#img_list=`ls /project/3011154.01/${s}/*.IMA`
	#echo "`ls /project/3011154.01/${s}/*.IMA | wc -l` dicom files found in top-folder"
	#mkdir -p ${outputdir}/${s}
	#for n in ${img_list[@]}; do
	#	cp ${n} ${outputdir}/${s}
	#done

	##### Eye-tracking
	#img_list=`ls /project/3024006.02/Data/intermediate/DAC/RSFMRI/${s}/behav/*`
	#echo "`ls /project/3024006.02/Data/intermediate/DAC/RSFMRI/${s}/behav/* | wc -l` eye-tracking files found"
	#mkdir -p ${outputdir}/${s}
	#for n in ${img_list[@]}; do
	#	cp ${n} ${outputdir}/${s}
	#done

	##### EMG
	#img_list=`ls /project/3024006.02/Data/intermediate/DAC/RSFMRI/${s}/emg/*`
	#echo "`ls /project/3024006.02/Data/intermediate/DAC/RSFMRI/${s}/emg/* | wc -l` emg files found"
	#mkdir -p ${outputdir}/${s}
	#for n in ${img_list[@]}; do
	#	cp ${n} ${outputdir}/${s}
	#done

	##### Preprocessed FUNC and DWI
	#img1=/project/3011154.01/MJ/FC/${s}/rs/prepro.feat/${s}_nuireg_hp_addsmth.nii.gz
	#if [ -f $img1 ]; then
	#	mkdir -p ${outputdir}/${s}/func
	#	cp $img1 ${outputdir}/${s}/func/${s}_func_preproc.nii.gz
	#fi

	#img2=/project/3011154.01/MJ/DWI/didi/${s}/FDT_Data/data.nii.gz
	#if [ -f $img2 ]; then
	#	mkdir -p ${outputdir}/${s}/dwi
	#	cp $img2 ${outputdir}/${s}/dwi/${s}_dwi_preproc.nii.gz
	#fi

	##### DWI derivatives
	img1=/project/3011154.01/MJ/DWI/FreeWater/${s}_FW_fixed_norm2.nii.gz
	if [ -f $img1 ]; then
		cp $img1 ${outputdir}/FreeWater/${s}_FW_std.nii.gz
	fi
	img2=/project/3011154.01/MJ/DWI/didi/${s}/reg2/FA_norm2.nii.gz
	if [ -f $img2 ]; then
		cp $img2 ${outputdir}/FractionalAnisotropy/${s}_FA_std.nii.gz
	fi
	img3=/project/3011154.01/MJ/DWI/didi/${s}/reg2/MD_norm2.nii.gz
	if [ -f $img3 ]; then
		cp $img3 ${outputdir}/MeanDiffusivity/${s}_MD_std.nii.gz
	fi
	img4=/project/3011154.01/MJ/DWI/didi/${s}/reg2/b0_mean_brain_norm.nii.gz
	if [ -f $img4 ]; then
		cp $img4 ${outputdir}/b0/${s}_avg-b0_std.nii.gz
	fi
	img5=`ls /project/3011154.01/MJ/DWI/didi/${s}/reg/SNmask*` 
	mkdir -p /project/3024006.02/Data/intermediate/DAC/mri/derivatives/diffusion_metrics/SubstantiaNigra_masks/${s}
	for m in ${img5}; do
		cp $m /project/3024006.02/Data/intermediate/DAC/mri/derivatives/diffusion_metrics/SubstantiaNigra_masks/${s}
	done

done

#cd /project/3011154.01/MJ/DWI/didi/${s}
#img_list=`ls f*.nii`
#fslmerge -t ${outputdir}/${s}/dwi/${s}_dwi `echo ${img_list[@]}`

