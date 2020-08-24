# !/bin/bash
# Configures FASTQ stats from input Runname
# Nextflow Inputs:
#   DEMUXED_RUN (Input): Name of run that has been demultiplexed
#   SAMPLE_SHEET_DIR (Config): Absolute path to where Sample Sheet for @DEMUXED_RUN will be found
#   STATS_DIR (Config): Absolute path to where stats should be written
# Nextflow Outputs:
#   TODO
# Run: 
#   STATSDIR=/igo/stats RUN=MICHELLE_0246_BHG7L2DSXY SAMPLE_SHEET_DIR=/home/igo/SampleSheetCopies templates/launch_stats.sh

STATSDIR=${STATS_DIR}
RUN=${DEMUXED_RUN}	

SAMPLESHEET=$(find ${SAMPLE_SHEET_DIR} -type f -name "SampleShee*$RUN.csv")
function get_run_type () {
  ROWS=$(sed -n "/Reads/,/Settings/p" $SAMPLESHEET | wc -l)
  if [[ "$ROWS" < 5  ]]; then
    echo "SE"
  else
    echo "PE"
  fi
}

function get_project_species_recipe() {
  if [[ "$DUAL" == "" ]]; then
    awk '{if(found) print} /Lane/{found=1}' $SAMPLESHEET | awk 'BEGIN { FS = "," } ;{printf"%s\t%s\t%s\n",$8,$4,$5}' | sort | uniq
  else
    awk '{if(found) print} /Lane/{found=1}' $SAMPLESHEET | awk 'BEGIN { FS = "," } ;{printf"%s\t%s\t%s\n",$9,$4,$5}' | sort | uniq
  fi
}

if [[ $(echo ${SAMPLESHEET} | wc -l) -eq 0 ]]; then
  echo "No SampleSheet found for Run: ${RUN}"
  # TODO - Alert
else
  RUN_TYPE=$(get_run_type)
  RUNNAME=$(echo $RUN | awk '{pos=match($0,"_"); print (substr($0,pos+1,length($0)))}')
  #If dual barcode (column index2 exists) then
  DUAL=$(cat $SAMPLESHEET |  awk '{pos=match($0,"index2"); if (pos>0) print pos}')

  echo "Launching RunName: ${RUNNAME}, Run: ${RUN}, SampleSheet: ${SAMPLESHEET}, RunType: ${RUN_TYPE}, Dual Index: ${DUAL}"

  # Tab-delimited project, species, recipe variable,
  #   e.g. "Project_08822_HF	Human	HumanWholeGenome"
  prj_spc_rec=$(get_project_species_recipe)

  IFS=$'\n'
  for psr in $prj_spc_rec; do
    PROJECT=$(echo $psr | awk '{printf"%s\n",$1}' );
    SPECIES=$(echo $psr | awk '{printf"%s\n",$2}' );
    RECIPE=$(echo $psr | awk '{printf"%s\n",$3}' );
    echo "SampleSheet Extraction - Project: ${PROJECT}, Species: ${SPECIES}, Recipe: ${RECIPE}"
    generate_run_params.py -r ${RECIPE} -s ${SPECIES} # Python scripts in bin of project root
  done
  IFS=' \t\n'
  
fi









