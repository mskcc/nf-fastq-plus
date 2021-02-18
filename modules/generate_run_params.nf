include { log_out as out } from './log_out'
include { log_out as out2 } from './log_out'

process generate_run_params_task {
  publishDir PIPELINE_OUT, mode:'copy'

  input:
    env RUNNAME
    env DEMUXED_DIR
    env SAMPLESHEET
    env RUN_PARAMS_FILE
  output:
    stdout()
    path "*${RUN_PARAMS_FILE}", emit: PARAMS
  shell:
    template 'generate_run_params.sh'
}

process create_sample_lane_jobs {
  input:
    path SAMPLE_FILE
  output:
    stdout()
    path "*${RUN_PARAMS_FILE}", emit: LANE_PARAM_FILES
  shell:
    '''
    # Hopefully this is just ONE file and we just send it along
    ls -ltr
    INPUT_FILE=$(ls *!{RUN_PARAMS_FILE})
    IDX=1
    # Write each line to a separate file
    while IFS= read -r line; do
      LANE_FILE=${IDX}_${INPUT_FILE}
      echo $line >> ${LANE_FILE}
      echo "Created Lane File: ${LANE_FILE}"
      echo "$line"

      let IDX=${IDX}+1
    done < "${INPUT_FILE}"
    ls -ltr
    # Get rid of original file so it isn't passed along
    echo "Lane sample param files created. Removing original ${INPUT_FILE}"
    rm $INPUT_FILE
    '''
}

workflow generate_run_params_wkflw {
  take:
    RUNNAME
    DEMUXED_DIR
    SAMPLESHEET
    RUN_PARAMS_FILE
  main:
    generate_run_params_task( RUNNAME, DEMUXED_DIR, SAMPLESHEET, RUN_PARAMS_FILE )
    out( generate_run_params_task.out[0], "generate_run_params" )
    generate_run_params_task.out.PARAMS
      .flatten()
      .set{ SAMPLE_FILE_CH }
    create_sample_lane_jobs( SAMPLE_FILE_CH )
    out2( create_sample_lane_jobs.out[0], "create_sample_lane_jobs" )
  emit:
    LANE_PARAM_FILES = create_sample_lane_jobs.out.LANE_PARAM_FILES
}
