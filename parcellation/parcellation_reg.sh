#!/bin/bash

# Register anatomical striatum masks to functional space. Only take subjects' A sessions here.

##QSUB
#list_subjects=(); for s in ${list_subjects[@]}; do qsub -o /project/3011154.01/MJ/logs -e /project/3011154.01/MJ/logs -N parcel_${s} -v subject=${s} -l 'walltime=00:20:00,mem=2gb' /project/3011154.01/MJ/scripts/parcellation/parcellation_reg.sh; done

export FSLDIR=/opt/fsl/5.0.11
.  ${FSLDIR}/etc/fslconf/fsl.sh

junk=/project/3011154.01/MJ/junk
working=/project/3011154.01/MJ/FC
#working=/project/3011154.01/MJ/teststuff
cd ${working}/${subject}

preparation=0
putamen=0
caudate=0
ventricle_subtraction=0
nucleus_accumbens=0
posterior_cingulate=0
global_signal=0
grey_matter_signal=0
extract_timeseries=1


#--------------------------------------------------------#
# Preparation

# Create directory for intermediate output. Useful for debugging/checking
mkdir -p $(pwd)/rs/parcellation/intermediate

# Define lists for for-loops
list_quadrant=(ant post)
hemisphere=(L R)

if [ ${preparation} -eq 1 ]
then

# Invert the highres2standard_warp
	# Note: This step is also done in nui_reg.sh
${FSLDIR}/bin/invwarp \
	-w $(pwd)/rs/prepro.feat/reg/highres2standard_warp \
	-o $(pwd)/rs/prepro.feat/reg/standard2highres_warp \
	-r $(pwd)/rs/prepro.feat/reg/highres
inverted_transform=$(pwd)/rs/prepro.feat/reg/standard2highres_warp

# Transform the dividing-quadrants to highres
for s in ${list_quadrant[@]}; do
  quadrant=/project/3011154.01/MJ/FC/designs/parcellation/${s}*
  ${FSLDIR}/bin/applywarp \
	-i ${quadrant} \
	-r $(pwd)/rs/prepro.feat/reg/highres \
	-o $(pwd)/rs/parcellation/intermediate/${s}_highres \
	-w ${inverted_transform}

  ${FSLDIR}/bin/fslmaths $(pwd)/rs/parcellation/intermediate/${s}_highres -thr 0.4 -bin $(pwd)/rs/parcellation/intermediate/${s}_highres_thrbin
done

fi

#--------------------------------------------------------#
# Putamen

if [ ${putamen} -eq 1 ]
then

