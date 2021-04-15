#!/bin/bash
# Uploads stat (.txt) files to ngs-stats & LIMS
# Nextflow Inputs:
#   Stat Files (in working directory) - .txt files
#   RUNNAME, env - Runname, e.g. MICHELLE_0347_BHWN55DMXX
#   STATSDONEDIR, env - Absolute path of where files should be written to
#   (SKIP_FILE_KEYWORD), env - txt to grep on to determine if file should be skipped, default: "SKIP_"
# Run: 
#   RUNNAME=MICHELLE_0347_BHWN55DMXX STATSDONEDIR=/igo/stats/DONE ./upload_stats.sh

SKIP_KEYWORD="SKIP_"
if [[ -z ${SKIP_FILE_KEYWORD} ]]; then
  SKIP_KEYWORD=${SKIP_FILE_KEYWORD}
fi

MACHINE=$(echo ${RUNNAME} | cut -d'_' -f1)  # MICHELLE_0347_BHWN55DMXX -> MICHELLE
RUN_NUM=$(echo ${RUNNAME} | cut -d'_' -f2)  # MICHELLE_0347_BHWN55DMXX -> 0347
FLOWCELL=$(echo ${RUNNAME} | cut -d'_' -f3) # MICHELLE_0347_BHWN55DMXX -> BHWN55DMXX
STAT_PREFIX="${MACHINE}_${RUN_NUM}_${FLOWCELL}"

STAT_FILES=$(find -L . -type f -name "*.txt" -exec readlink -f {} \;)

DESTINATION=$STATSDONEDIR/$MACHINE
mkdir -p ${DESTINATION}
echo "Copying stat files to ${DESTINATION}"

for stat_file in ${STAT_FILES}; do
  # SKIP_LINES were added because these steps were skipped in the workflow
  SKIP_LINE=$(cat ${stat_file} | grep "${SKIP_KEYWORD}")
  if [[ -z "$SKIP_LINE" ]]; then
    DESTINATION_FILE=$STATSDONEDIR/$MACHINE/$(basename ${stat_file})
    # If SKIP_KEYWORD isn't detected in the file, then we will prepare it for upload
    echo "Preparing ${stat_file} for upload: ${DESTINATION_FILE}"
    chmod 777 $stat_file
    cp $stat_file ${DESTINATION_FILE}
  else
    echo "Skipping ${stat_file}"
  fi
done

echo "START: $(date +"%D %T")"
DELPHI_ENDPOINT="http://delphi.mskcc.org:8080/ngs-stats/picardstats/updaterun/${MACHINE}/${STAT_PREFIX}"
echo "Updating Picard stats DB: ${DELPHI_ENDPOINT}"
curl "${DELPHI_ENDPOINT}"
sleep 10
LIMS_ENDPOINT="https://igo-lims02.mskcc.org:8443/LimsRest/updateLimsSampleLevelSequencingQc?runId=${STAT_PREFIX}"
printf "\nUpdating LIMS QC Metrics: ${LIMS_ENDPOINT}\n"
curl -k ${LIMS_ENDPOINT}
printf "\nEND: $(date +"%D %T")\n"

touch UPLOAD_DONE.txt

# TODO - Remove GRCh37 BAM files when "PicardScripts"
# rm -rf SAM/*$PROJECTNUMBER*
# sed -i "/$PROJECTNUMBER/d" ~/StatsTracker/$RUNNAME-Summary-File.txt
