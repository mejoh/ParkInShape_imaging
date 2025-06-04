#!/bin/bash

##QSUB
#qsub -o /project/3011154.01/MJ/logs -e /project/3011154.01/MJ/logs -N group_melodic -l 'walltime=40:00:00,mem=15gb' ~/scripts/ParkInShape/stats/sensitivity_perprotocol/group_ica.sh 

export FSLDIR=/opt/fsl/6.0.3
.  ${FSLDIR}/etc/fslconf/fsl.sh

junk=/project/3011154.01/MJ/junk
working=/project/3011154.01/MJ/FC

cd ${working}

run_dual_regression=1
subtract=1
third_level_ica=1

# Run dual reg on all components to get subject-specific spatial maps (stage2)
# Recommended that you don't split them (think multiple regression)
# We're not interested in stage3 output now, just stage2, so we set permutations to 0

if [ ${run_dual_regression} -eq 1 ]
then

# First create a new input_list.txt
# This new list is ordered according to group, which is what we need for performing the third-level analysis
new_list_subjects=(PS003 PS012 PS014 PS017 PS019 PS021 PS025 PS026 PS027 PS033 PS035 PS038 PS041 PS044 PS046 PS052 PS053 PS002 PS004 PS006 PS011 PS016 PS018 PS020 PS024 PS028 PS029 PS031 PS034 PS036 PS039 PS043 PS047 PS048 PS049 PS054 PS056 PS059 PS060)
# Write one textfile each for the A and B sessions, but delete old ones first, then run randomise on each.
rm /project/3011154.01/MJ/FC/higher_level/3rd_level/randomise/sensitivity_perprotocol_2-7-2021/ICA/A_sessions.txt /project/3011154.01/MJ/FC/higher_level/3rd_level/randomise/sensitivity_perprotocol_2-7-2021/ICA/B_sessions.txt
touch /project/3011154.01/MJ/FC/higher_level/3rd_level/randomise/sensitivity_perprotocol_2-7-2021/ICA/A_sessions.txt
touch /project/3011154.01/MJ/FC/higher_level/3rd_level/randomise/sensitivity_perprotocol_2-7-2021/ICA/B_sessions.txt
mkdir -p /project/3011154.01/MJ/FC/higher_level/3rd_level/randomise/sensitivity_perprotocol_2-7-2021/ICA/dual_reg/A /project/3011154.01/MJ/FC/higher_level/3rd_level/randomise/sensitivity_perprotocol_2-7-2021/ICA/dual_reg/B
session=(A B)
for b in ${session[@]}; do
  for i in ${new_list_subjects[@]}; do
    grep ${i}${b}_nuireg_hp_std input_list.txt >> /project/3011154.01/MJ/FC/higher_level/3rd_level/randomise/sensitivity_perprotocol_2-7-2021/ICA/${b}_sessions.txt
  done

  ${FSLDIR}/bin/dual_regression \
        group/melodic_IC \
 	1 \
 	-1 \
 	0 \
 	/project/3011154.01/MJ/FC/higher_level/3rd_level/randomise/sensitivity_perprotocol_2-7-2021/ICA/dual_reg/${b} \
 	`cat /project/3011154.01/MJ/FC/higher_level/3rd_level/randomise/sensitivity_perprotocol_2-7-2021/ICA/${b}_sessions.txt`

done

fi

#----------------------------------------------------------#

# Subtract A from B. Do this for all components

mkdir -p $(pwd)/2nd_level

if [ ${subtract} -eq 1 ]
then

component=(0000 0001 0002 0003 0004 0005 0006 0007 0008 0009 0010 0011 0012 0013 0014 0015 0016 0017 0018 0019)
component=(0005)

for y in ${component[@]}; do
  ${FSLDIR}/bin/fslmaths \
	/project/3011154.01/MJ/FC/higher_level/3rd_level/randomise/sensitivity_perprotocol_2-7-2021/ICA/dual_reg/B/dr_stage2_ic${y} \
	-sub \
	/project/3011154.01/MJ/FC/higher_level/3rd_level/randomise/sensitivity_perprotocol_2-7-2021/ICA/dual_reg/A/dr_stage2_ic${y} \
	/project/3011154.01/MJ/FC/higher_level/3rd_level/randomise/sensitivity_perprotocol_2-7-2021/ICA//BsubA_ic${y}
done

fi

#----------------------------------------------------------#

# THIRD LEVEL: ICA

# IF you do multiple components, and run contrasts both ways, then you have to correct p values
# 0.05 / (Nr_of_comps * 2)
# 0.05 / (5 * 2) = 0.005	1-0.005 = 0.995

