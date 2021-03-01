include { log_out as out } from './log_out'

process task {
  label 'BSUB_OPTIONS_LARGE'
  tag "$INPUT_ID"

  input:
    path PARAMS
    path SAM_CH
    val INPUT_ID

  output:
    stdout()
    path "${RUN_PARAMS_FILE}", emit: PARAMS
    path '*.bam', emit: BAM_CH
    env SAMPLE_TAG, emit: SAMPLE_TAG

  shell:
    template 'add_or_replace_read_groups.sh'
}

workflow add_or_replace_read_groups_wkflw {
  take:
    PARAMS
    BAM_CH
  main:
    task( PARAMS, BAM_CH )
    out( task.out[0], "add_or_replace_read_groups" )
  emit:
    PARAMS = task.out.PARAMS
    BAM_CH = task.out.BAM_CH
    OUTPUT_ID = task.out.SAMPLE_TAG
}
