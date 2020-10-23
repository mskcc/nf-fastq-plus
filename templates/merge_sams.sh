#!/bin/bash
# Submits an alignment to the reference
# Nextflow Inputs:
#   PRJ_SMP,  Key used to group all SAM files
#   SAM_LIST, Stringified Java List of SAM files 
# Nextflow Outputs:
#   TODO
# Run:
#   TODO

# TODO

echo $PRJ_SMP
SAMS=${SAM_LIST//[,[\]]}
# SAMS=${SAMS//]}
for sam in $SAMS; do
  echo $sam
done
