include { log_out as out } from '../utils/log_out'

process task {
  label 'LOCAL'

  tag "$SAMPLE_ID"

  input:
    path PARAMS
    val SAMPLE_ID

  output:
    stdout()

  shell:
    template 'crispresso.sh'
}

workflow crispresso_wkflw {
  take:
    PARAMS
    SAMPLE_ID

  main:
    task( PARAMS, SAMPLE_ID )
    out( task.out[0], "crispresso_wkflw" )
}