#1	DMN
#2	Visual
#3	Visual
#4	Parietal-SMA
#5	DMN
#6**	RFPN
#7**	LFPN
#8*	Parietal-Precuneus-Premotor
#9*	Parietal-Precuneus-PCC
#10*	Prefrontal-Thalamus-Caudate
#11*	Lateral M1
#12*	MPFC-ACC-Caudate-Thalamus
#13**	Premotor-ACC-Caudate-Thalamus (exec)
#14*	M1-S1-SPL
#15**	SMN
#16	Auditory
#17	Visual
#18	Parietal-Premotor (noisy)
#19	Cerebellum
#20	Parietal-Frontal-Visual
#comp_list=(0000 0001 0002 0003 0004 0005 0006 0007 0008 0009 0010 0011 0012 0013 0014 0015 0016 0017 0018 0019)
motor_comp_list=(0014 0013 0010)			# Motor comps
exec_comp_list=(0005 0006 0012 0011 0009)		# Executive function comps
rfpn_comp_list=(0005)					# Only rfpn
parietal_comp_list=(0003 0007 0008 0019)		# Remaining parietal comps

for e in ${rfpn_comp_list[@]}; do

	baseline=/project/3011154.01/MJ/FC/higher_level/3rd_level/randomise/sensitivity_perprotocol_2-7-2021/ICA/dual_reg/A/dr_stage2_ic${e}
	followup=/project/3011154.01/MJ/FC/higher_level/3rd_level/randomise/sensitivity_perprotocol_2-7-2021/ICA/dual_reg/B/dr_stage2_ic${e}
	BsubA=/project/3011154.01/MJ/FC/higher_level/3rd_level/randomise/sensitivity_perprotocol_2-7-2021/ICA/BsubA_ic${e}
	icnr=${e##+(0)}
	icnr=$(echo $e | sed 's/^0*//')

 	${FSLDIR}/bin/randomise \
		-i $BsubA \
		-o /project/3011154.01/MJ/FC/higher_level/3rd_level/randomise/sensitivity_perprotocol_2-7-2021/ICA/RFPN/exec_BsubA_ic${e}_up3ba-only \
		-d /home/sysneu/marjoh/scripts/ParkInShape/stats/sensitivity_perprotocol/3rd_level_cov_up3ba-only.mat \
		-t /project/3011154.01/MJ/FC/designs/statistics/3rd_level/3rd_level_cov_up3ba-only.con \
		-f /project/3011154.01/MJ/FC/designs/statistics/3rd_level/3rd_level_cov_up3ba-only.fts \
		-m $(pwd)/3rd_level/masks/ic_${icnr} \
		-n 5000 \
		-T \
		-R \
		--uncorrp
 	${FSLDIR}/bin/randomise \
		-i $baseline \
		-o /project/3011154.01/MJ/FC/higher_level/3rd_level/randomise/sensitivity_perprotocol_2-7-2021/ICA/RFPN/exec_A_ic${e}_up3ba-only \
		-d /home/sysneu/marjoh/scripts/ParkInShape/stats/sensitivity_perprotocol/3rd_level_cov_up3ba-only.mat \
		-t /home/sysneu/marjoh/scripts/ParkInShape/stats/sensitivity_perprotocol/3rd_level_cov_up3ba-only.con \
		-f /home/sysneu/marjoh/scripts/ParkInShape/stats/sensitivity_perprotocol/3rd_level_cov_up3ba-only.fts \
		-m $(pwd)/3rd_level/masks/ic_${icnr} \
		-n 5000 \
		-T \
		-R \
		--uncorrp
 	${FSLDIR}/bin/randomise \
		-i $followup \
		-o /project/3011154.01/MJ/FC/higher_level/3rd_level/randomise/sensitivity_perprotocol_2-7-2021/ICA/RFPN/exec_B_ic${e}_up3ba-only \
		-d /home/sysneu/marjoh/scripts/ParkInShape/stats/sensitivity_perprotocol/3rd_level_cov_up3ba-only.mat \
		-t /home/sysneu/marjoh/scripts/ParkInShape/stats/sensitivity_perprotocol/3rd_level_cov_up3ba-only.con \
		-f /home/sysneu/marjoh/scripts/ParkInShape/stats/sensitivity_perprotocol/3rd_level_cov_up3ba-only.fts \
		-m $(pwd)/3rd_level/masks/ic_${icnr} \
		-n 5000 \
		-T \
		-R \
		--uncorrp

#/project/3011154.01/MJ/FC/higher_level/groupICA/group/masks/ic${e}

done

fi
