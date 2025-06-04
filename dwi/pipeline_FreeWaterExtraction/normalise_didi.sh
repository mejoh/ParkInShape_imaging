#!/bin/bash

#list_subjects=(PS030A PS055A PS010A PS023A PS040A PS051A PS041A PS053A); for s in ${list_subjects[@]}; do qsub -o /project/3011154.01/MJ/DWI/logs -e /project/3011154.01/MJ/DWI/logs -N normDiDI_${s} -v subject=${s} -l 'walltime=00:10:00,mem=1gb' ~/scripts/ParkInShape/dwi/pipeline_FreeWaterExtraction/normalise_didi.sh; done

# PS002A PS002B PS003A PS003B PS004A PS004B PS006A PS006B PS007A PS007B PS011A PS011B PS012A PS012B PS014A PS014B PS017A PS017B PS018A PS018B PS019A PS019B PS020A PS020B PS021A PS021B PS022A PS022B PS024A PS024B PS025A PS025B PS026A PS026B PS027A PS027B PS028A PS028B PS029A PS029B PS031A PS031B PS032A PS032B PS033A PS033B PS034A PS034B PS035A PS035B PS036A PS036B PS037A PS037B PS038A PS038B PS039A PS039B PS042A PS042B PS043A PS043B PS044A PS044B PS045A PS045B PS046A PS046B PS047A PS047B PS048A PS048B PS049A PS049B PS052A PS052B PS054A PS054B PS056A PS056B PS057A PS057B PS058A PS058B PS059A PS059B PS060A PS060B

subject=PS042B


export FSLDIR=/opt/fsl/6.0.3
.  ${FSLDIR}/etc/fslconf/fsl.sh

DidiDir=/project/3011154.01/MJ/DWI/didi/$subject			# Subject specific Didi directory
DidiRegDir=$DidiDir/reg2							# Subject specific registration directory
FeatRegDir=/project/3024006.02/Users/marjoh/intermediate/$subject.feat/reg	# Subject specific FEAT registration directory

PreprocData=FDT_Data/data.nii.gz					# Preprocessed data
AnatomicalRef=highres.nii.gz						# Betted T1
WarpAna2Std=highres2standard_warp.nii.gz				# Non-linear transform: Ana-to-MNI

if [ -d $DidiRegDir ]; then						# Start with fresh directory
	rm -r $DidiRegDir
	mkdir $DidiRegDir
else
	mkdir $DidiRegDir
fi

# Generate betted mean b0 img and mask for FW calculation
b0idx=(0 1 11 21 31 41 51 61)		# Index of volumes without diffusion weighting
for i in ${b0idx[@]}; do
    ${FSLDIR}/bin/fslroi $DidiDir/$PreprocData $DidiRegDir/b0_vol${i} ${i} 1
done
${FSLDIR}/bin/fslmerge -t $DidiRegDir/b0_vols $DidiRegDir/b0_vol*
${FSLDIR}/bin/fslmaths $DidiRegDir/b0_vols -Tmean $DidiRegDir/b0_mean
rm $DidiRegDir/b0_vol*
${FSLDIR}/bin/bet $DidiRegDir/b0_mean $DidiRegDir/b0_mean_brain -R -f 0.1 -g -0.2 -m	# -m Mask for FW calculation
b0=b0_mean_brain

# Estimate linear: DWI to T1
${FSLDIR}/bin/flirt -ref $FeatRegDir/$AnatomicalRef -in $DidiRegDir/$b0 -dof 6 -omat $DidiRegDir/dwi2struct.mat
RigidDwi2Ana=dwi2struct.mat

# Apply non-linear: DWI to MNI
${FSLDIR}/bin/applywarp --ref=/project/3011154.01/MJ/anatomical_std_template/template_avg_anat_asym_brain.nii.gz --in=$DidiRegDir/$b0 --warp=$FeatRegDir/$WarpAna2Std --premat=$DidiRegDir/$RigidDwi2Ana --out=$DidiRegDir/${b0}_norm



