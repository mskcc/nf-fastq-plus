include { log_out as out } from './log_out'
include { log_out as out2 } from './log_out'
include { write_params } from './write_params'

process task {
  publishDir PIPELINE_OUT, mode:'copy'

  input:
    env RUNNAME
    env DEMUXED_DIR
    env SAMPLESHEET
  output:
    stdout()
    path "${RUN_PARAMS_FILE}", emit: PARAMS
  shell:
    template 'generate_run_params.sh'
}

workflow generate_run_params_wkflw {
  take:
    RUNNAME
    DEMUXED_DIR
    SAMPLESHEET
  main:
    task( RUNNAME, DEMUXED_DIR, SAMPLESHEET )
    task.out.PARAMS.splitText().set{ params_ch }
    write_params( params_ch )
    out( task.out[0], "generate_run_params" )
    out2( write_params.out[0], "generate_run_params" )
  emit:
    PARAMS = write_params.out.PARAMS
}


