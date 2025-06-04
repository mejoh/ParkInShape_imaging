#!/bin/bash

# Turn a COPE image into a 1-P image

ttologp -logpout logp1 varcope1 cope1 `cat dof`
fslmaths logp1 -exp p1
fslmaths p1 -mul -1 -add 1 -mas ../mask p1_1minusp

# FDR
# Calculate log(p) image > Calculate p image > Calculate FDR-threshold > Calculate 1-P image and apply FDR correction

ttologp -logpout logp1 varcope1 cope1 `cat dof`
fslmaths logp1 -exp p1
fdr -i p1 -m ../mask -q 0.05
fslmaths p1 -mul -1 -add 1 -thr xxx -mas ../mask thresh_p1

	# for clarity, an alternative...

ttologp -logpout logp1 varcope1 cope1 `cat dof`
fslmaths logp1 -exp p1
fslmaths p1 -mul -1 -add 1 -mas ../mask p1_1minusp
fdr -i p1 -m ../mask -q 0.05
fslmaths p1_1minusp -thr xxx -mas ../mask thresh_p1

# Cluster

	# Defining cluster
cluster -i zstat1 -t 3.1 -o cluster_index --osize=cluster_size > cluster.txt
	# Extracting cluster from index
fslmaths -dt int cluster_index -thr 7 -uthr 7 -bin cluster_mask7
	# GRF thresholding
	# dlh and volume are found in the smoothness text file that feat generates
cluster -i zstat1 -t 3.1 -p 0.001 --dlh=0.318792 --volume=229291 -o cluster_index --osize=cluster_size > cluster.txt














