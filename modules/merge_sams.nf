include { log_out as out } from './log_out'
 
process task {
  input:
  tuple env( PRJ_SMP ), env( SAM_LIST )
 
  output:
  stdout()

  shell:
  template 'merge_sams.sh'
}

workflow merge_sams_wkflw {
  take:
    sam
  main:
    task( sam )
    out( task.out, "merge_sams" )
  
  emit:
    out.out 
}
