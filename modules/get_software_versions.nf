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
  printf "VERSIONS: PICARD $(echo ${picard})\n\n"
  '''
}

workflow get_software_versions_wkflw {
  main:
    task | out
  
  emit:
    out.out // Emits for downstream dependency, i.e. force other processes to come after
}
