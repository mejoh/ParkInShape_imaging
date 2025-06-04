#!/bin/bash

# Description
# Generate mean image for all participants and for each group
# Mean images of interest: b0, FA, MD, FW

# 12, 28, 34 excluded due to motion

#participants=(PS002A PS002B PS003A PS003B PS004A PS004B PS006A PS006B PS007A PS007B PS011A PS011B PS014A PS014B PS017A PS017B PS018A PS018B PS019A PS019B PS020A PS020B PS021A PS021B PS022A PS022B PS024A PS024B PS025A PS025B PS026A PS026B PS027A PS027B PS029A PS029B PS031A PS031B PS032A PS032B PS033A PS033B PS035A PS035B PS036A PS036B PS037A PS037B PS038A PS038B PS039A PS039B PS042A PS042B PS043A PS043B PS044A PS044B PS045A PS045B PS046A PS046B PS047A PS047B PS048A PS048B PS049A PS049B PS052A PS052B PS054A PS054B PS056A PS056B PS057A PS057B PS058A PS058B PS059A PS059B PS060A PS060B)
#control=(PS002A PS002B PS004A PS004B PS006A PS006B PS007A PS007B PS011A PS011B PS018A PS018B PS020A PS020B PS022A PS022B PS024A PS024B PS029A PS029B PS031A PS031B PS036A PS036B PS039A PS039B PS042A PS042B PS043A PS043B PS047A PS047B PS048A PS048B PS049A PS049B PS054A PS054B PS056A PS056B PS058A PS058B PS059A PS059B PS060A PS060B)
#exercise=(PS003A PS003B PS014A PS014B PS017A PS017B PS019A PS019B PS021A PS021B PS025A PS025B PS026A PS026B PS027A PS027B PS032A PS032B PS033A PS033B PS035A PS035B PS037A PS037B PS038A PS038B PS044A PS044B PS045A PS045B PS046A PS046B PS052A PS052B PS057A PS057B)

participants=(PS002A PS004A PS006A PS007A PS011A PS018A PS020A PS022A PS024A PS029A PS031A PS036A PS039A PS042A PS043A PS047A PS048A PS049A PS054A PS056A PS058A PS059A PS060A PS003A PS014A PS017A PS019A PS021A PS025A PS026A PS027A PS032A PS033A PS035A PS037A PS038A PS044A PS045A PS046A PS052A PS057A PS002B PS004B PS006B PS007B PS011B PS018B PS020B PS022B PS024B PS029B PS031B PS036B PS039B PS042B PS043B PS047B PS048B PS049B PS054B PS056B PS058B PS059B PS060B PS003B PS014B PS017B PS019B PS021B PS025B PS026B PS027B PS032B PS033B PS035B PS037B PS038B PS044B PS045B PS046B PS052B PS057B)
control=(PS002A PS004A PS006A PS007A PS011A PS018A PS020A PS022A PS024A PS029A PS031A PS036A PS039A PS042A PS043A PS047A PS048A PS049A PS054A PS056A PS058A PS059A PS060A PS002B PS004B PS006B PS007B PS011B PS018B PS020B PS022B PS024B PS029B PS031B PS036B PS039B PS042B PS043B PS047B PS048B PS049B PS054B PS056B PS058B PS059B PS060B)
exercise=(PS003A PS014A PS017A PS019A PS021A PS025A PS026A PS027A PS032A PS033A PS035A PS037A PS038A PS044A PS045A PS046A PS052A PS057A PS003B PS014B PS017B PS019B PS021B PS025B PS026B PS027B PS032B PS033B PS035B PS037B PS038B PS044B PS045B PS046B PS052B PS057B)


root=/project/3011154.01/MJ/DWI			# Root directory
DidiDir=$root/didi				# Preprocessing directory
FreewaterDir=$root/FreeWater

MeanImageDir=$root/MeanImages			# Directory where mean images are stored

### ALL PARTICIPANTS ###

MDImageList=()					# Lists that will contain filepaths for images
FAImageList=()
b0ImageList=()
FWImageList=()
SNAntMaskList=()
SNPostMaskList=()

