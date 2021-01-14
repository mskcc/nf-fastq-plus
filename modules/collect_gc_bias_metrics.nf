include { log_out as out } from './log_out'

process task {
  label 'BSUB_OPTIONS_LARGE'

  input:
    path PARAMS
    path BAM_CH

  output:
    stdout()

  shell:
    template 'collect_gc_bias_metrics.sh'
}

workflow collect_gc_bias_wkflw {
  take:
    PARAMS
    BAM_CH
  main:
    task( PARAMS, BAM_CH )
    out( task.out[0], "collect_gc_bias" )
}


