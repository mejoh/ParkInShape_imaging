#!/bin/bash

# This script registers the anatomical seeds defined for the A session to the functional space of the B session. It then extracts avg time series from those seeds. That is, it extracts regressors for the B session. These regressors follow the same naming conventions as was used for the A sessions. 

##QSUB
#list_subjects=(); for s in ${list_subjects[@]}; do qsub -o /project/3011154.01/MJ/logs -e /project/3011154.01/MJ/logs -N atob_${s} -v subject=${s} -l 'walltime=00:40:00,mem=3gb' /project/3011154.01/MJ/scripts/parcellation/parcellation_atob.sh; done

export FSLDIR=/opt/fsl/5.0.11
.  ${FSLDIR}/etc/fslconf/fsl.sh

junk=/project/3011154.01/MJ/junk
#working=/project/3011154.01/MJ/teststuff
working=/project/3011154.01/MJ/FC

cd $working

estimate_transform=0
putamen=0
caudate=0
nacc=0
global_gm=0
ts_extraction=1

#----------------------------------------------------------#

# Estimate transformation from A anatomical to B functional. We're using the epi_reg and convert_xfm commands here because that is what FEAT uses. Thus, we're calculating transformations from A to B with the same command-structure that was used to calculate transformations within A.

mkdir -p $(pwd)/${subject}B/rs/parcellation/intermediate

if [ ${estimate_transform} -eq 1 ]
then

${FSLDIR}/bin/epi_reg --epi=$(pwd)/${subject}B/rs/prepro.feat/example_func --t1=$(pwd)/${subject}A/ana/${subject}A_ana --t1brain=$(pwd)/${subject}A/ana/${subject}A_ana_brain --out=$(pwd)/${subject}B/rs/parcellation/example_func2highres

${FSLDIR}/bin/convert_xfm -omat $(pwd)/${subject}B/rs/parcellation/atob.mat -inverse $(pwd)/${subject}B/rs/parcellation/example_func2highres.mat

rm $(pwd)/${subject}B/rs/parcellation/example_func2highres*

fi

#----------------------------------------------------------#

# Putamen

list_quadrant=(ant post)
hemisphere=(L R)

if [ ${putamen} -eq 1 ]
then

