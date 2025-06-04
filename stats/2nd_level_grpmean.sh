#!/bin/bash

#

##QSUB
#roi_list=(1 2 3 4 5); for s in ${roi_list[@]}; do qsub -e /project/3011154.01/MJ/logs -o /project/3011154.01/MJ/logs -N 2ndgrpmean_${s} -v roi=${s} -l 'walltime=04:00:00,mem=8gb' /project/3011154.01/MJ/scripts/stats/2nd_level_grpmean.sh; done

export FSLDIR=/opt/fsl/5.0.11
.  ${FSLDIR}/etc/fslconf/fsl.sh

junk=/project/3011154.01/MJ/junk
working=/project/3011154.01/MJ/FC

cd ${working}

registration=1
merge=0
randomise=0

mkdir -p higher_level/2nd_level/randomise_grpmean

list_subjects=(PS003A PS012A PS014A PS017A PS019A PS021A PS025A PS026A PS027A PS032A PS033A PS035A PS037A PS038A PS041A PS044A PS045A PS046A PS052A PS053A PS057A PS002A PS004A PS006A PS007A PS011A PS016A PS018A PS020A PS022A PS024A PS028A PS029A PS031A PS034A PS036A PS039A PS043A PS047A PS048A PS049A PS054A PS056A PS058A PS059A PS060A PS003B PS012B PS014B PS017B PS019B PS021B PS025B PS026B PS027B PS032B PS033B PS035B PS037B PS038B PS041B PS044B PS045B PS046B PS052B PS053B PS057B PS002B PS004B PS006B PS007B PS011B PS016B PS018B PS020B PS022B PS024B PS028B PS029B PS031B PS034B PS036B PS039B PS043B PS047B PS048B PS049B PS054B PS056B PS058B PS059B PS060B)

# Specify whether you want 'cope' or 'zstat'
image=zstat

# Non-linearly register zstat images to MNI152 space

if [ ${registration} -eq 1 ]
then

for s in ${list_subjects[@]}; do
  cd ${s}

  ${FSLDIR}/bin/applywarp \
	-i $(pwd)/rs/stats/1st_level/1st_level.feat/stats/${image}${roi} \
	-o $(pwd)/rs/stats/1st_level/${image}${roi}_std \
	-r $(pwd)/rs/stats/1st_level/1st_level.feat/reg/standard \
	-w $(pwd)/rs/stats/1st_level/1st_level.feat/reg/example_func2standard_warp

cd ${working}

done


fi

# Merge the COPE images for all participants separately for each seed
# PS042B is not included due to excessive motion

if [ ${merge} -eq 1 ]
then

${FSLDIR}/bin/fslmerge \
 	-t \
 	$(pwd)/higher_level/2nd_level/merged_seed${roi} \
 	$(pwd)/PS002B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS003B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS004B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS006B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS007B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS011B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS012B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS014B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS016B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS017B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS018B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS019B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS020B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS021B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS022B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS024B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS025B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS026B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS027B/rs/stats/1st_level/${image}${roi}_std \
	$(pwd)/PS028B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS029B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS031B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS032B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS033B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS034B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS035B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS036B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS037B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS038B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS039B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS041B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS043B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS044B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS045B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS046B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS047B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS048B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS049B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS052B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS053B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS054B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS056B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS057B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS058B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS059B/rs/stats/1st_level/${image}${roi}_std \
 	$(pwd)/PS060B/rs/stats/1st_level/${image}${roi}_std

#     SETTINGS FOR SEPARATE GROUP MEANS BELOW

# Set t to which session you want
#t=B
# Exercise
#${FSLDIR}/bin/fslmerge \
#	-t \
 #	$(pwd)/higher_level/2nd_level/merged_seed${roi} \
#	$(pwd)/PS003${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS012${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS014${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS017${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS019${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS021${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS025${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS026${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS027${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS032${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS033${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS035${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS037${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS038${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS041${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS044${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS045${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS046${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS052${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS053${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS057${t}/rs/stats/1st_level/${image}${roi}_std 

# Stretch
#${FSLDIR}/bin/fslmerge \
#	-t \
 #	$(pwd)/higher_level/2nd_level/merged_seed${roi} \
#	$(pwd)/PS002${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS004${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS006${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS007${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS011${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS016${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS018${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS020${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS022${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS024${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS028${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS029${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS031${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS034${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS036${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS039${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS043${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS047${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS048${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS049${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS054${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS056${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS058${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS059${t}/rs/stats/1st_level/${image}${roi}_std \
#	$(pwd)/PS060${t}/rs/stats/1st_level/${image}${roi}_std

fi

# Non-parametric one-sample t-test with TFCE thresholding. No design matrix needed, randomise recognizes that there is only one sample with the -1 option
# Change -T to -x or -c 3.1 if you want randomise to build distribution from max t or max cluster size

if [ ${randomise} -eq 1 ]
then

${FSLDIR}/bin/randomise \
 	-i $(pwd)/higher_level/2nd_level/merged_seed${roi} \
 	-o $(pwd)/higher_level/2nd_level/randomise_grpmean/randomise_seed${roi} \
	-m $(pwd)/higher_level/mask_final \
	-n 5000 \
 	-1 \
	-R \
 	-T \
	--uncorrp

fi

