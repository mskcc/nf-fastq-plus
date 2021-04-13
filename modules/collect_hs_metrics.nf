include { log_out as out } from './log_out'

process task {
  label 'BSUB_OPTIONS_SMALL'

  tag "$INPUT_ID"

  input:
    path PARAMS
    path BAM_FILES
    val INPUT_ID

  output:
    stdout()
    path "*___HS.txt", optional: true, emit: METRICS_FILE

  shell:
    template 'collect_hs_metrics.sh'
}

workflow collect_hs_metrics_wkflw {
  take:
    PARAMS
    BAM_CH
    INPUT_ID

  main:
    task( PARAMS, BAM_CH, INPUT_ID )
    out( task.out[0], "collect_hs_metrics" )

  emit:
    METRICS_FILE = task.out.METRICS_FILE
}
