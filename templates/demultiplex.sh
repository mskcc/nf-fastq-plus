#!/bin/bash
# Submits demultiplexing jobs
# Nextflow Inputs:
#   RUN_TO_DEMUX_DIR: Absolute path to directory of the Run to demux (Defined as input in nextflow process)
# Nextflow Outputs:
#   DEMUXED_RUN: Name of run to demux, given by the name of @RUN_TO_DEMUX_DIR
# Run: 
#   RUN_TO_DEMUX_DIR=/igo/sequencers/michelle/200814_MICHELLE_0249_AHMNCJDRXX ./demultiplex.sh

printf "RUN_TO_DEMUX_DIR=${RUN_TO_DEMUX_DIR}"

#Deletes shortest match of $substring '/*Complet*' from back of $x
RUNPATH=$(echo ${RUN_TO_DEMUX_DIR%/*Complet*})
IFS='/'
array=($RUNPATH)
MACHINE="${array[3]}"
DEMUXED_RUN="${array[4]}" # EXPORT TO NEXT NEXTFLOW PROCESS
IFS=','
# TODO - Demultiplexing


