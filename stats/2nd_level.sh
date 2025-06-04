#!/bin/bash

# Subtract first-level estimates of functional connectivity between session to get change over time

##QSUB
#list_subjects=(PS003 PS012 PS014 PS017 PS019 PS021 PS025 PS026 PS027 PS032 PS033 PS035 PS037 PS038 PS041 PS044 PS045 PS046 PS052 PS053 PS057 PS002 PS004 PS006 PS007 PS011 PS016 PS018 PS020 PS022 PS024 PS028 PS029 PS031 PS034 PS036 PS039 PS043 PS047 PS048 PS049 PS054 PS056 PS058 PS059 PS060); for s in ${list_subjects[@]}; do qsub -o /project/3011154.01/MJ/logs -e /project/3011154.01/MJ/logs -N 2nd_${s} -v subject=${s} -l 'walltime=00:10:00,mem=2gb' ~/scripts/ParkInShape/stats/2nd_level.sh; done

#subject=PS036

export FSLDIR=/opt/fsl/6.0.3
.  ${FSLDIR}/etc/fslconf/fsl.sh

junk=/project/3011154.01/MJ/junk
working=/project/3011154.01/MJ/FC
#working=/project/3011154.01/MJ/teststuff
cd ${working}

normalize=1
mask_stats=1
second_level=1

mkdir -p $(pwd)/higher_level/2nd_level/${subject}

# Specify whether you want 'cope' or 'zstat'
image=cope

session=(A B)

#----------------------------------------------------------#

# Normalise first level COPE images

if [ ${normalize} -eq 1 ]
then

session=(A B)
for ses in ${session[@]}; do

cd ${working}/${subject}${ses}

	for roi in {1..4}; do

#	${FSLDIR}/bin/applywarp \
#		-i $(pwd)/rs/stats/1st_level/1st_level.feat/stats/${image}${roi} \
#		-o $(pwd)/rs/stats/1st_level/${image}${roi}_std \
#		-r $(pwd)/rs/stats/1st_level/1st_level.feat/reg/standard \
#		-w $(pwd)/rs/stats/1st_level/1st_level.feat/reg/example_func2standard_warp
#	done

	${FSLDIR}/bin/applywarp \
		-i $(pwd)/rs/stats/1st_level/1st_level.feat/stats/${image}${roi} \
		-o $(pwd)/rs/stats/1st_level/${image}${roi}_std \
		-r /project/3024006.02/Users/marjoh/intermediate/${subject}${ses}.feat/reg/standard \
		-w /project/3024006.02/Users/marjoh/intermediate/${subject}${ses}.feat/reg/example_func2standard_warp
	done

cd ${working}

done

fi

#----------------------------------------------------------#

# Mask statistical images prior to subtraction (doesnt really matter when you do it, the result is the same before and after). I do it prior because I want to use the images for the grpmean script.

if [ ${mask_stats} -eq 1 ]
then

for ses in ${session[@]}; do

cd ${working}/${subject}${ses}

#mask=$(pwd)/rs/stats/1st_level/1st_level.feat/reg/standard
mask=/project/3024006.02/Users/marjoh/intermediate/${subject}${ses}.feat/reg/standard_mask

	for roi in {1..4}; do

	${FSLDIR}/bin/fslmaths \
		$(pwd)/rs/stats/1st_level/${image}${roi}_std \
		-mas \
		${mask} \
		$(pwd)/rs/stats/1st_level/${image}${roi}_std
	done

cd ${working}

done

fi

#----------------------------------------------------------#

# SECOND LEVEL

if [ ${second_level} -eq 1 ]
then

# Subtract the COPE image of session B from that of session A for each seed region
for roi in {1..4}; do

	cp $(pwd)/${subject}A/rs/stats/1st_level/${image}${roi}_std.nii.gz $(pwd)/higher_level/2nd_level/${subject}/${image}${roi}_std_A.nii.gz
	cp $(pwd)/${subject}B/rs/stats/1st_level/${image}${roi}_std.nii.gz $(pwd)/higher_level/2nd_level/${subject}/${image}${roi}_std_B.nii.gz

	${FSLDIR}/bin/fslmaths \
		$(pwd)/${subject}B/rs/stats/1st_level/${image}${roi}_std.nii.gz \
		-sub \
		$(pwd)/${subject}A/rs/stats/1st_level/${image}${roi}_std.nii.gz \
		$(pwd)/higher_level/2nd_level/${subject}/${image}${roi}_std_BsubA
done

# Subtract the difference between AP and PP of session A from that of session B
for ses in ${session[@]}; do
${FSLDIR}/bin/fslmaths \
	$(pwd)/${subject}${ses}/rs/stats/1st_level/${image}1_std.nii.gz \
	-sub \
	$(pwd)/${subject}${ses}/rs/stats/1st_level/${image}2_std.nii.gz \
	$(pwd)/${subject}${ses}/rs/stats/1st_level/${image}APsubPP_std

	cp $(pwd)/${subject}${ses}/rs/stats/1st_level/${image}APsubPP_std.nii.gz $(pwd)/higher_level/2nd_level/${subject}/${image}APsubPP_std_${ses}.nii.gz

done

${FSLDIR}/bin/fslmaths \
	$(pwd)/${subject}B/rs/stats/1st_level/${image}APsubPP_std \
	-sub \
	$(pwd)/${subject}A/rs/stats/1st_level/${image}APsubPP_std \
	$(pwd)/higher_level/2nd_level/${subject}/${image}APsubPP_std_BsubA

fi