for i in ${participants[@]}; do			# Fill lists with filepaths

 MDImg=`ls $DidiDir/$i/reg/MD_norm.nii.gz`
 MDImageList+=( $MDImg )

 FAImg=`ls $DidiDir/$i/reg/FA_norm.nii.gz`
 FAImageList+=( $FAImg )

 b0Img=`ls $DidiDir/$i/reg/b0_mean_brain_norm.nii.gz`
 b0ImageList+=( $b0Img )

 FWImg=`ls $FreewaterDir/${i}_FW_fixed_norm.nii.gz`
 FWImageList+=( $FWImg )

 SNAnt=`ls $DidiDir/$i/reg/SNmaskAnt.nii.gz`
 SNAntMaskList+=( $SNAnt )

 SNPost=`ls $DidiDir/$i/reg/SNmaskPost.nii.gz`
 SNPostMaskList+=( $SNPost )

done

fslmaths $SNAntMaskList -mul 0 $MeanImageDir/Ant_all
for t in ${SNAntMaskList[@]}; do
 fslmaths $MeanImageDir/Ant_all -add $t $MeanImageDir/Ant_all
done

fslmaths $SNPostMaskList -mul 0 $MeanImageDir/Post_all
for t in ${SNPostMaskList[@]}; do
 fslmaths $MeanImageDir/Post_all -add $t $MeanImageDir/Post_all
done

fslmerge -t $MeanImageDir/MD_all `echo ${MDImageList[@]}`
fslmaths $MeanImageDir/MD_all -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/MD_all_mean
fslroi $MeanImageDir/MD_all $MeanImageDir/MD_all_t1 0 41
fslmaths $MeanImageDir/MD_all_t1 -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/MD_all_t1_mean
fslroi $MeanImageDir/MD_all $MeanImageDir/MD_all_t2 41 41
fslmaths $MeanImageDir/MD_all_t2 -sub $MeanImageDir/MD_all_t1 -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/MD_all_t2-t1_mean
fslmaths $MeanImageDir/MD_all_t2 -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/MD_all_t2_mean

fslmerge -t $MeanImageDir/FA_all `echo ${FAImageList[@]}`
fslmaths $MeanImageDir/FA_all -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/FA_all_mean
fslroi $MeanImageDir/FA_all $MeanImageDir/FA_all_t1 0 41
fslmaths $MeanImageDir/FA_all_t1 -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/FA_all_t1_mean
fslroi $MeanImageDir/FA_all $MeanImageDir/FA_all_t2 41 41
fslmaths $MeanImageDir/FA_all_t2 -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/FA_all_t2_mean
fslmaths $MeanImageDir/FA_all_t2 -sub $MeanImageDir/FA_all_t1 -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/FA_all_t2-t1_mean

fslmerge -t $MeanImageDir/b0_all `echo ${b0ImageList[@]}`
fslmaths $MeanImageDir/b0_all -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/b0_all_mean
fslroi $MeanImageDir/b0_all $MeanImageDir/b0_all_t1 0 41
fslmaths $MeanImageDir/b0_all_t1 -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/b0_all_t1_mean
fslroi $MeanImageDir/b0_all $MeanImageDir/b0_all_t2 41 41
fslmaths $MeanImageDir/b0_all_t2 -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/b0_all_t2_mean
fslmaths $MeanImageDir/b0_all_t2 -sub $MeanImageDir/b0_all_t1 -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/b0_all_t2-t1_mean

fslmerge -t $MeanImageDir/FW_all `echo ${FWImageList[@]}`
fslmaths $MeanImageDir/FW_all -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/FW_all_mean
fslroi $MeanImageDir/FW_all $MeanImageDir/FW_all_t1 0 41
fslmaths $MeanImageDir/FW_all_t1 -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/FW_all_t1_mean
fslroi $MeanImageDir/FW_all $MeanImageDir/FW_all_t2 41 41
fslmaths $MeanImageDir/FW_all_t2 -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/FW_all_t2_mean
fslmaths $MeanImageDir/FW_all_t2 -sub $MeanImageDir/FW_all_t1 -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/FW_all_t2-t1_mean

### CONTROLS ###

MDImageList=()					# Lists that will contain filepaths for images
FAImageList=()
b0ImageList=()
FWImageList=()
SNAntMaskList=()
SNPostMaskList=()

