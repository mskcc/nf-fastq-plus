include { log_out as out } from './log_out'
 
process task {
  input:
  env RUN_TAG
  path SAM_LIST
 
  output:
  stdout()
  env RUN_TAG, emit: RUN_TAG
  path '*.bam', emit: BAM_CH

  shell:
  template 'merge_sams.sh'
}

workflow merge_sams_wkflw {
  take:
    RUN_TAG
    SAM_FILES
  main:
    task( RUN_TAG, SAM_FILES )
    out( task.out[0], "merge_sams" )
  
  emit:
    BAM_CH = task.out.BAM_CH
    RUN_TAG = task.out.RUN_TAG
}
