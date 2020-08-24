/**
 * Retrieves versions of software defined in nextflow.config
 */

include { log_out as out } from './log_out'
 
process task {
  output:
  stdout()

  shell:
  '''
  echo "Starting Run $(date)"
  echo "VERSIONS: BWA $(${bwa} 2>&1 | grep "Version")"
  echo "VERSIONS: PICARD $(echo ${picard})"
  '''
}

workflow dependency_check_wkflw {
  main:
    task()
    out( task.out, "dependency_check" )
  
  emit:
    out.out // Emits for downstream dependency, i.e. force other processes to come after
}
