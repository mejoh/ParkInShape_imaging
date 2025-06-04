#!/bin/bash

# Create a mask that encompasses all overlapping voxels. Use it to mask statistical images before you test

start=$(pwd)
working=/project/3011154.01/MJ/FC

cd ${working}

create_mask=1

list_subjects=(PS002A PS003A PS004A PS006A PS007A PS011A PS012A PS014A PS016A PS017A PS018A PS019A PS020A PS021A PS022A PS024A PS025A PS026A PS027A PS028A PS029A PS031A PS032A PS033A PS034A PS035A PS036A PS037A PS038A PS039A PS041A PS043A PS044A PS045A PS046A PS047A PS048A PS049A PS052A PS053A PS054A PS056A PS057A PS058A PS059A PS060A PS002B PS003B PS004B PS006B PS007B PS011B PS012B PS014B PS016B PS017B PS018B PS019B PS020B PS021B PS022B PS024B PS025B PS026B PS027B PS028B PS029B PS031B PS032B PS033B PS034B PS035B PS036B PS037B PS038B PS039B PS041B PS043B PS044B PS045B PS046B PS047B PS048B PS049B PS052B PS053B PS054B PS056B PS057B PS058B PS059B PS060B)

# Create a mask

if [ ${create_mask} -eq 1 ]
then

${FSLDIR}/bin/fslmaths \
	/opt/fsl/5.0.11/data/standard/MNI152_T1_2mm_brain \
	-mul 0 \
	$(pwd)/higher_level/mask

for i in ${list_subjects[@]}; do
  ${FSLDIR}/bin/applywarp \
 	-r $(pwd)/${i}/rs/prepro.feat/reg/standard \
 	-i $(pwd)/${i}/rs/prepro.feat/mean_func \
 	-o $(pwd)/${i}/rs/prepro.feat/mean_func_std \
 	-w $(pwd)/${i}/rs/prepro.feat/reg/example_func2standard_warp

  ${FSLDIR}/bin/fslmaths \
	$(pwd)/${i}/rs/prepro.feat/mean_func_std \
	-bin \
	$(pwd)/${i}/rs/prepro.feat/mean_func_std

  ${FSLDIR}/bin/fslmaths \
	$(pwd)/higher_level/mask \
	-add \
	$(pwd)/${i}/rs/prepro.feat/mean_func_std \
	$(pwd)/higher_level/mask

done

nr_of_subs=`echo ${#list_subjects[@]}`

${FSLDIR}/bin/fslmaths \
	$(pwd)/higher_level/mask \
	-thr ${nr_of_subs} \
	-bin \
	$(pwd)/higher_level/mask_final

fi
