include { log_out as out } from './log_out'
 
process task {
  label 'BSUB_OPTIONS_LARGE'

  tag "$INPUT_ID"

  input:
  path PARAMS
  path SAM_LIST
  val INPUT_ID
 
  output:
  stdout()
  path "${RUN_PARAMS_FILE}", emit: PARAMS
  path '*.bam', emit: BAM_CH
  env SAMPLE_TAG, emit: SAMPLE_TAG

  shell:
  template 'merge_sams.sh'
}

workflow merge_sams_wkflw {
  take:
    PARAMS
    SAM_FILES
    INPUT_ID

  main:
    task( PARAMS, SAM_FILES, INPUT_ID )
    out( task.out[0], "merge_sams" )
  
  emit:
    PARAMS = task.out.PARAMS
    BAM_CH = task.out.BAM_CH
    OUTPUT_ID = task.out.SAMPLE_TAG
}
