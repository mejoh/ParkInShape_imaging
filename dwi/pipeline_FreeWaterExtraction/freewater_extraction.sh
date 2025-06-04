#!/bin/bash

#Subjects=(PS002 PS003 PS004 PS006 PS007 PS011 PS012 PS014 PS017 PS018 PS019 PS020 PS021 PS022 PS024 PS025 PS026 PS027 PS028 PS029 PS031 PS032 PS033 PS034 PS035 PS036 PS037 PS038 PS039 PS042 PS043 PS044 PS045 PS046 PS047 PS048 PS049 PS052 PS054 PS056 PS057 PS058 PS059 PS060)
Subjects=(PS002 PS003 PS004 PS006 PS007 PS010 PS011 PS012 PS014 PS017 PS018 PS019 PS020 PS021 PS022 PS023 PS024 PS025 PS026 PS027 PS028 PS029 PS030 PS031 PS032 PS033 PS034 PS035 PS036 PS037 PS038 PS039 PS040 PS041 PS042 PS043 PS044 PS045 PS046 PS047 PS048 PS049 PS051 PS052 PS053 PS054 PS055 PS056 PS057 PS058 PS059 PS060)
Sessions=(A B)

FreewaterDir=/project/3011154.01/MJ/DWI/FreeWater		# Directory where FW image is stored
FreewaterValuesTxt=FreewaterValues3.txt
MeanDiffValuesTxt=MeanDiffValues3.txt

if [ -f "$FreewaterDir/$FreewaterValuesTxt" ]; then		# Generate text document
  rm $FreewaterDir/$FreewaterValuesTxt
  rm $FreewaterDir/$MeanDiffValuesTxt
  touch $FreewaterDir/$FreewaterValuesTxt
  touch $FreewaterDir/$MeanDiffValuesTxt
else
  touch $FreewaterDir/$FreewaterValuesTxt
  touch $FreewaterDir/$MeanDiffValuesTxt
fi
echo "Subject t1Ant t1Post t1RAnt t1LAnt t1RPost t1LPost t2Ant t2Post t2RAnt t2LAnt t2RPost t2LPost" >> $FreewaterDir/$FreewaterValuesTxt  # Write headers (subjects, masks)
echo "Subject t1Ant t1Post t1RAnt t1LAnt t1RPost t1LPost t2Ant t2Post t2RAnt t2LAnt t2RPost t2LPost" >> $FreewaterDir/$MeanDiffValuesTxt

for i in ${Subjects[@]}; do					# Create SN masks for each subject's two sessions and print to file
  for t in ${Sessions[@]}; do

  DidiRegDir=/project/3011154.01/MJ/DWI/didi/${i}${t}/reg	# Directory where SN mask is stored
  if [ ! -d "$DidiRegDir" ]; then
    echo "$DidiRegDir not found"
    break
  fi

  SubNigMask=b0_mean_brain_norm_SNmask.nii.gz			# Name of SN mask
  FreewaterImg=${i}${t}_FW_fixed_norm2.nii.gz			# Name of FW image
  MeanDiffImg=MD_norm

  Ant=SNmaskAnt.nii.gz 						# Names of different SN sub-masks
  Post=SNmaskPost.nii.gz
  RAnt=SNmaskAntR.nii.gz
  LAnt=SNmaskAntL.nii.gz
  RPost=SNmaskPostR.nii.gz
  LPost=SNmaskPostL.nii.gz
  MaskList=($Ant $Post $RAnt $LAnt $RPost $LPost)

  fslmaths $DidiRegDir/$SubNigMask -thr 1 -uthr 2 -bin $DidiRegDir/$Ant		# Non-lateralized masks
  fslmaths $DidiRegDir/$SubNigMask -thr 3 -uthr 4 -bin $DidiRegDir/$Post

  fslmaths $DidiRegDir/$SubNigMask -thr 1 -uthr 1 -bin $DidiRegDir/$RAnt	        # Lateralized masks, used for checks
  fslmaths $DidiRegDir/$SubNigMask -thr 2 -uthr 2 -bin $DidiRegDir/$LAnt
  fslmaths $DidiRegDir/$SubNigMask -thr 3 -uthr 3 -bin $DidiRegDir/$RPost
  fslmaths $DidiRegDir/$SubNigMask -thr 4 -uthr 4 -bin $DidiRegDir/$LPost

  done
done

for i in ${Subjects[@]}; do					# Extract FW values for each subject's two sessions and print to file
  
  DidiDir=/project/3011154.01/MJ/DWI/didi/${i}			# Directory to subjects didi directory
  FreewaterValues=()						# Set empty vector to hold FW values
  MeanDiffValues=()

  for t in ${Sessions[@]}; do

#    if [ -d "$DidiDir" ]; then

      RegExt=${t}/reg						# Extension used to access registration-folder in subjects didi directory
      FreewaterImg=${i}${t}_FW_fixed_norm2.nii.gz			# Name of FW image
      for s in ${MaskList[@]}; do								# Extract FW for each mask, store in vector
        FreewaterValues+=( `fslstats $FreewaterDir/$FreewaterImg -k ${DidiDir}${RegExt}/$s -M` )
      done

      MeanDiffImg=MD_norm
      for s in ${MaskList[@]}; do								# Extract MD for each mask, store in array
        MeanDiffValues+=( `fslstats ${DidiDir}${RegExt}/$MeanDiffImg -k ${DidiDir}${RegExt}/$s -M` )
      done

#    else

      #FreewaterValues+=("NA" "NA" "NA" "NA" "NA" "NA")
      #MeanDiffValues+=("NA" "NA" "NA" "NA" "NA" "NA")

#    fi

  done

  echo -n $i' ' >> $FreewaterDir/$FreewaterValuesTxt					# Print FW values to txt file
  echo ${FreewaterValues[@]} >> $FreewaterDir/$FreewaterValuesTxt

  echo -n $i' ' >> $FreewaterDir/$MeanDiffValuesTxt					# Print MD values to txt file
  echo ${MeanDiffValues[@]} >> $FreewaterDir/$MeanDiffValuesTxt

done