l_puta=$(pwd)/rs/parcellation/first/*L_Puta_corr*
r_puta=$(pwd)/rs/parcellation/first/*R_Puta_corr*

for i in ${list_quadrant[@]}; do
  for h in ${hemisphere[@]}; do

    # Divide
		#add -ero option after -mul to increase specificity
    ${FSLDIR}/bin/fslmaths \
	$(pwd)/rs/parcellation/first/*${h}_Puta_corr* \
	-mul $(pwd)/rs/parcellation/intermediate/${i}_highres_thrbin \
	$(pwd)/rs/parcellation/intermediate/${h}_puta_${i}
    var=$(pwd)/rs/parcellation/intermediate/${h}_puta_${i}

    # Register
    ${FSLDIR}/bin/flirt \
	-in ${var} \
	-ref $(pwd)/rs/prepro.feat/reg/example_func \
	-applyxfm \
	-init $(pwd)/rs/prepro.feat/reg/highres2example_func.mat \
	-out ${var}_func

    # Calculate threshold
    minmax=$(${FSLDIR}/bin/fslstats ${var}_func -R)
    max=$(echo "${minmax}" | cut -d ' ' -f 2)
    max=${max%.*}
    thr=$((${max}*2/3))

    # Threshold and binarize
    ${FSLDIR}/bin/fslmaths \
    	${var}_func \
    	-thr ${thr} \
    	-bin \
    	${var}_func_thrbin
    
  done
done

# Add left and right
#Anterior
${FSLDIR}/bin/fslmaths $(pwd)/rs/parcellation/intermediate/L_puta_ant_func_thrbin -add $(pwd)/rs/parcellation/intermediate/R_puta_ant_func_thrbin $(pwd)/rs/parcellation/${subject}_puta_ant
#Posterior
${FSLDIR}/bin/fslmaths $(pwd)/rs/parcellation/intermediate/L_puta_post_func_thrbin -add $(pwd)/rs/parcellation/intermediate/R_puta_post_func_thrbin $(pwd)/rs/parcellation/${subject}_puta_post

fi

#--------------------------------------------------------#
# Caudate

if [ ${caudate} = 1 ]
then

l_caud=$(pwd)/rs/parcellation/first/*L_Caud_corr*
r_caud=$(pwd)/rs/parcellation/first/*R_Caud_corr*

list_quadrant=(ant post)
hemisphere=(L R)
for i in ${list_quadrant[@]}; do
  for h in ${hemisphere[@]}; do

    # Divide
		#add -ero option after -mul to increase sensitivity
    ${FSLDIR}/bin/fslmaths \
	$(pwd)/rs/parcellation/first/*${h}_Caud_corr* \
	-mul $(pwd)/rs/parcellation/intermediate/${i}_highres_thrbin \
	$(pwd)/rs/parcellation/intermediate/${h}_caud_${i}
    var=$(pwd)/rs/parcellation/intermediate/${h}_caud_${i}

    # Register
    ${FSLDIR}/bin/flirt \
	-in ${var} \
	-ref $(pwd)/rs/prepro.feat/reg/example_func \
	-applyxfm \
	-init $(pwd)/rs/prepro.feat/reg/highres2example_func.mat \
	-out ${var}_func

    # Calculate threshold
    minmax=$(${FSLDIR}/bin/fslstats ${var}_func -R)
    max=$(echo "${minmax}" | cut -d ' ' -f 2)
    max=${max%.*}
    thr=$((${max}*2/3))

    # Threshold and binarize
    ${FSLDIR}/bin/fslmaths \
    	${var}_func \
    	-thr ${thr} \
    	-bin \
    	${var}_func_thrbin
    
  done
done

# Add left and right
#Anterior
${FSLDIR}/bin/fslmaths $(pwd)/rs/parcellation/intermediate/L_caud_ant_func_thrbin -add $(pwd)/rs/parcellation/intermediate/R_caud_ant_func_thrbin $(pwd)/rs/parcellation/${subject}_caud_ant
#Posterior
${FSLDIR}/bin/fslmaths $(pwd)/rs/parcellation/intermediate/L_caud_post_func_thrbin -add $(pwd)/rs/parcellation/intermediate/R_caud_post_func_thrbin $(pwd)/rs/parcellation/${subject}_caud_post

fi

#----#

if [ ${ventricle_subtraction} -eq 1 ]
then

# Subtract lateral ventricles from caudate masks to increase sensitivity. Use the CSF mask in functional space that we constructed in nui_hp.sh

# Binarize
${FSLDIR}/bin/fslmaths \
 	$(pwd)/rs/nui_hp/${subject}_csfmask_func \
 	-bin \
 	$(pwd)/rs/parcellation/intermediate/latvent_func

# Subtract
${FSLDIR}/bin/fslmaths \
 	$(pwd)/rs/parcellation/${subject}_caud_post \
 	-sub \
 	$(pwd)/rs/parcellation/intermediate/latvent_func \
 	-bin \
 	$(pwd)/rs/parcellation/${subject}_caud_post_sub

${FSLDIR}/bin/fslmaths \
 	$(pwd)/rs/parcellation/${subject}_caud_ant \
 	-sub \
 	$(pwd)/rs/parcellation/intermediate/latvent_func \
 	-bin \
 	$(pwd)/rs/parcellation/${subject}_caud_ant_sub

fi

#--------------------------------------------------------#
# Nucleus Accumbens (NAcc)

if [ ${nucleus_accumbens} -eq 1 ]
then

	# uncomment the following to erode NAcc mask to increase sensitivity. You'll have to change what you FLIRT if you want to use this option.
#${FSLDIR}/bin/fslmaths $(pwd)/rs/parcellation/first/*L_Accu_corr* -ero $(pwd)/rs/parcellation/intermediate/highres_L_Accu_corr_ero
#${FSLDIR}/bin/fslmaths $(pwd)/rs/parcellation/first/*R_Accu_corr* -ero $(pwd)/rs/parcellation/intermediate/highres_R_Accu_corr_ero

l_accu=$(pwd)/rs/parcellation/first/*L_Accu_corr*
r_accu=$(pwd)/rs/parcellation/first/*R_Accu_corr*

for h in ${hemisphere[@]}; do

    # Register
    ${FSLDIR}/bin/flirt \
	-in $(pwd)/rs/parcellation/first/*${h}_Accu_corr* \
	-ref $(pwd)/rs/prepro.feat/reg/example_func \
	-applyxfm \
	-init $(pwd)/rs/prepro.feat/reg/highres2example_func.mat \
	-out $(pwd)/rs/parcellation/intermediate/${h}_accu_func
    var=$(pwd)/rs/parcellation/intermediate/${h}_accu_func

    # Calculate threshold
    minmax=$(${FSLDIR}/bin/fslstats ${var} -R)
    max=$(echo "${minmax}" | cut -d ' ' -f 2)
    max=${max%.*}
    thr=$((${max}*2/3))

    # Threshold and binarize
    ${FSLDIR}/bin/fslmaths \
    	${var} \
    	-thr ${thr} \
    	-bin \
    	${var}_thrbin
done

# Add left and right
${FSLDIR}/bin/fslmaths $(pwd)/rs/parcellation/intermediate/L_accu_func_thrbin -add $(pwd)/rs/parcellation/intermediate/R_accu_func_thrbin $(pwd)/rs/parcellation/${subject}_accu

# Additional step unique to NAcc: Subtract the NAcc-mask from the anterior caudate mask. The two tend to overlap and ant caud tends to be quite a bit larger than NAcc. Note that this script affects the caudate mask only, but is done as a part of the NAcc script since it increases the sensitivity of the NAcc mask.

${FSLDIR}/bin/fslmaths $(pwd)/rs/parcellation/${subject}_caud_ant_sub -sub $(pwd)/rs/parcellation/${subject}_accu -bin $(pwd)/rs/parcellation/${subject}_caud_ant_sub

fi

#--------------------------------------------------------#
# Posterior cingulate (PCC)
# Turning this option on will require adding to the ts extraction in this script and 1st_level.sh

if [ ${posterior_cingulate} -eq 1 ]
then

# Note: This script utilizes the FIRST output of the nui_hp.sh script. Make sure you've run that script before. Otherwise you can run FIRST on its own and direct the gm-variable below to its output.
pcc=/project/3011154.01/MJ/FC/designs/parcellation/cortex/pcc_80bin
gm=$(pwd)/rs/nui_hp/${subject}_highres_pve_1

# Register mask
${FSLDIR}/bin/applywarp \
	-i ${pcc} \
	-r $(pwd)/rs/prepro.feat/reg/highres \
	-o $(pwd)/rs/parcellation/intermediate/pcc_highres \
	-w ${inverted_transform}

# Threshold and mask segmented grey matter
${FSLDIR}/bin/fslmaths \
	${gm} \
	-thr 1 \
	-bin \
	-mas $(pwd)/rs/parcellation/intermediate/pcc_highres \
	$(pwd)/rs/parcellation/intermediate/grey_matter_thrbinmas
gm=$(pwd)/rs/parcellation/intermediate/grey_matter_thrbinmas

# Register grey matter
${FSLDIR}/bin/flirt \
	-in ${gm} \
	-ref $(pwd)/rs/prepro.feat/reg/example_func \
	-applyxfm \
	-init $(pwd)/rs/prepro.feat/reg/highres2example_func.mat \
	-out ${gm}_func

# Threshold final mask. Lenient threshold as we used a stringent one in highres
${FSLDIR}/bin/fslmaths \
	${gm}_func \
	-thr 0.2 \
	-bin \
	$(pwd)/rs/parcellation/${subject}_pcc

fi

#--------------------------------------------------------#
# Global signal

if [ ${global_signal} -eq 1 ]
then

cp $(pwd)/rs/ica_aroma/mask.nii.gz $(pwd)/rs/parcellation/${subject}_gs.nii.gz

fi

#------------------------------------------------------------------------------#
# Grey matter mask for first level analysis

grey_matter_signal=1

if [ ${grey_matter_signal} -eq 1 ]
then

${FSLDIR}/bin/fslmaths \
	$(pwd)/rs/parcellation/first/highres_all_fast_firstseg \
	-bin \
	$(pwd)/rs/parcellation/intermediate/binned_highres_masks

${FSLDIR}/bin/fslmaths \
	$(pwd)/rs/nui_hp/${subject}_highres_pve_1.nii.gz \
	-sub $(pwd)/rs/parcellation/intermediate/binned_highres_masks \
	$(pwd)/rs/parcellation/intermediate/${subject}_gm_highres

${FSLDIR}/bin/fslmaths \
	$(pwd)/rs/parcellation/intermediate/${subject}_gm_highres \
	-thr 0.9 \
	-bin \
	$(pwd)/rs/parcellation/intermediate/${subject}_gm_highres

${FSLDIR}/bin/flirt \
 	-in $(pwd)/rs/parcellation/intermediate/${subject}_gm_highres \
	-ref $(pwd)/rs/prepro.feat/example_func \
	-applyxfm \
	-init $(pwd)/rs/prepro.feat/reg/highres2example_func.mat \
	-out $(pwd)/rs/parcellation/intermediate/${subject}_gm_func

${FSLDIR}/bin/fslmaths \
	$(pwd)/rs/parcellation/intermediate/${subject}_gm_func \
	-thr 0.4 \
	-bin \
	$(pwd)/rs/parcellation/${subject}_gm_func

fi

#------------------------------------------------------------------------------#

# Extract timeseries
# Remove _sub from the caudate masks if you dont want the lateral ventricles subtracted

if [ ${extract_timeseries} -eq 1 ]
then

list_masks=(puta_ant puta_post caud_ant_sub caud_post_sub accu gm_func)
for i in ${list_masks[@]}; do
${FSLDIR}/bin/fslmeants \
	-i $(pwd)/rs/prepro.feat/${subject}_nuireg_hp_addsmth \
	-o $(pwd)/rs/parcellation/${subject}_${i}_ts.txt \
	-m $(pwd)/rs/parcellation/${subject}_${i}
done

paste rs/parcellation/${subject}_puta_ant_ts.txt rs/parcellation/${subject}_puta_post_ts.txt rs/parcellation/${subject}_caud_ant_sub_ts.txt rs/parcellation/${subject}_caud_post_sub_ts.txt rs/parcellation/${subject}_accu_ts.txt rs/parcellation/${subject}_gm_func_ts.txt > rs/parcellation/${subject}_allseeds_ts.txt

fi






