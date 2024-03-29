include { log_out as out } from '../utils/log_out'

process task {
  label 'BSUB_OPTIONS_LARGE'

  tag "$INPUT_ID"

  input:
    path PARAMS
    path BAM_CH
    val INPUT_ID
    env STATSDONEDIR

  output:
    stdout()
    path "*___gc_bias_metrics.txt", emit: METRICS_FILE

  shell:
    template 'collect_gc_bias_metrics.sh'
}

workflow collect_gc_bias_wkflw {
  take:
    PARAMS
    BAM_CH
    INPUT_ID
    STATSDONEDIR
  main:
    task( PARAMS, BAM_CH, INPUT_ID, STATSDONEDIR )
    out( task.out[0], "collect_gc_bias" )
  emit:
    METRICS_FILE = task.out.METRICS_FILE
}


