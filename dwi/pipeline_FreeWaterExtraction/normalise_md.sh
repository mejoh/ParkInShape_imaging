#!/bin/bash

export FSLDIR=/opt/fsl/6.0.3
.  ${FSLDIR}/etc/fslconf/fsl.sh

#Subjects=(PS002A PS002B PS003A PS003B PS004A PS004B PS006A PS006B PS007A PS007B PS011A PS011B PS012A PS012B PS014A PS014B PS017A PS017B PS018A PS018B PS019A PS019B PS020A PS020B PS021A PS021B PS022A PS022B PS024A PS024B PS025A PS025B PS026A PS026B PS027A PS027B PS028A PS028B PS029A PS029B PS031A PS031B PS032A PS032B PS033A PS033B PS034A PS034B PS035A PS035B PS036A PS036B PS037A PS037B PS038A PS038B PS039A PS039B PS042A PS042B PS043A PS043B PS044A PS044B PS045A PS045B PS046A PS046B PS047A PS047B PS048A PS048B PS049A PS049B PS052A PS052B PS054A PS054B PS056A PS056B PS057A PS057B PS058A PS058B PS059A PS059B PS060A PS060B)
#Subjects=(PS030A PS055A PS010A PS023A PS040A PS051A PS041A PS053A)

Subjects=(PS042A PS042B)

for i in ${Subjects[@]}; do

  DidiDir=/project/3011154.01/MJ/DWI/didi/$i			# Subject specific Didi directory
  DidiRegDir=$DidiDir/reg2							# Subject specific registration directory
  FeatRegDir=/project/3024006.02/Users/marjoh/intermediate/$i.feat/reg	# Subject specific FEAT registration directory
  FreeWaterDir=/project/3011154.01/MJ/DWI/FreeWater

  AnatomicalRef=highres.nii.gz						# Betted T1
  WarpAna2Std=highres2standard_warp.nii.gz				# Non-linear transform: Ana-to-MNI
  RigidDwi2Ana=dwi2struct.mat
  #MeanDiff=ad_PATCH_pwLPCA_f*-0008-00001-000001-01
  MeanDiff=dtifit_MD
  MeanDiffOut=MD_norm2
  #FA=fa_PATCH_pwLPCA_f*-0008-00001-000001-01
  FA=dtifit_FA
  FAOut=FA_norm2

  #if [ -f $DidiDir/$MeanDiff.nii ]; then		# Compress MD image
  #  gzip $DidiDir/$MeanDiff.nii
  #fi
  #if [ -f $DidiDir/$FA.nii ]; then		# Compress FA image
  #  gzip $DidiDir/$FA.nii
  #fi

  # Estimate and Apply non-linear: DWI to MNI
  MeanDiff=`ls $DidiDir/FDT_Data/dtifit_MD*`
  MeanDiff=`basename $MeanDiff`
  ${FSLDIR}/bin/flirt -ref $FeatRegDir/$AnatomicalRef -in $DidiDir/FDT_Data/$MeanDiff -dof 6 -omat $DidiRegDir/md2struct.mat
  RigidDwi2Ana=md2struct.mat
  ${FSLDIR}/bin/applywarp --ref=/project/3011154.01/MJ/anatomical_std_template/template_avg_anat_asym_brain.nii.gz --in=$DidiDir/FDT_Data/$MeanDiff --warp=$FeatRegDir/$WarpAna2Std --premat=$DidiRegDir/$RigidDwi2Ana --out=$DidiRegDir/$MeanDiffOut

  FA=`ls $DidiDir/FDT_Data/dtifit_FA*`
  FA=`basename $FA`
  ${FSLDIR}/bin/flirt -ref $FeatRegDir/$AnatomicalRef -in $DidiDir/FDT_Data/$FA -dof 6 -omat $DidiRegDir/fa2struct.mat
  RigidDwi2Ana=fa2struct.mat
  ${FSLDIR}/bin/applywarp --ref=/project/3011154.01/MJ/anatomical_std_template/template_avg_anat_asym_brain.nii.gz --in=$DidiDir/FDT_Data/$FA --warp=$FeatRegDir/$WarpAna2Std --premat=$DidiRegDir/$RigidDwi2Ana --out=$DidiRegDir/$FAOut

done



