include { log_out as out } from '../utils/log_out'

process task {
  label 'BSUB_OPTIONS_LARGE'
  tag "$INPUT_ID"

  input:
    path PARAMS
    path BAM_CH
    val INPUT_ID
    env RUN_PARAMS_FILE
    env CMD_FILE
    env PICARD
    env STATSDONEDIR
    env STATS_DIR

  output:
    stdout()
    path "STATS___*.bam", emit: BAM_CH
    env SAMPLE_TAG, emit: SAMPLE_TAG
    path "${RUN_PARAMS_FILE}", emit: PARAMS
    path "*___MD.txt", emit: METRICS_FILE

  shell:
  template 'mark_duplicates.sh'
}

workflow mark_duplicates_wkflw {
  take:
    PARAMS
    BAM_CH
    INPUT_ID
    RUN_PARAMS_FILE
    CMD_FILE
    PICARD
    STATSDONEDIR
    STATS_DIR

  main:
    task( PARAMS, BAM_CH, INPUT_ID, RUN_PARAMS_FILE, CMD_FILE, PICARD, STATSDONEDIR, STATS_DIR )
    out( task.out[0], "mark_duplicates" )

  emit:
    BAM_CH = task.out.BAM_CH
    OUTPUT_ID = task.out.SAMPLE_TAG
    PARAMS = task.out.PARAMS
    METRICS_FILE = task.out.METRICS_FILE
}
