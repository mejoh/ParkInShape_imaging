#!/bin/bash

#qsub -o /project/3011154.01/MJ/logs -e /project/3011154.01/MJ/logs -N long_vbm -l 'walltime=20:00:00,mem=10gb' ~/scripts/ParkInShape/longitudinal_vbm.sh

export FSLDIR=/opt/fsl/6.0.3
.  ${FSLDIR}/etc/fslconf/fsl.sh

folder_prep=0
brain_ext=0
template_cre=0		# 12h 30min
process=0		# 8h 15min
concatenate=0
smoothing=0
grp_stats=1
post_hoc=0

### --- Prepare VBM analysis folder --- ###
# Copy anatomicals to a folder for the VBM analysis
if [ ${folder_prep} -eq 1 ]
then

# Manually create a design file in GLM and drop it in /project/3011154.01/MJ/VBM. You will not use this design at the group level, it is just for the benefit of fslvbm_3_proc

# Dump ALL anatomicals you want to use in /project/3011154.01/MJ/VBM
#p_list=(PS003A PS012A PS014A PS017A PS019A PS021A PS025A PS026A PS027A PS032A PS033A PS035A PS037A PS038A #PS041A PS044A PS045A PS046A PS052A PS053A PS057A PS002A PS004A PS006A PS007A PS011A PS016A PS018A PS020A #PS022A PS024A PS028A PS029A PS031A PS034A PS036A PS039A PS043A PS047A PS048A PS049A PS054A PS056A PS058A #PS059A PS060A PS003B PS012B PS014B PS017B PS019B PS021B PS025B PS026B PS027B PS032B PS033B PS035B PS037B #PS038B PS041B PS044B PS045B PS046B PS052B PS053B PS057B PS002B PS004B PS006B PS007B PS011B PS016B PS018B #PS020B PS022B PS024B PS028B PS029B PS031B PS034B PS036B PS039B PS043B PS047B PS048B PS049B PS054B PS056B #PS058B PS059B PS060B)
p_list=(PS003 PS012 PS014 PS017 PS019 PS021 PS025 PS026 PS027 PS032 PS033 PS035 PS037 PS038 PS041 PS044 PS045 PS046 PS052 PS053 PS057 PS002 PS004 PS006 PS007 PS011 PS016 PS018 PS020 PS022 PS024 PS028 PS029 PS031 PS034 PS036 PS039 PS043 PS047 PS048 PS049 PS054 PS056 PS058 PS059 PS060)
for i in ${p_list[@]}; do

cp \
/project/3024006.02/ParkInShape_siena/${i}A_ana2_to_${i}B_ana2_siena/A_halfwayto_B.nii.gz \
/project/3011154.01/MJ/VBM_2/${i}A_halfwayto_B_ana.nii.gz

cp \
/project/3024006.02/ParkInShape_siena/${i}A_ana2_to_${i}B_ana2_siena/B_halfwayto_A.nii.gz \
/project/3011154.01/MJ/VBM_2/${i}B_halfwayto_A_ana.nii.gz

#cp /project/3011154.01/MJ/FC/${i}/ana/PS*_ana.nii.gz /project/3011154.01/MJ/VBM/${i}_ana.nii.gz

done

# Create a template list
cd /project/3011154.01/MJ/VBM_2
ls -1 PS*A_halfwayto_B_ana.nii.gz > template_list; ls -1 PS*B_halfwayto_A_ana.nii.gz >> template_list

#ls -1 PS*A_ana.nii.gz > template_list; ls -1 PS*B_ana.nii.gz >> template_list

# Create a html file to check quality of anatomicals
${FSLDIR}/bin/slicesdir `imglob *`

fi

### --- Brain extract: fslvbm_1_bet --- ###
if [ ${brain_ext} -eq 1 ]
then

cd /project/3011154.01/MJ/VBM_2
${FSLDIR}/bin/fslvbm_1_bet -N

fi

### --- Template creation: fslvbm_2_template --- ###
if [ ${template_cre} -eq 1 ]
then

# Manually modify the template_list file so that an equal number of participants from the two groups are included

cd /project/3011154.01/MJ/VBM_2

# create template
${FSLDIR}/bin/fslvbm_2_template -n

# restore template_list
ls -1 PS*A_halfwayto_B_ana.nii.gz > template_list; ls -1 PS*B_halfwayto_A_ana.nii.gz >> template_list
#ls -1 PS*A_ana.nii.gz > template_list; ls -1 PS*B_ana.nii.gz >> template_list

fi

### --- Process images: fslvbm_3_proc --- ###
if [ ${process} -eq 1 ]
then

cd /project/3011154.01/MJ/VBM_2
${FSLDIR}/bin/fslvbm_3_proc

