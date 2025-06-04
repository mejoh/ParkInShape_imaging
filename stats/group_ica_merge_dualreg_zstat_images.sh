#!/bin/bash

sessions=(A B)
for t in ${sessions[@]}; do

  cd /project/3024006.02/Users/marjoh/intermediate/groupICA/dual_reg/$t
  rm -r merged_Z
  mkdir -p merged_Z

  component=(0000 0001 0002 0003 0004 0005 0006 0007 0008 0009 0010 0011 0012 0013 0014 0015 0016 0017 0018 0019)

  for y in ${component[@]}; do

    for i in {00..45}; do

	    input=dr_stage2_subject000${i}_Z.nii.gz
	    output=merged_Z/dr_stage2_subject000${i}_Z_${y}.nii.gz
	    fslroi $input $output ${y} 1

    done

    cd merged_Z
    fslmerge -t dr_stage2_ic${y}_Z `ls dr_stage2_subject*_Z_${y}.nii.gz`
    fslroi dr_stage2_ic${y}_Z dr_stage2_ic${y}_Z_exercise 0 21
    fslroi dr_stage2_ic${y}_Z dr_stage2_ic${y}_Z_stretch 21 -1
    rm dr_stage2_subject*_Z_${y}.nii.gz
    cd ../

  done

done




