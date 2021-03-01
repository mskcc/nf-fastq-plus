include { log_out as out } from './log_out'

process task {
  label 'BSUB_OPTIONS_SMALL'

  tag "$INPUT_ID"

  input:
    path PARAMS
    path BAM_CH
    val INPUT_ID

  output:
    stdout()

  shell:
    template 'collect_oxoG_metric.sh'
}

workflow collect_oxoG_metrics_wkflw {
  take:
    PARAMS
    BAM_CH
    INPUT_ID

  main:
    task( PARAMS, BAM_CH, INPUT_ID )
    out( task.out[0], "collect_oxoG_metrics" )
}
