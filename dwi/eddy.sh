#!/bin/bash

##Qsub
#list_subjects=(PS033A); for s in ${list_subjects[@]}; do qsub -o /project/3011154.01/MJ/DWI/logs -e /project/3011154.01/MJ/DWI/logs -N eddy_${s} -v subject=${s} -l 'walltime=02:00:00,mem=4gb' ~/scripts/dwi/eddy.sh; done

#Subjects=(PS002A PS002B PS003A PS003B PS004A PS004B PS006A PS006B PS007A PS007B PS011A PS011B PS012A PS012B PS014A PS014B PS017A PS017B PS018A PS018B PS019A PS019B PS020A PS020B PS021A PS021B PS022A PS022B PS024A PS024B PS025A PS025B PS026A PS026B PS027A PS027B PS028A PS028B PS029A PS029B PS031A PS031B PS032A PS032B PS033A PS033B PS034A PS034B PS035A PS035B PS036A PS036B PS037A PS037B PS038A PS038B PS039A PS039B PS042A PS042B PS043A PS043B PS044A PS044B PS045A PS045B PS046A PS046B PS047A PS047B PS048A PS048B PS049A PS049B PS052A PS052B PS054A PS054B PS056A PS056B PS057A PS057B PS058A PS058B PS059A PS059B PS060A PS060B)

subject=PS033A

export FSLDIR=/opt/fsl/6.0.3
.  ${FSLDIR}/etc/fslconf/fsl.sh

## Directories
RAWDir=/project/3011154.01/MJ/DWI/raw/${subject}/0008
OUTDir=/project/3011154.01/MJ/DWI/processed/${subject}
RAWImg=`ls ${RAWDir}/0008*.nii.gz`
Mask=${OUTDir}/first_b0_brain_mask.nii.gz
Bvals=`ls ${RAWDir}/*.bval`
Bvecs=`ls ${RAWDir}/*.bvec`
Index=${OUTDir}/index.txt
Acqparam=${OUTDir}/acqparam.txt
EDDYData=${OUTDir}/data.eddy_outlier_free_data.nii.gz
mkdir -p ${OUTDir}


echo $RAWImg
## Extract first b0 image (volume 11)
${FSLDIR}/bin/fslroi \
${RAWImg} \
${OUTDir}/first_b0 \
0 \
1

## Mask
${FSLDIR}/bin/bet \
${OUTDir}/first_b0 \
${OUTDir}/first_b0_brain \
-m \
-n \
-f 0.2 \
-g 0.1

## Eddy: corrects for eddy-currents and motion

# Create index.txt file (we only have one image, so this file will just contain a row of ones)
# This file distinguishes different images (they need to be merged if you have more than 1)
indx=""
for ((i=1; i<=69; i+=1)); do indx="$indx 1"; done
echo $indx > ${Index}
# Create acqparams.txt file (specifies that the phase-encoding direction is along the y-axis)
# Last value is time between reading center of first echo and reading center of last echo. It's defined
# as 'dwell time' multiplied by 'number of PE steps - 1'. 
# Echo spacing: 0.62ms, EPI factor: 100, >>> 0.62*0.001*(100-1)=0.06138
# This file informs eddy what direction distortions are likely to go in. 
acqparam=""
echo "0 1 0 0.0614" > ${Acqparam}

${FSLDIR}/bin/eddy_openmp \
--imain=${RAWImg} \
--mask=${Mask} \
--bvals=${Bvals} \
--bvecs=${Bvecs} \
--acqp=${Acqparam} \
--index=${Index} \
--out=${OUTDir}/data \
--repol \
--verbose
#--estimate_move_by_susceptibility \

## DTIFIT: generates FA, MD etc. from eddy-corrected data
${FSLDIR}/bin/dtifit \
-k ${EDDYData} \
-o ${OUTDir}/dti \
-m ${Mask} \
-r ${Bvecs} \
-b ${Bvals} \
--verbose



## Command to be used for running eddy with GPU
#Slspec=${OUTDir}/slspec.txt
#${FSLDIR}/bin/eddy_openmp \
#--imain=${RAWImg} \
#--mask=${Mask} \
#--bvals=${Bvals} \
#--bvecs=${Bvecs} \
#--acqp=${Acqparam} \
#--index=${Index} \
#--out=${OUTDir}/data \
#--niter=8 \
#--fwhm=10,6,4,2,0,0,0,0 \
#--repol \
#--mporder=8 \
#--s2v_niter=8 \
#--slspec=${Slspec} \
#--verbose