for i in ${list_quadrant[@]}; do
  for h in ${hemisphere[@]}; do

    ${FSLDIR}/bin/fslmaths \
	$(pwd)/${subject}A/rs/parcellation/first/*${h}_Puta_corr* \
	-mul $(pwd)/${subject}A/rs/parcellation/intermediate/${i}_highres_thrbin \
	$(pwd)/${subject}B/rs/parcellation/intermediate/${h}_puta_${i}
    var=$(pwd)/${subject}B/rs/parcellation/intermediate/${h}_puta_${i}

    ${FSLDIR}/bin/flirt \
	-in ${var} \
	-ref $(pwd)/${subject}B/rs/prepro.feat/example_func \
	-applyxfm \
	-init $(pwd)/${subject}B/rs/parcellation/atob.mat \
	-out ${var}_func

    minmax=$(${FSLDIR}/bin/fslstats ${var}_func -R)
    max=$(echo "${minmax}" | cut -d ' ' -f 2)
    max=${max%.*}
    thr=$((${max}*2/3))

    ${FSLDIR}/bin/fslmaths \
    	${var}_func \
    	-thr ${thr} \
    	-bin \
    	${var}_func_thrbin


  done
done


${FSLDIR}/bin/fslmaths $(pwd)/${subject}B/rs/parcellation/intermediate/L_puta_ant_func_thrbin -add $(pwd)/${subject}B/rs/parcellation/intermediate/R_puta_ant_func_thrbin $(pwd)/${subject}B/rs/parcellation/${subject}B_puta_ant

${FSLDIR}/bin/fslmaths $(pwd)/${subject}B/rs/parcellation/intermediate/L_puta_post_func_thrbin -add $(pwd)/${subject}B/rs/parcellation/intermediate/R_puta_post_func_thrbin $(pwd)/${subject}B/rs/parcellation/${subject}B_puta_post

fi

#----------------------------------------------------------#

# Caudate

if [ ${caudate} -eq 1 ]
then

for i in ${list_quadrant[@]}; do
  for h in ${hemisphere[@]}; do

    ${FSLDIR}/bin/fslmaths \
	$(pwd)/${subject}A/rs/parcellation/first/*${h}_Caud_corr* \
	-mul $(pwd)/${subject}A/rs/parcellation/intermediate/${i}_highres_thrbin \
	$(pwd)/${subject}B/rs/parcellation/intermediate/${h}_caud_${i}
    var=$(pwd)/${subject}B/rs/parcellation/intermediate/${h}_caud_${i}

    ${FSLDIR}/bin/flirt \
	-in ${var} \
	-ref $(pwd)/${subject}B/rs/prepro.feat/example_func \
	-applyxfm \
	-init $(pwd)/${subject}B/rs/parcellation/atob.mat \
	-out ${var}_func

    minmax=$(${FSLDIR}/bin/fslstats ${var}_func -R)
    max=$(echo "${minmax}" | cut -d ' ' -f 2)
    max=${max%.*}
    thr=$((${max}*2/3))

    ${FSLDIR}/bin/fslmaths \
    	${var}_func \
    	-thr ${thr} \
    	-bin \
    	${var}_func_thrbin

  done
done

${FSLDIR}/bin/fslmaths $(pwd)/${subject}B/rs/parcellation/intermediate/L_caud_ant_func_thrbin -add $(pwd)/${subject}B/rs/parcellation/intermediate/R_caud_ant_func_thrbin $(pwd)/${subject}B/rs/parcellation/${subject}B_caud_ant

${FSLDIR}/bin/fslmaths $(pwd)/${subject}B/rs/parcellation/intermediate/L_caud_post_func_thrbin -add $(pwd)/${subject}B/rs/parcellation/intermediate/R_caud_post_func_thrbin $(pwd)/${subject}B/rs/parcellation/${subject}B_caud_post

${FSLDIR}/bin/fslmaths \
 	$(pwd)/${subject}B/rs/nui_hp/${subject}B_csfmask_func \
 	-bin \
 	$(pwd)/${subject}B/rs/parcellation/intermediate/latvent_func

${FSLDIR}/bin/fslmaths \
 	$(pwd)/${subject}B/rs/parcellation/${subject}B_caud_post \
 	-sub \
 	$(pwd)/${subject}B/rs/parcellation/intermediate/latvent_func \
 	-bin \
 	$(pwd)/${subject}B/rs/parcellation/${subject}B_caud_post_sub

${FSLDIR}/bin/fslmaths \
 	$(pwd)/${subject}B/rs/parcellation/${subject}B_caud_ant \
 	-sub \
 	$(pwd)/${subject}B/rs/parcellation/intermediate/latvent_func \
 	-bin \
 	$(pwd)/${subject}B/rs/parcellation/${subject}B_caud_ant_sub

fi

#----------------------------------------------------------#

# NAcc

if [ ${nacc} -eq 1 ]
then

for h in ${hemisphere[@]}; do


    ${FSLDIR}/bin/flirt \
	-in $(pwd)/${subject}A/rs/parcellation/first/*${h}_Accu_corr* \
	-ref $(pwd)/${subject}B/rs/prepro.feat/example_func \
	-applyxfm \
	-init $(pwd)/${subject}B/rs/parcellation/atob.mat \
	-out $(pwd)/${subject}B/rs/parcellation/intermediate/${h}_accu_func
    var=$(pwd)/${subject}B/rs/parcellation/intermediate/${h}_accu_func

    minmax=$(${FSLDIR}/bin/fslstats ${var} -R)
    max=$(echo "${minmax}" | cut -d ' ' -f 2)
    max=${max%.*}
    thr=$((${max}*2/3))

    ${FSLDIR}/bin/fslmaths \
    	${var} \
    	-thr ${thr} \
    	-bin \
    	${var}_thrbin

done

${FSLDIR}/bin/fslmaths $(pwd)/${subject}B/rs/parcellation/intermediate/L_accu_func_thrbin -add $(pwd)/${subject}B/rs/parcellation/intermediate/R_accu_func_thrbin $(pwd)/${subject}B/rs/parcellation/${subject}B_accu

${FSLDIR}/bin/fslmaths $(pwd)/${subject}B/rs/parcellation/${subject}B_caud_ant_sub -sub $(pwd)/${subject}B/rs/parcellation/${subject}B_accu -bin $(pwd)/${subject}B/rs/parcellation/${subject}B_caud_ant_sub

fi

#--------------------------------------------------------#

# Grey matter mask for first level analysis

if [ ${global_gm} -eq 1 ]
then

# Linear registration of gm mask to functional space
${FSLDIR}/bin/flirt \
 	-in $(pwd)/${subject}A/rs/parcellation/intermediate/${subject}A_gm_highres \
	-ref $(pwd)/${subject}B/rs/prepro.feat/example_func \
	-applyxfm \
	-init $(pwd)/${subject}B/rs/parcellation/atob.mat \
	-out $(pwd)/${subject}B/rs/parcellation/intermediate/${subject}B_gm_func

# Threhsold and binarize
${FSLDIR}/bin/fslmaths \
	$(pwd)/${subject}B/rs/parcellation/intermediate/${subject}B_gm_func \
	-thr 0.4 \
	-bin \
	$(pwd)/${subject}B/rs/parcellation/${subject}B_gm_func

fi

#--------------------------------------------------------#

if [ ${ts_extraction} -eq 1 ]
then

list_masks=(puta_ant puta_post caud_ant_sub caud_post_sub accu gm_func)
for i in ${list_masks[@]}; do
${FSLDIR}/bin/fslmeants \
	-i $(pwd)/${subject}B/rs/prepro.feat/${subject}B_nuireg_hp_addsmth \
	-o $(pwd)/${subject}B/rs/parcellation/${subject}B_${i}_ts.txt \
	-m $(pwd)/${subject}B/rs/parcellation/${subject}B_${i}
done

paste ${subject}B/rs/parcellation/${subject}B_puta_ant_ts.txt ${subject}B/rs/parcellation/${subject}B_puta_post_ts.txt ${subject}B/rs/parcellation/${subject}B_caud_ant_sub_ts.txt ${subject}B/rs/parcellation/${subject}B_caud_post_sub_ts.txt ${subject}B/rs/parcellation/${subject}B_accu_ts.txt ${subject}B/rs/parcellation/${subject}B_gm_func_ts.txt > ${subject}B/rs/parcellation/${subject}B_allseeds_ts.txt

fi

