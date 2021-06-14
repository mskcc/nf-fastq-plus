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
  echo "BWA: $(${BWA} 2>&1 | grep "Version")"
  echo "PICARD: $(echo ${PICARD})"

  required_python_packages="requests pandas"
  for pkg in ${required_python_packages}; do
    if [[ -z ${pkg} ]]; then
      echo "/usr/bin/env python missing package: ${pkg}"
      exit 1
    fi
  done
  '''
}

workflow dependency_check_wkflw {
  main:
    task()
    out( task.out, "dependency_check" )
  
  emit:
    out.out // Emits for downstream dependency, i.e. force other processes to come after
}
