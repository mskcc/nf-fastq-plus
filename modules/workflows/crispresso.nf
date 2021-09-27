include { log_out as out } from '../utils/log_out'

process task {
  label 'BSUB_OPTIONS_SMALL'

  tag "$INPUT_ID"

  input:
    path PARAMS
    val INPUT_ID
    env STATSDONEDIR

  output:
    stdout()

  shell:
    template 'crispresso.sh'
}

workflow crispresso_wkflw {
  take:
    PARAMS
    INPUT_ID
    STATSDONEDIR

  main:
    task( DEMUXED_DIR, INPUT_ID, STATSDONEDIR )
    out( task.out[0], "crispresso_wkflw" )
}
