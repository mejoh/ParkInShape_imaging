#!/bin/bash

# First-level analysis to get estimates of functional connectivity for each patient's two sessions

##QSUB
#list_subjects=(); for s in ${list_subjects[@]}; do qsub -o /project/3011154.01/MJ/logs -e /project/3011154.01/MJ/logs -N 1st_${s} -v subject=${s} -l 'walltime=02:30:00,mem=6gb' /project/3011154.01/MJ/scripts/stats/1st_level.sh; done

export FSLDIR=/opt/fsl/5.0.11
.  ${FSLDIR}/etc/fslconf/fsl.sh

junk=/project/3011154.01/MJ/junk
working=/project/3011154.01/MJ/FC
#working=/project/3011154.01/MJ/teststuff
cd ${working}

#----------------------------------------------------------#

# FIRST LEVEL
# Remember: Make a design template in FEAT

# Move old stuff (because of additional smoothing)
#mkdir -p ${subject}/rs/stats/1st_level/33mm
#mv ${subject}/rs/stats/1st_level/1st* ${subject}/rs/stats/1st_level/33mm
#mv ${subject}/rs/stats/1st_level/zstat* ${subject}/rs/stats/1st_level/33mm

# Copy 1st_level design template and change relevant settings
mkdir -p ${subject}/rs/stats/1st_level
cp /project/3011154.01/MJ/FC/designs/statistics/1st_level.fsf ${subject}/rs/stats/1st_level/1st_level.fsf
cd ${subject}

design=$(pwd)/rs/stats/1st_level/1st_level.fsf
outdir=$(pwd)/rs/stats/1st_level/1st_level
input_rs=$(pwd)/rs/prepro.feat/${subject}_nuireg_hp_addsmth.nii.gz
seed_region1=$(pwd)/rs/parcellation/${subject}_puta_ant_ts.txt
seed_region2=$(pwd)/rs/parcellation/${subject}_puta_post_ts.txt
seed_region3=$(pwd)/rs/parcellation/${subject}_caud_ant_sub_ts.txt
seed_region4=$(pwd)/rs/parcellation/${subject}_caud_post_sub_ts.txt
seed_region5=$(pwd)/rs/parcellation/${subject}_accu_ts.txt
seed_region6=$(pwd)/rs/parcellation/${subject}_gm_func_ts.txt

sed -i "s#outdir#${outdir}#g" ${design}
sed -i "s#input_rs#${input_rs}#g" ${design}
sed -i "s#seed_region1#${seed_region1}#g" ${design}
sed -i "s#seed_region2#${seed_region2}#g" ${design}
sed -i "s#seed_region3#${seed_region3}#g" ${design}
sed -i "s#seed_region4#${seed_region4}#g" ${design}
sed -i "s#seed_region5#${seed_region5}#g" ${design}
sed -i "s#seed_region6#${seed_region6}#g" ${design}

# Carry out first level analysis

${FSLDIR}/bin/feat ${design}

# Copy registration-folder from preprocessing in order to run 2nd level stats on separate groups

cp -r rs/prepro.feat/reg rs/stats/1st_level/1st_level.feat/reg

#----------------------------------------------------------#









