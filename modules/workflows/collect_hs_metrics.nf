include { log_out as out } from '../utils/log_out'

process task {
  label 'BSUB_OPTIONS_SMALL'

  tag "$INPUT_ID"

  input:
    path PARAMS
    path BAM_FILES
    val INPUT_ID
    env STATSDONEDIR

  output:
    stdout()
    path "*___HS.txt", emit: METRICS_FILE

  shell:
    template 'collect_hs_metrics.sh'
}

workflow collect_hs_metrics_wkflw {
  take:
    PARAMS
    BAM_CH
    INPUT_ID
    STATSDONEDIR

  main:
    task( PARAMS, BAM_CH, INPUT_ID, STATSDONEDIR )
    out( task.out[0], "collect_hs_metrics" )

  emit:
    METRICS_FILE = task.out.METRICS_FILE
}
