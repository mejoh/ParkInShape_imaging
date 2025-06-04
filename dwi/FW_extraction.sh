#!/bin/bash

root=/project/3011154.01/MJ/DWI/processed
FWdir=${root}/FW
FWNORMdir=${FWdir}/Normalised
STATSdir=${FWdir}/Stats
TMPdir=${FWdir}/tmp

Subjects=(PS002A PS002B PS003A PS003B)
#Subjects=(PS003A)

for i in ${Subjects[@]}; do

echo ${i}

sn_mask=${root}/${i}/b0/S0_norm_SNmask2
normalised_fw=${FWNORMdir}/${i}_FW_norm
#normalised_md=${root}/${i}/b0/MD_norm.nii.gz

#sn_mask=/project/3011154.01/MJ/DWI/processed/FW/tmp/${i}_b0_norm_SNmask.nii.gz
#normalised_fw=/project/3011154.01/MJ/DWI/processed/FW/tmp/${i}_FW_norm.nii.gz

	for n in {1..2}; do
	fslmaths ${sn_mask} -thr ${n} -uthr ${n} ${TMPdir}/mask${n}
	fslstats ${normalised_fw} -k ${TMPdir}/mask${n} -M -S
	done

done
