#!/bin/bash

#var_list=(moca-prog); for var in ${var_list[@]}; do qsub -e /project/3011154.01/MJ/AnnalsOfNeu_behav-corrs/voxelwise_correlations/logs -o /project/3011154.01/MJ/AnnalsOfNeu_behav-corrs/voxelwise_correlations/logs -N rand_${var} -v var=${var} -l 'walltime=03:00:00,mem=6gb' ~/scripts/ParkInShape/stats/exercise_brain_behav_corrs.sh; done

export FSLDIR=/opt/fsl/6.0.3
.  ${FSLDIR}/etc/fslconf/fsl.sh

#var=up3notrem-prog
img=RFPN

designdir=/project/3011154.01/MJ/AnnalsOfNeu_behav-corrs/designs
outputdir=/project/3011154.01/MJ/AnnalsOfNeu_behav-corrs/voxelwise_correlations
mkdir -p $outputdir/data

apsubppdat=/project/3011154.01/MJ/FC/higher_level/3rd_level/APsubPP_BsubA_merged.nii.gz
mkdir -p $outputdir/stats/APsubPP
ppdat=/project/3011154.01/MJ/FC/higher_level/3rd_level/2_BsubA_merged.nii.gz
mkdir -p $outputdir/stats/PP
rfpndat=/project/3024006.02/Users/marjoh/intermediate/groupICA/2nd_level/BsubA_ic0005.nii.gz
mkdir -p $outputdir/stats/RFPN

${FSLDIR}/bin/fslroi \
	$apsubppdat \
	$outputdir/data/ex_APsubPP \
	0 21
${FSLDIR}/bin/fslroi \
	$ppdat \
	$outputdir/data/ex_PP \
	0 21
${FSLDIR}/bin/fslroi \
	$rfpndat \
	$outputdir/data/ex_RFPN \
	0 21

if [ $img == APsubPP ]; then
	mask=/project/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun4_10-05-2021/SMN/results/APsubPP_up3ba-only/mask.nii.gz
elif [ $img == PP ]; then
	mask=/project/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun4_10-05-2021/SMN/results/2_up3ba-only/mask.nii.gz
elif [ $img == RFPN ]; then
	mask=/project/3024006.02/Users/marjoh/intermediate/groupICA/3rd_level/results/rfpn_BsubA/mask.nii.gz
fi

echo "Analyzing $var for image $img"
echo "Selecting mask: $mask"
echo "Running randomise..."

${FSLDIR}/bin/randomise \
	-i $outputdir/data/ex_$img \
	-o $outputdir/stats/$img/$var \
	-d $designdir/ex_$var.mat \
	-t $designdir/ex_$var.con \
	-m $mask \
	-n 5000 \
	-R \
	-T \
	--uncorrp

