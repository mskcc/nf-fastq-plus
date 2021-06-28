include { log_out as out } from './log_out'

process task {
  publishDir PIPELINE_OUT, mode:'copy'

  label 'LOCAL'

  tag "$RUN_TAG"

  input:
    env DEMUXED_DIR
    env SAMPLESHEET
    val RUN_TAG
    env RUN_PARAMS_FILE
  output:
    stdout()
    path "*${RUN_PARAMS_FILE}", optional: true, emit: PARAMS
    env RUNNAME, emit: RUNNAME
  shell:
    template 'generate_run_params.sh'
}

workflow generate_run_params_wkflw {
  take:
    DEMUXED_DIR
    SAMPLESHEET
    RUN_PARAMS_FILE
  main:
    task( DEMUXED_DIR, SAMPLESHEET, DEMUXED_DIR, RUN_PARAMS_FILE )
    out( task.out[0], "generate_run_params" )
    task.out.PARAMS
      .flatten()
      .set{ SAMPLE_FILE_CH }
  emit:
    SAMPLE_FILE_CH = SAMPLE_FILE_CH
    RUNNAME = task.out.RUNNAME
}
