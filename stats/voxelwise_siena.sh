#!/bin/bash

#qsub -o /project/3024006.02/ParkInShape_siena/stats/logs -e /project/3024006.02/ParkInShape_siena/stats/logs -N long_vbm -l 'walltime=20:00:00,mem=8gb' ~/scripts/ParkInShape/stats/voxelwise_siena.sh

cd /project/3024006.02/ParkInShape_siena
mkdir -p stats/data

merged=$(pwd)/stats/data/A_to_B_flow_to_std_merged
${FSLDIR}/bin/fslmerge \
	-t \
	${merged} \
	$(pwd)/PS003A_ana2_to_PS003B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS012A_ana2_to_PS012B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS014A_ana2_to_PS014B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS017A_ana2_to_PS017B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS019A_ana2_to_PS019B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS021A_ana2_to_PS021B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS025A_ana2_to_PS025B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS026A_ana2_to_PS026B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS027A_ana2_to_PS027B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS032A_ana2_to_PS032B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS033A_ana2_to_PS033B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS035A_ana2_to_PS035B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS037A_ana2_to_PS037B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS038A_ana2_to_PS038B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS041A_ana2_to_PS041B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS044A_ana2_to_PS044B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS045A_ana2_to_PS045B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS046A_ana2_to_PS046B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS052A_ana2_to_PS052B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS053A_ana2_to_PS053B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS057A_ana2_to_PS057B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS002A_ana2_to_PS002B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS004A_ana2_to_PS004B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS006A_ana2_to_PS006B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS007A_ana2_to_PS007B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS011A_ana2_to_PS011B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS016A_ana2_to_PS016B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS018A_ana2_to_PS018B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS020A_ana2_to_PS020B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS022A_ana2_to_PS022B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS024A_ana2_to_PS024B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS028A_ana2_to_PS028B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS029A_ana2_to_PS029B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS031A_ana2_to_PS031B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS034A_ana2_to_PS034B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS036A_ana2_to_PS036B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS039A_ana2_to_PS039B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS043A_ana2_to_PS043B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS047A_ana2_to_PS047B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS048A_ana2_to_PS048B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS049A_ana2_to_PS049B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS054A_ana2_to_PS054B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS056A_ana2_to_PS056B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS058A_ana2_to_PS058B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS059A_ana2_to_PS059B_ana2_siena/A_to_B_flow_to_std.nii.gz \
	$(pwd)/PS060A_ana2_to_PS060B_ana2_siena/A_to_B_flow_to_std.nii.gz

up3ba=up3ba-only
${FSLDIR}/bin/randomise \
	-i ${merged} \
	-o stats/A_to_B_flow_${up3ba} \
	-d /project/3011154.01/MJ/FC/designs/statistics/3rd_level/3rd_level_cov_up3ba-only.mat \
	-t /project/3011154.01/MJ/FC/designs/statistics/3rd_level/3rd_level_cov_up3ba-only.con \
	-f /project/3011154.01/MJ/FC/designs/statistics/3rd_level/3rd_level_cov_up3ba-only.fts \
	-m ${FSLDIR}/data/standard/MNI152_T1_2mm_edges \
	-n 5000 \
	-R \
	-T \
	--uncorrp