for i in ${control[@]}; do			# Fill lists with filepaths

 MDImg=`ls $DidiDir/$i/reg/MD_norm.nii.gz`
 MDImageList+=( $MDImg )

 FAImg=`ls $DidiDir/$i/reg/FA_norm.nii.gz`
 FAImageList+=( $FAImg )

 b0Img=`ls $DidiDir/$i/reg/b0_mean_brain_norm.nii.gz`
 b0ImageList+=( $b0Img )

 FWImg=`ls $FreewaterDir/${i}_FW_fixed_norm.nii.gz`
 FWImageList+=( $FWImg )

 SNAnt=`ls $DidiDir/$i/reg/SNmaskAnt.nii.gz`
 SNAntMaskList+=( $SNAnt )

 SNPost=`ls $DidiDir/$i/reg/SNmaskPost.nii.gz`
 SNPostMaskList+=( $SNPost )

done

fslmaths $SNAntMaskList -mul 0 $MeanImageDir/Ant_con
for t in ${SNAntMaskList[@]}; do
 fslmaths $MeanImageDir/Ant_con -add $t $MeanImageDir/Ant_con
done

fslmaths $SNPostMaskList -mul 0 $MeanImageDir/Post_con
for t in ${SNPostMaskList[@]}; do
 fslmaths $MeanImageDir/Post_con -add $t $MeanImageDir/Post_con
done

fslmerge -t $MeanImageDir/MD_con `echo ${MDImageList[@]}`
fslmaths $MeanImageDir/MD_con -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/MD_con_mean
fslroi $MeanImageDir/MD_con $MeanImageDir/MD_con_t1 0 23
fslmaths $MeanImageDir/MD_con_t1 -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/MD_con_t1_mean
fslroi $MeanImageDir/MD_con $MeanImageDir/MD_con_t2 23 23
fslmaths $MeanImageDir/MD_con_t2 -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/MD_con_t2_mean
fslmaths $MeanImageDir/MD_con_t2 -sub $MeanImageDir/MD_con_t1 -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/MD_con_t2-t1_mean

fslmerge -t $MeanImageDir/FA_con `echo ${FAImageList[@]}`
fslmaths $MeanImageDir/FA_con -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/FA_con_mean
fslroi $MeanImageDir/FA_con $MeanImageDir/FA_con_t1 0 23
fslmaths $MeanImageDir/FA_con_t1 -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/FA_con_t1_mean
fslroi $MeanImageDir/FA_con $MeanImageDir/FA_con_t2 23 23
fslmaths $MeanImageDir/FA_con_t2 -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/FA_con_t2_mean
fslmaths $MeanImageDir/FA_con_t2 -sub $MeanImageDir/FA_con_t1 -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/FA_con_t2-t1_mean

fslmerge -t $MeanImageDir/b0_con `echo ${b0ImageList[@]}`
fslmaths $MeanImageDir/b0_con -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/b0_con_mean
fslroi $MeanImageDir/b0_con $MeanImageDir/b0_con_t1 0 23
fslmaths $MeanImageDir/b0_con_t1 -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/b0_con_t1_mean
fslroi $MeanImageDir/b0_con $MeanImageDir/b0_con_t2 23 23
fslmaths $MeanImageDir/b0_con_t2 -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/b0_con_t2_mean
fslmaths $MeanImageDir/b0_con_t2 -sub $MeanImageDir/b0_con_t1 -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/b0_con_t2-t1_mean

fslmerge -t $MeanImageDir/FW_con `echo ${FWImageList[@]}`
fslmaths $MeanImageDir/FW_con -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/FW_con_mean
fslroi $MeanImageDir/FW_con $MeanImageDir/FW_con_t1 0 23
fslmaths $MeanImageDir/FW_con_t1 -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/FW_con_t1_mean
fslroi $MeanImageDir/FW_con $MeanImageDir/FW_con_t2 23 23
fslmaths $MeanImageDir/FW_con_t2 -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/FW_con_t2_mean
fslmaths $MeanImageDir/FW_con_t2 -sub $MeanImageDir/FW_con_t1 -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/FW_con_t2-t1_mean

### EXERCISE ###

MDImageList=()					# Lists that will contain filepaths for images
FAImageList=()
b0ImageList=()
FWImageList=()
SNAntMaskList=()
SNPostMaskList=()

