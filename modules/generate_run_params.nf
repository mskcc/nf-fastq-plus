include { log_out as out } from './log_out'

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
    path "*${RUN_PARAMS_FILE}", emit: LANE_PARAM_FILES
  shell:
    '''
    # Hopefully this is just ONE file and we just send it along
    ls -ltr
    INPUT_FILE=$(ls *!{RUN_PARAMS_FILE})
    IDX=1
    # Write each line to a separate file
    while IFS= read -r line; do
      echo "$line"
      echo $line >> ${IDX}_${INPUT_FILE}
      let IDX=${IDX}+1
    done < "${INPUT_FILE}"
    ls -ltr
    # Get rid of original file so it isn't passed along
    rm $INPUT_FILE
    ls -ltr
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
    generate_run_params_task.out.PARAMS | flatten | create_sample_lane_jobs
  emit:
    LANE_PARAM_FILES = create_sample_lane_jobs.out.LANE_PARAM_FILES
}
