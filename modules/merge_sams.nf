include { log_out as out } from './log_out'
 
process task {
  input:
  tuple env( RUN_TAG ), env( SAM_LIST )
 
  output:
  stdout()
  env RUN_TAG, emit: RUN_TAG
  path '*.bam', emit: BAM_CH

  shell:
  template 'merge_sams.sh'
}

workflow merge_sams_wkflw {
  take:
    sam
  main:
    task( sam )
    out( task.out[0], "merge_sams" )
  
  emit:
    BAM_CH = task.out.BAM_CH
    RUN_TAG = task.out.RUN_TAG
}
