#!/bin/bash

cd /project/3011154.01/MJ/FC/
subs=`ls -d PS*`

for n in ${subs[@]}; do

dcm2niix -z y $n/ana/raw
cp $n/ana/raw/raw_t1_mprage*.nii.gz $n/ana
rm $n/ana/raw/raw_t1_mprage*.nii.gz
rm $n/ana/raw/raw_t1_mprage*.json
mv $n/ana/raw_t1_mprage*.nii.gz $n/ana/${n}_ana2.nii.gz


done
