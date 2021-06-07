include { log_out as out } from './log_out'

process task {
  label 'BSUB_OPTIONS_SMALL'

  tag "$INPUT_ID"

  input:
    path PARAMS
    env RUN_PARAMS_FILE

  output:
    stdout()

  shell:
    template 'create_sample_bams.sh'
}

workflow create_sample_bams_wkflw {
  take:
    PARAMS
    RUN_PARAMS_FILE
  main:
    task( PARAMS )
    out( task.out[0], "create_sample_bams" )
}
