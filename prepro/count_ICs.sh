#!/bin/bash

# Generate a text file with a column of values. Each value represents the number of components that ICA-AROMA derived  for a single patient.

export FSLDIR=/opt/fsl/5.0.11
.  ${FSLDIR}/etc/fslconf/fsl.sh

start=${pwd}
junk=/project/3011154.01/MJ/junk
working=/project/3011154.01/MJ/FC

list_subjects=()

session=(A B)

rm /project/3011154.01/MJ/FC/ICs_A.txt
rm /project/3011154.01/MJ/FC/ICs_B.txt

for x in ${session[@]}; do
for subject in ${list_subjects[@]}; do
  cd ${working}/${subject}${x}
  var=`fslinfo rs/ica_aroma/melodic.ica/melodic_IC | grep dim4 -m 1`
  echo ${var:5} >> ${working}/ICs_${x}.txt
done
done
