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
    path "*.bam", emit: BAM_CH
    env SAMPLE_TAG, emit: SAMPLE_TAG
    path "${RUN_PARAMS_FILE}", optional: true, emit: PARAMS
    path "*___MD.txt", optional: true, emit: METRICS_FILE

  shell:
  template 'mark_duplicates.sh'
}

workflow mark_duplicates_wkflw {
  take:
    PARAMS
    BAM_CH
    INPUT_ID

  main:
    task( PARAMS, BAM_CH, INPUT_ID )
    out( task.out[0], "mark_duplicates" )

  emit:
    BAM_CH = task.out.BAM_CH
    OUTPUT_ID = task.out.SAMPLE_TAG
    PARAMS = task.out.PARAMS
    METRICS_FILE = task.out.METRICS_FILE
}
