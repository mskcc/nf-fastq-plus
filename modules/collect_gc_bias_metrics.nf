include { log_out as out } from './log_out'

process task {
  label 'BSUB_OPTIONS_LARGE'

  tag "$INPUT_ID"

  input:
    path PARAMS
    path BAM_CH
    val INPUT_ID

  output:
    stdout()

  shell:
    template 'collect_gc_bias_metrics.sh'
}

workflow collect_gc_bias_wkflw {
  take:
    PARAMS
    BAM_CH
    INPUT_ID
  main:
    task( PARAMS, BAM_CH, INPUT_ID )
    out( task.out[0], "collect_gc_bias" )
}


