include { log_out as out } from './log_out'

process task {
  label 'BSUB_OPTIONS_SMALL'

  tag "$INPUT_ID"

  input:
    path PARAMS
    path BAM_FILES
    val INPUT_ID
    env SKIP_FILE_KEYWORD

  output:
    stdout()
    path "*___WGS.txt", emit: METRICS_FILE

  shell:
    template 'collect_wgs_metrics.sh'
}

workflow collect_wgs_metrics_wkflw {
  take:
    PARAMS
    BAM_CH
    INPUT_ID
    SKIP_FILE_KEYWORD

  main:
    task( PARAMS, BAM_CH, INPUT_ID, SKIP_FILE_KEYWORD )
    out( task.out[0], "collect_wgs_metrics" )

  emit:
    METRICS_FILE = task.out.METRICS_FILE
}
