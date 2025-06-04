#!/bin/bash

# Calculate a group average
cd /project/3011154.01/MJ/anatomical_std_template
images=`ls PS0*_warped_ana.nii.gz`
fslmerge -t template_4D_anat $images
fslmaths template_4D_anat -Tmean template_avg_anat_asym
fslswapdim template_avg_anat_asym -x y z template_avg_anat_asym_swap
fslmerge -t template_avg_anat_4D template_avg_anat_asym template_avg_anat_asym_swap
fslmaths template_avg_anat_4D -Tmean template_avg_anat_sym

fslmaths template_avg_anat_asym -mul /opt/fsl/6.0.3/data/standard/MNI152_T1_2mm_brain_mask_dil1 template_avg_anat_asym_brain
fslmaths template_avg_anat_sym -mul /opt/fsl/6.0.3/data/standard/MNI152_T1_2mm_brain_mask_dil1 template_avg_anat_sym_brain


