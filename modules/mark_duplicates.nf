include { log_out as out } from './log_out'

process task {
  label 'BSUB_OPTIONS_LARGE'

  input:
  path PARAMS
  path BAM_CH

  output:
  stdout()
  path "${RUN_PARAMS_FILE}", emit: PARAMS
  path "*MD.bam", emit: MD_BAM_CH

  shell:
  template 'mark_duplicates.sh'
}

workflow mark_duplicates_wkflw {
  take:
    PARAMS
    BAM_CH

  main:
    task( PARAMS, BAM_CH )
    out( task.out[0], "mark_duplicates" )

  emit:
    PARAMS = task.out.PARAMS
    MD_BAM_CH = task.out.MD_BAM_CH
}
