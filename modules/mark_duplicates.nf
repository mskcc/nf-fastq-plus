include { log_out as out } from './log_out'

process task {
  label 'BSUB_OPTIONS_LARGE'
  tag "$INPUT_ID"

  input:
    path PARAMS
    path BAM_CH
    val INPUT_ID
    env SKIP_FILE_KEYWORD

  output:
    stdout()
    path "${RUN_PARAMS_FILE}", emit: PARAMS
    path "*MD.bam", emit: MD_BAM_CH
    env SAMPLE_TAG, emit: SAMPLE_TAG
    path "*___MD.txt", emit: METRICS_FILE

  shell:
  template 'mark_duplicates.sh'
}

workflow mark_duplicates_wkflw {
  take:
    PARAMS
    BAM_CH
    INPUT_ID
    SKIP_FILE_KEYWORD

  main:
    task( PARAMS, BAM_CH, INPUT_ID, SKIP_FILE_KEYWORD )
    out( task.out[0], "mark_duplicates" )

  emit:
    PARAMS = task.out.PARAMS
    MD_BAM_CH = task.out.MD_BAM_CH
    OUTPUT_ID = task.out.SAMPLE_TAG
    METRICS_FILE = task.out.METRICS_FILE
}
