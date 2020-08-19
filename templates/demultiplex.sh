#!/bin/bash

for x in $(cat ${RUNS_TO_DEMUX_FILE}) ; do
  echo $x
  #Deletes shortest match of $substring '/*Complet*' from back of $x
  RUNPATH=$(echo ${x%/*Complet*})
  IFS='/'
  array=($RUNPATH)
  MACHINE="${array[3]}"
  RUN="${array[4]}"
  IFS=','

  echo $RUN
done
