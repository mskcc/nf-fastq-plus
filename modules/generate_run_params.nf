include { log_out as out } from './log_out'
include { log_out as out2 } from './log_out'

process task {
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
    tuple env SAMPLE_NAME, path SAMPLE_FILE
  output:
    path "*${RUN_PARAMS_FILE}", emit: LANE_PARAM_FILES
  shell:
    '''
    # Hopefully this is just ONE file and we just send it along
    ls -ltr
    INPUT_FILE=$(ls *!{RUN_PARAMS_FILE})
    IDX=1
    for line in $(cat $INPUT_FILE); do
      echo $line
      cp $f ${IDX}_${INPUT_FILE}
      let IDX=${IDX}+1
    done
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
    task( RUNNAME, DEMUXED_DIR, SAMPLESHEET, RUN_PARAMS_FILE )
    out( task.out[0], "generate_run_params" )
    // We need to process each sample_file on its own rather than all samples of the run at once
    task.out.PARAMS
      .map { file ->
        def key = file.name.toString().tokenize('___').get(0)
        return tuple(key, file)
      }
      .groupTuple()
      .set{ SAMPLE_PARAMS }
    emit_sample_job( SAMPLE_PARAMS }
  emit:
    LANE_PARAM_FILES = emit_sample_job.out.LANE_PARAM_FILES
}
