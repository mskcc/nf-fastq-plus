#!/bin/bash

for run in $(cat ${RUNS_TO_DEMUX_FILE}) ; do
  #Deletes shortest match of $substring '/*Complet*' from back of $x
  RUNPATH=$(echo ${run%/*Complet*})
  IFS='/'
  array=($RUNPATH)
  MACHINE="${array[3]}"
  RUN="${array[4]}"
  IFS=','
done
