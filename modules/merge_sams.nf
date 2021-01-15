include { log_out as out } from './log_out'
 
process task {
  label 'BSUB_OPTIONS_LARGE'

  input:
  path PARAMS
  path SAM_LIST
 
  output:
  stdout()
  path "${RUN_PARAMS_FILE}", emit: PARAMS
  path '*.bam', emit: BAM_CH

  shell:
  template 'merge_sams.sh'
}

workflow merge_sams_wkflw {
  take:
    PARAMS
    SAM_FILES

  main:
    task( PARAMS, SAM_FILES )
    out( task.out[0], "merge_sams" )
  
  emit:
    PARAMS = task.out.PARAMS
    BAM_CH = task.out.BAM_CH
}