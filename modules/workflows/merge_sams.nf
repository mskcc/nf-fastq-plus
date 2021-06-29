include { log_out as out } from '../utils/log_out'
 
process task {
  label 'BSUB_OPTIONS_LARGE'

  tag "$INPUT_ID"

  input:
    path PARAMS
    path SAM_LIST
    val INPUT_ID
    env RUN_PARAMS_FILE
    env CMD_FILE
    env PICARD
    env STATS_DIR
 
  output:
    stdout()
    path "${RUN_PARAMS_FILE}", emit: PARAMS
    path '*.bam', optional: true, emit: BAM_CH
    env SAMPLE_TAG, optional: true, emit: SAMPLE_TAG

  shell:
    template 'merge_sams.sh'
}

workflow merge_sams_wkflw {
  take:
    PARAMS
    SAM_FILES
    INPUT_ID
    RUN_PARAMS_FILE
    CMD_FILE
    PICARD
    STATS_DIR

  main:
    task( PARAMS, SAM_FILES, INPUT_ID, RUN_PARAMS_FILE, CMD_FILE, PICARD, STATS_DIR )
    out( task.out[0], "merge_sams" )
  
  emit:
    PARAMS = task.out.PARAMS
    BAM_CH = task.out.BAM_CH
    OUTPUT_ID = task.out.SAMPLE_TAG
}