for i in ${exercise[@]}; do			# Fill lists with filepaths

 MDImg=`ls $DidiDir/$i/reg/MD_norm.nii.gz`
 MDImageList+=( $MDImg )

 FAImg=`ls $DidiDir/$i/reg/FA_norm.nii.gz`
 FAImageList+=( $FAImg )

 b0Img=`ls $DidiDir/$i/reg/b0_mean_brain_norm.nii.gz`
 b0ImageList+=( $b0Img )

 FWImg=`ls $FreewaterDir/${i}_FW_fixed_norm.nii.gz`
 FWImageList+=( $FWImg )

 SNAnt=`ls $DidiDir/$i/reg/SNmaskAnt.nii.gz`
 SNAntMaskList+=( $SNAnt )

 SNPost=`ls $DidiDir/$i/reg/SNmaskPost.nii.gz`
 SNPostMaskList+=( $SNPost )

done

fslmaths $SNAntMaskList -mul 0 $MeanImageDir/Ant_ex
for t in ${SNAntMaskList[@]}; do
 fslmaths $MeanImageDir/Ant_ex -add $t $MeanImageDir/Ant_ex
done

fslmaths $SNPostMaskList -mul 0 $MeanImageDir/Post_ex
for t in ${SNPostMaskList[@]}; do
 fslmaths $MeanImageDir/Post_ex -add $t $MeanImageDir/Post_ex
done

fslmerge -t $MeanImageDir/MD_ex `echo ${MDImageList[@]}`
fslmaths $MeanImageDir/MD_ex -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/MD_ex_mean
fslroi $MeanImageDir/MD_ex $MeanImageDir/MD_ex_t1 0 18
fslmaths $MeanImageDir/MD_ex_t1 -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/MD_ex_t1_mean
fslroi $MeanImageDir/MD_ex $MeanImageDir/MD_ex_t2 18 18
fslmaths $MeanImageDir/MD_ex_t2 -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/MD_ex_t2_mean
fslmaths $MeanImageDir/MD_ex_t2 -sub $MeanImageDir/MD_ex_t1 -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/MD_ex_t2-t1_mean

fslmerge -t $MeanImageDir/FA_ex `echo ${FAImageList[@]}`
fslmaths $MeanImageDir/FA_ex -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/FA_ex_mean
fslroi $MeanImageDir/FA_ex $MeanImageDir/FA_ex_t1 0 18
fslmaths $MeanImageDir/FA_ex_t1 -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/FA_ex_t1_mean
fslroi $MeanImageDir/FA_ex $MeanImageDir/FA_ex_t2 18 18
fslmaths $MeanImageDir/FA_ex_t2 -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/FA_ex_t2_mean
fslmaths $MeanImageDir/FA_ex_t2 -sub $MeanImageDir/FA_ex_t1 -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/FA_ex_t2-t1_mean

fslmerge -t $MeanImageDir/b0_ex `echo ${b0ImageList[@]}`
fslmaths $MeanImageDir/b0_ex -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/b0_ex_mean
fslroi $MeanImageDir/b0_ex $MeanImageDir/b0_ex_t1 0 18
fslmaths $MeanImageDir/b0_ex_t1 -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/b0_ex_t1_mean
fslroi $MeanImageDir/b0_ex $MeanImageDir/b0_ex_t2 18 18
fslmaths $MeanImageDir/b0_ex_t2 -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/b0_ex_t2_mean
fslmaths $MeanImageDir/b0_ex_t2 -sub $MeanImageDir/b0_ex_t1 -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/b0_ex_t2-t1_mean

fslmerge -t $MeanImageDir/FW_ex `echo ${FWImageList[@]}`
fslmaths $MeanImageDir/FW_ex -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/FW_ex_mean
fslroi $MeanImageDir/FW_ex $MeanImageDir/FW_ex_t1 0 18
fslmaths $MeanImageDir/FW_ex_t1 -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/FW_ex_t1_mean
fslroi $MeanImageDir/FW_ex $MeanImageDir/FW_ex_t2 18 18
fslmaths $MeanImageDir/FW_ex_t2 -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/FW_ex_t2_mean
fslmaths $MeanImageDir/FW_ex_t2 -sub $MeanImageDir/FW_ex_t1 -Tmean -mul /opt/fsl/6.0.1/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz $MeanImageDir/FW_ex_t2-t1_mean


