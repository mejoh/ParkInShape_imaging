#!/bin/bash

export FSLDIR=/opt/fsl/6.0.1
.  ${FSLDIR}/etc/fslconf/fsl.sh

root=/project/3011154.01/MJ/FC
sessions=(A B)
roi=APsubPP

for s in ${sessions[@]}; do

	${FSLDIR}/bin/fslmerge \
		-t \
		/project/3011154.01/MJ/AnnalsOfNeu_behav-corrs/fc/APsubPP/data/${roi}_${s}_merged \
		$root/PS003${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS012${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS014${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS017${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS019${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS021${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS025${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS026${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS027${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS032${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS033${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS035${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS037${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS038${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS041${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS044${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS045${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS046${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS052${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS053${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS057${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS002${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS004${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS006${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS007${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS011${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS016${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS018${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS020${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS022${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS024${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS028${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS029${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS031${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS034${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS036${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS039${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS043${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS047${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS048${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS049${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS054${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS056${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS058${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS059${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz \
		$root/PS060${s}/rs/stats/1st_level/zstat${roi}_std.nii.gz

done

root=/project/3011154.01/MJ/FC
image=zstat
roi=APsubPP

${FSLDIR}/bin/fslmerge \
	-t \
	/project/3011154.01/MJ/AnnalsOfNeu_behav-corrs/fc/APsubPP/data/${roi}_BsubA_merged \
	$root/higher_level/2nd_level/PS003/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS012/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS014/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS017/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS019/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS021/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS025/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS026/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS027/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS032/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS033/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS035/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS037/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS038/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS041/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS044/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS045/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS046/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS052/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS053/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS057/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS002/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS004/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS006/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS007/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS011/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS016/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS018/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS020/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS022/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS024/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS028/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS029/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS031/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS034/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS036/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS039/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS043/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS047/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS048/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS049/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS054/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS056/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS058/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS059/${image}${roi}_std_BsubA \
	$root/higher_level/2nd_level/PS060/${image}${roi}_std_BsubA

for s in ${sessions[@]}; do

${FSLDIR}/bin/fslroi \
  /project/3011154.01/MJ/AnnalsOfNeu_behav-corrs/fc/APsubPP/data/${roi}_${s}_merged \
  /project/3011154.01/MJ/AnnalsOfNeu_behav-corrs/fc/APsubPP/data/${roi}_${s}_exercise \
  0 21
${FSLDIR}/bin/fslroi \
  /project/3011154.01/MJ/AnnalsOfNeu_behav-corrs/fc/APsubPP/data/${roi}_${s}_merged \
  /project/3011154.01/MJ/AnnalsOfNeu_behav-corrs/fc/APsubPP/data/${roi}_${s}_stretch \
  21 -1

done

${FSLDIR}/bin/fslroi \
  /project/3011154.01/MJ/AnnalsOfNeu_behav-corrs/fc/APsubPP/data/${roi}_BsubA_merged \
  /project/3011154.01/MJ/AnnalsOfNeu_behav-corrs/fc/APsubPP/data/${roi}_BsubA_exercise \
  0 21
${FSLDIR}/bin/fslroi \
  /project/3011154.01/MJ/AnnalsOfNeu_behav-corrs/fc/APsubPP/data/${roi}_BsubA_merged \
  /project/3011154.01/MJ/AnnalsOfNeu_behav-corrs/fc/APsubPP/data/${roi}_BsubA_stretch \
  21 -1



