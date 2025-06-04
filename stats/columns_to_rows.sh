#!/bin/bash

# Adapted from this post: https://stackoverflow.com/questions/1729824/an-efficient-way-to-transpose-a-file-in-bash

# Turn columns into rows, replace spaces with commas.
# This prepares interrogation.sh-output for R-scripts

# Give the location of a *_temp file
input=$1
# Give the location and name of the new file, eg. *_temp_col
output=$2

awk '
{ 
    for (i=1; i<=NF; i++)  {
        a[NR,i] = $i
    }
}
NF>p { p = NF }
END {    
    for(j=1; j<=p; j++) {
        str=a[1,j]
        for(i=2; i<=NR; i++){
            str=str" "a[i,j];
        }
        print str
    }
}' ${input} | tr -s '[:blank:]' ' ' > ${output}