fi

### --- Concatenate GM images and calculate Post-Pre difference --- ###
if [ ${concatenate} -eq 1 ]
then

cd /project/3011154.01/MJ/VBM_2/struc

ex_A=(PS003A PS012A PS014A PS017A PS019A PS021A PS025A PS026A PS027A PS032A PS033A PS035A PS037A PS038A PS041A PS044A PS045A PS046A PS052A PS053A PS057A)
ex_B=(PS003B PS012B PS014B PS017B PS019B PS021B PS025B PS026B PS027B PS032B PS033B PS035B PS037B PS038B PS041B PS044B PS045B PS046B PS052B PS053B PS057B)
st_A=(PS002A PS004A PS006A PS007A PS011A PS016A PS018A PS020A PS022A PS024A PS028A PS029A PS031A PS034A PS036A PS039A PS043A PS047A PS048A PS049A PS054A PS056A PS058A PS059A PS060A)
st_B=(PS002B PS004B PS006B PS007B PS011B PS016B PS018B PS020B PS022B PS024B PS028B PS029B PS031B PS034B PS036B PS039B PS043B PS047B PS048B PS049B PS054B PS056B PS058B PS059B PS060B)

# merge images from EX group for each session separately
${FSLDIR}/bin/fslmerge -t ex_A_mod_merg `printf "%s_halfwayto_B_ana_struc_GM_to_template_GM_mod " "${ex_A[@]}"`
${FSLDIR}/bin/fslmerge -t ex_B_mod_merg `printf "%s_halfwayto_A_ana_struc_GM_to_template_GM_mod " "${ex_B[@]}"`
# merge images from ST group for each session separately
${FSLDIR}/bin/fslmerge -t st_A_mod_merg `printf "%s_halfwayto_B_ana_struc_GM_to_template_GM_mod " "${st_A[@]}"`
${FSLDIR}/bin/fslmerge -t st_B_mod_merg `printf "%s_halfwayto_A_ana_struc_GM_to_template_GM_mod " "${st_B[@]}"`
# compute post-pre for each group
${FSLDIR}/bin/fslmaths ex_B_mod_merg -sub ex_A_mod_merg ex_BsubA_mod_merg
${FSLDIR}/bin/fslmaths st_B_mod_merg -sub st_A_mod_merg st_BsubA_mod_merg
# merge the two groups
${FSLDIR}/bin/fslmerge -t ../BsubA_mod_merg ex_BsubA_mod_merg st_BsubA_mod_merg
${FSLDIR}/bin/fslmerge -t ../A_mod_merg ex_A_mod_merg st_A_mod_merg
${FSLDIR}/bin/fslmerge -t ../B_mod_merg ex_B_mod_merg st_B_mod_merg

fi

### --- Smoothing --- ###
if [ ${smoothing} -eq 1 ]
then

# FWHM = 2.35 * sigma

cd /project/3011154.01/MJ/VBM_2

$FSLDIR/bin/fslmaths BsubA_mod_merg -s 4.5 BsubA_mod_merg4
$FSLDIR/bin/fslmaths A_mod_merg -s 4.5 A_mod_merg4
$FSLDIR/bin/fslmaths B_mod_merg -s 4.5 B_mod_merg4

fi

### --- Group-level stats --- ###
# Use the same design as was used for functional connectivity (two-sample t-test)
if [ ${grp_stats} -eq 1 ]
then

cd /project/3011154.01/MJ/VBM_2

mkdir -p stats/rand

#GM_mask
#rfpn_mask
#smn_mask
#SigRFPN_mask
#SigPutSmn_mask

# NEW MASKS following new normalization procedure
#/project/3024006.02/Users/marjoh/intermediate/groupICA/3rd_level/masks/ic_10.nii.gz	SMN: Lateral M1
#/project/3024006.02/Users/marjoh/intermediate/groupICA/3rd_level/masks/ic_13.nii.gz	SMN: M1-S1-SPL
#/project/3024006.02/Users/marjoh/intermediate/groupICA/3rd_level/masks/ic_14.nii.gz	SMN: Main
#/project/3024006.02/Users/marjoh/intermediate/groupICA/3rd_level/masks/ic_5.nii.gz	RFPN
#/project/3024006.02/Users/marjoh/intermediate/groupICA/3rd_level/masks/ic_6.nii.gz	LFPN
#/project/3024006.02/Users/marjoh/intermediate/groupICA/3rd_level/masks/ic_12.nii.gz	EXEC
#grpdesign/rois/GM_mask 	Whole brain
#/project/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun4_10-05-2021/SMN/results/APsubPP_up3ba-only/mask.nii.gz		# AP-PP fc
#/project/3011154.01/MJ/FC/higher_level/3rd_level/randomise/rerun4_10-05-2021/SMN/results/2_up3ba-only/mask.nii.gz		#PP fc
#/project/3024006.02/Users/marjoh/intermediate/groupICA/3rd_level/results/rfpn/mask.nii.gz		# Rfpn fc

