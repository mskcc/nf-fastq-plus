include { log_out as out } from './log_out'

process task {
  label 'BSUB_OPTIONS_SMALL'

  input:
    path PARAMS
    path BAM_CH

  output:
    stdout()

  shell:
    template 'collect_oxoG_metric.sh'
}

workflow collect_oxoG_metrics_wkflw {
  take:
    PARAMS
    BAM_CH

  main:
    task( PARAMS, BAM_CH )
    out( task.out[0], "collect_oxoG_metrics" )
}
