#!/bin/sh

if [[ -z "$1" || -z "$2" ]]; then
  echo "./filter_commands.sh {LOG_FILE} {SAMPLE}"
fi

LOG_FILE=$1
SAMPLE=$2

if [[ ! -f ${LOG_FILE} ]]; then
  echo "$LOG_FILE isn't a file"
  exit 1
fi

echo "LOG_FILE=${LOG_FILE} SAMPLE=${SAMPLE}"

cat ${LOG_FILE} | grep ${SAMPLE} | grep -oP "(/igo/home/igo/Scripts/PicardScripts/picard|/home/igo/resources/picard2.21.8/picard.jar|/opt/common/CentOS_7/bwa/bwa-0.7.17/bwa).*" | sed -e 's/ /\n\t/g' 

