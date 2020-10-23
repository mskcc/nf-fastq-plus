include { log_out as out } from './log_out'
 
process task {
  input:
  tuple env( prj_smp ), env( list_of_sams )
 
  output:
  stdout()

  shell:
  '''
  echo $prj_smp
  SAMS=${list_of_sams//[,[]}
  SAMS=${SAMS//]}
  for sam in $SAMS; do
    echo $sam
  done
  '''
}

workflow merge_wkflw {
  take:
    sam
  main:
    task( sam )
    out( task.out, "merge" )
  
  emit:
    out.out 
}
