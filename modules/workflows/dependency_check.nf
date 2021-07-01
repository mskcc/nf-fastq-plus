/**
 * Retrieves versions of software defined in nextflow.config
 */

include { log_out as out } from '../utils/log_out'
 
process task {
  output:
  stdout()

  shell:
  '''
  if [[ 1 -eq $(${PICARD} -h 2>&1 | grep "USAGE: PicardCommandLine" | wc -l) ]]; then
    echo "Valid PICARD: ${PICARD}"
  else
    echo "Invalid PICARD: ${PICARD}"
    exit 1
  fi
  if [[ 1 -eq $(${BWA} -h 2>&1 | grep "Program: bwa" | wc -l) ]]; then
    echo "Valid BWA: ${BWA}"
  else
    echo "Invalid BWA: ${BWA}"
    exit 1
  fi
  ${SAMTOOLS} --version
  if [[ 0 -eq $? ]]; then
    echo "Valid SAMTOOLS: ${SAMTOOLS}"
  else
    echo "Invalid SAMTOOLS: ${SAMTOOLS}"
  fi

  # All bin/*py scripst use the /usr/bin/env python, which require these packages
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
