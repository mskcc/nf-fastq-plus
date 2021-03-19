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
    path "*___AM.txt", emit: METRICS_FILE

  shell:
    template 'collect_alignment-summary_metrics.sh'
}

workflow alignment_summary_wkflw {
  take:
    PARAMS
    BAM_FILES
    INPUT_ID
    SKIP_FILE_KEYWORD
  main:
    task( PARAMS, BAM_FILES, INPUT_ID, SKIP_FILE_KEYWORD )
    out( task.out[0], "collect_alignment-summary_metrics" )
  emit:
    METRICS_FILE = task.out.METRICS_FILE
}

