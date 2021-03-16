#!/bin/bash

SKIP_KEYWORD="SKIP_"
if [[ -z ${SKIP_FILE_KEYWORD} ]]; then
  SKIP_KEYWORD=${SKIP_FILE_KEYWORD}
fi

MACHINE=$(echo ${RUN} | cut -d'_' -f2)  # 10309_MICHELLE_0347_BHWN55DMXX -> MICHELLE
RUN_NUM=$(echo ${RUN} | cut -d'_' -f3)  # 10309_MICHELLE_0347_BHWN55DMXX -> 0347
FLOWCELL=$(echo ${RUN} | cut -d'_' -f4) # 10309_MICHELLE_0347_BHWN55DMXX -> BHWN55DMXX
STAT_PREFIX="${MACHINE}_${RUN_NUM}_${FLOWCELL}"

STAT_FILES=$(find -L . -type f -name "*.txt" -exec readlink -f {} \;)
# echo "FILES_TO_UPLOAD: ${STAT_FILES}"
for stat_file in ${STAT_FILES}; do
  # SKIP_LINES were added because these steps were skipped in the workflow
  SKIP_LINE=$(cat ${stat_file} | grep "${SKIP_KEYWORD}")
  if [[ -z $SKIP_LINE ]]; then
    echo "Skipping ${stat_file}"
  else
    echo "Preparing ${stat_file} for upload"
    mkdir -p $STATSDONEDIR/$MACHINE
    cp $stat_file $STATSDONEDIR/$MACHINE
  fi
done

DELPHI_ENDPOINT="http://delphi.mskcc.org:8080/ngs-stats/picardstats/updaterun/${MACHINE}/${STAT_PREFIX}"
echo "Calling to update Picard stats DB: ${DELPHI_ENDPOINT}"
# TODO - uncomment
# curl "${DELPHI_ENDPOINT}"
sleep 10
LIMS_ENDPOINT="https://igo-lims02.mskcc.org:8443/LimsRest/updateLimsSampleLevelSequencingQc?runId=${STAT_PREFIX}"
echo "Calling to LIMS QC Metrics: ${LIMS_ENDPOINT}"
# TODO - uncomment
# curl -k ${LIMS_ENDPOINT}

# TODO - Remove GRCh37 BAM files when "PicardScripts"
# rm -rf SAM/*$PROJECTNUMBER*
echo ${STAT_PREFIX} | mail -s " Stats calculated for Run ${STAT_PREFIX} " streidd@mskcc.org # naborsd@mskcc.org mcmanamd@mskcc.org cobbsc@mskcc.org hubermak@mskcc.org vialea@mskcc.org
# sed -i "/$PROJECTNUMBER/d" ~/StatsTracker/$RUNNAME-Summary-File.txt
