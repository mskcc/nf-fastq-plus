include { log_out as out } from '../utils/log_out'

process task {
  label 'BSUB_OPTIONS_SMALL'

  tag "$INPUT_ID"

  input:
    path PARAMS
    val PARAMS

  output:
    stdout()

  shell:
    template 'crispresso.sh'
}

workflow crispresso_wkflw {
  take:
    PARAMS

  main:
    task( PARAMS, PARAMS )
    out( task.out[0], "crispresso_wkflw" )
}
