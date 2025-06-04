#!/bin/bash

# Brain extract anatomicals. Preprocess fmri data with FEAT. Run ICA aroma. Re-do ICA aroma.
# Note: Preprocessing creates a lot of intermediate outputs that are removed at the end. This takes up a lot of space. It's therefore best not to run all subjects at the same time, but in groups of ~30

##QSUB
#list_subjects=(PS042A PS042B); for s in ${list_subjects[@]}; do qsub -o /project/3011154.01/MJ/logs -e /project/3011154.01/MJ/logs -N dataprep_${s} -v subject=${s} -l 'walltime=04:00:00,mem=5gb' ~/scripts/ParkInShape/prepro/dataprep.sh; done

#PS002A PS002B PS003A PS003B PS004A PS004B PS006A PS006B PS007A PS007B PS011A PS011B PS012A PS012B PS014A PS014B PS016A PS016B PS017A PS017B PS018A PS018B PS019A PS019B PS020A PS020B PS021A PS021B PS022A PS022B PS024A PS024B PS025A PS025B PS026A PS026B PS027A PS027B PS028A PS028B PS029A PS029B PS031A PS031B PS032A PS032B PS033A PS033B PS034A PS034B PS035A PS035B PS036A PS036B PS037A PS037B PS038A PS038B PS039A PS039B PS041A PS041B PS042A PS042B PS043A PS043B PS044A PS044B PS045A PS045B PS046A PS046B PS047A PS047B PS048A PS048B PS049A PS049B PS052A PS052B PS053A PS053B PS054A PS054B PS056A PS056B PS057A PS057B PS058A PS058B PS059A PS059B PS060A PS060B

#PS030A PS055A PS010A PS023A PS040A PS051A PS041A PS053A

export FSLDIR=/opt/fsl/6.0.3
.  ${FSLDIR}/etc/fslconf/fsl.sh

junk=/project/3011154.01/MJ/junk
working=/project/3011154.01/MJ/FC
#working=/project/3011154.01/MJ/teststuff
cd ${working}
cd ${subject}

brain_extraction=0
feat_preprocessing=1
aroma_motion=0
rerun_ica=0

#------------------------------------------------------------------------------#

# Brain extract the anatomicals

if [ ${brain_extraction} -eq 1 ]
then

${FSLDIR}/bin/bet \
	$(pwd)/ana/${subject}_ana \
	$(pwd)/ana/${subject}_ana_brain \
 	-f 0.5 \
	-R \
	-B
 	#-g 0.1
fi

#------------------------------------------------------------------------------#

# Run FEAT to preprocess resting-state data (brain extract>motion correct>smooth>estimate transforms)
# Remember to make a design template in FEAT

if [ ${feat_preprocessing} -eq 1 ]
then

cd ${working}
cp /project/3011154.01/MJ/FC/designs/preprocessing/preprocessing.fsf ${subject}/rs/${subject}_prepro.fsf

cd ${subject}
design=$(pwd)/rs/${subject}_prepro.fsf
#output=$(pwd)/rs/prepro
output=/project/3024006.02/Users/marjoh/intermediate/${subject}
input_rs=$(pwd)/rs/${subject}_rs.nii.gz
nvols=`${FSLDIR}/bin/fslnvols ${input_rs}`
func_image_tr=1.1
func_image_smooth=5
slice_time_corr=0
refimg=/project/3011154.01/MJ/anatomical_std_template/template_avg_anat_asym_brain.nii.gz
input_ana=$(pwd)/ana/${subject}_ana_brain.nii.gz
#if [[ $subject == *"A"* ]]; then 
#	input_ana=/project/3011154.01/MJ/VBM_2/struc/${subject}_halfwayto_B_ana_struc_brain.nii.gz
#else
#	input_ana=/project/3011154.01/MJ/VBM_2/struc/${subject}_halfwayto_A_ana_struc_brain.nii.gz
#fi
sed -i "s#output_dir#${output}#g" ${design}
sed -i "s#input_rs#${input_rs}#g" ${design}
sed -i "s#input_ana#${input_ana}#g" ${design}
sed -i "s#nvols#${nvols}#g" ${design}
sed -i "s#func_image_tr#${func_image_tr}#g" ${design}
sed -i "s#func_image_smooth#${func_image_smooth}#g" ${design}
sed -i "s#slice_time_corr#${slice_time_corr}#g" ${design}
sed -i "s#refimg#${refimg}#g" ${design}

${FSLDIR}/bin/feat \
	${design}

mv rs/${subject}_prepro.fsf rs/prepro.feat/${subject}_prepro.fsf

fi

#------------------------------------------------------------------------------#

# Run ICA-AROMA to denoise resting-state data

if [ ${aroma_motion} -eq 1 ]
then

ica_aroma=/project/3011154.01/MJ/scripts/prepro/ICA_AROMA_files/ICA_AROMA.py

python2.7 ${ica_aroma} -feat $(pwd)/rs/prepro.feat -out $(pwd)/rs/ica_aroma -tr 1.1


fi

#------------------------------------------------------------------------------#

# Re-run ICA-AROMA
# After you've run ICA_AROMA, check whether the components are labeled correctly. If you want to relabel, then create a text-file called reclassified_motion_ICs.txt (as opposed to the classified_motion_ICs.txt that ICA-AROMA creates for you). Easiest way to do this is with fsleyes in melodic mode. The following script will rewrite the previously denoised resting-state data
# Note that the script below performs NON-AGGRESSIVE denoising. You give fsl_regilt all the ICA time courses, these are regressed against the functional data and then, by default, variance attributed to whatever is in the -f option is removed. 

if [ ${rerun_ica} -eq 1 ]
then

${FSLDIR}/bin/fsl_regfilt \
	-i $(pwd)/rs/prepro.feat/filtered_func_data \
	-d $(pwd)/rs/ica_aroma/melodic.ica/melodic_mix \
	-f $(tail -1 $(pwd)/rs/ica_aroma/reclassified_motion_ICs.txt | tr -d "[] \t\r\n") \
	-o $(pwd)/rs/ica_aroma/denoised_func_data_nonaggr

fi

# Done. Next run regressors.m using the command below...
# Qsub command: matlab_sub --walltime 00:30:00 --mem 2gb /project/3011154.01/MJ/scripts/prepro/regressors.m
