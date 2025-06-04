#!/bin/bash

subjects=(PS003 PS012 PS014 PS017 PS019 PS021 PS025 PS026 PS027 PS032 PS033 PS035 PS037 PS038 PS041 PS044 PS045 PS046 PS052 PS053 PS057 PS002 PS004 PS006 PS007 PS011 PS016 PS018 PS020 PS022 PS024 PS028 PS029 PS031 PS034 PS036 PS039 PS043 PS047 PS048 PS049 PS054 PS056 PS058 PS059 PS060)
MAS=(2 2 2 1 1 2 2 2 2 1 2 1 1 1 2 1 1 2 1 2 1 1 2 2 2 1 2 1 1 2 1 2 2 2 2 1 1 2 2 1 1 1 1 2 2 1)

for n in ${!subjects[@]}; do

	if [ ${MAS[n]} -eq 2 ]; then

		roi=1
		s=${subjects[n]}
		m=${MAS[n]}
		echo "Left-to-right flipping ${s}, MAS=${m}"

		input=/project/3011154.01/MJ/FC/higher_level/2nd_level/${s}/${image}${roi}_std_A
		output=/project/3011154.01/MJ/FC/higher_level/test/${s}/${image}${roi}_std_A_LtoR
		fslswapdim /project/3011154.01/MJ/FC/higher_level/2nd_level/${s}/${image}${roi}_std_A \
			-x y z \
			/project/3011154.01/MJ/FC/higher_level/test/${s}/${image}${roi}_std_A_LtoR

		#input=$(pwd)/higher_level/2nd_level/${subject[n]}/${image}${roi}_std_B
		#output=$(pwd)/higher_level/test/${subject[n]}/${image}${roi}_std_B_LtoR
		#${FSLDIR}/bin/fslswapdim $input -x y z $output

		#input=$(pwd)/higher_level/2nd_level/${subject[n]}/${image}${roi}_std_BsubA
		#output=$(pwd)/higher_level/test/${subject[n]}/${image}${roi}_std_BsubA_LtoR
		#${FSLDIR}/bin/fslswapdim $input -x y z $output

	fi

done