icnr=13
network=whole_brain
up3ba=up3ba-only
outputdir=stats/rand/${network}
mkdir -p ${outputdir}
mask=grpdesign/rois/GM_mask

cp /project/3011154.01/MJ/FC/designs/statistics/3rd_level/3rd_level_cov_${up3ba}.con ${outputdir}/con_${up3ba}.txt
cp $mask ${outputdir}

${FSLDIR}/bin/randomise \
	-i BsubA_mod_merg4 \
	-o ${outputdir}/vbm_BsubA_${up3ba} \
	-m ${mask} \
	-d /project/3011154.01/MJ/FC/designs/statistics/3rd_level/3rd_level_cov_${up3ba}.mat \
	-t /project/3011154.01/MJ/FC/designs/statistics/3rd_level/3rd_level_cov_${up3ba}.con \
	-f /project/3011154.01/MJ/FC/designs/statistics/3rd_level/3rd_level_cov_${up3ba}.fts \
	-n 5000 \
	-T \
	--uncorrp
${FSLDIR}/bin/randomise \
	-i A_mod_merg4 \
	-o ${outputdir}/vbm_A_${up3ba} \
	-m ${mask} \
	-d /project/3011154.01/MJ/FC/designs/statistics/3rd_level/3rd_level_cov_${up3ba}.mat \
	-t /project/3011154.01/MJ/FC/designs/statistics/3rd_level/3rd_level_cov_${up3ba}.con \
	-f /project/3011154.01/MJ/FC/designs/statistics/3rd_level/3rd_level_cov_${up3ba}.fts \
	-n 5000 \
	-T \
	--uncorrp
${FSLDIR}/bin/randomise \
	-i B_mod_merg4 \
	-o ${outputdir}/vbm_B_${up3ba} \
	-m ${mask} \
	-d /project/3011154.01/MJ/FC/designs/statistics/3rd_level/3rd_level_cov_${up3ba}.mat \
	-t /project/3011154.01/MJ/FC/designs/statistics/3rd_level/3rd_level_cov_${up3ba}.con \
	-f /project/3011154.01/MJ/FC/designs/statistics/3rd_level/3rd_level_cov_${up3ba}.fts \
	-n 5000 \
	-T \
	--uncorrp

fi

### --- Post hoc --- ###

if [ ${post_hoc} -eq 1 ]
then

cd /project/3011154.01/MJ/VBM_2

${FSLDIR}/bin/fslroi \
	$(pwd)/BsubA_mod_merg4 \
	$(pwd)/BsubAexercise_mod_merg4 \
	0 21
${FSLDIR}/bin/fslroi \
	$(pwd)/BsubA_mod_merg4 \
	$(pwd)/BsubAstretch_mod_merg4 \
	21 25

${FSLDIR}/bin/fslmaths $(pwd)/BsubAexercise_mod_merg4 -mul -1 $(pwd)/BsubAexerciseNEG_mod_merg4
${FSLDIR}/bin/fslmaths $(pwd)/BsubAstretch_mod_merg4 -mul -1 $(pwd)/BsubAstretchNEG_mod_merg4

group=(exercise stretch)
#mask=GM_mask
#mask=rfpn_mask
#mask=smn_mask
#mask=SigRFPN_mask
mask=SigPutSmn_mask

for i in ${group[@]}; do

${FSLDIR}/bin/randomise \
	-i $(pwd)/BsubA${i}_mod_merg4.nii.gz \
	-o $(pwd)/stats/rand/APsubPPposthoc/${i} \
	-m $(pwd)/grpdesign/rois/APsubPPresult\
	-d $(pwd)/grpdesign/posthoc/${i}/3rd_level_cov.mat \
	-t $(pwd)/grpdesign/posthoc/${i}/3rd_level_cov.con \
	-n 5000 \
	-T \
	--uncorrp

${FSLDIR}/bin/randomise \
	-i $(pwd)/BsubA${i}NEG_mod_merg4.nii.gz \
	-o $(pwd)/stats/rand/APsubPP/posthoc/${i}NEG \
	-m $(pwd)/grpdesign/rois/APsubPPresult \
	-d $(pwd)/grpdesign/posthoc/${i}/3rd_level_cov.mat \
	-t $(pwd)/grpdesign/posthoc/${i}/3rd_level_cov.con \
	-n 5000 \
	-T \
	--uncorrp

done

fi







