/**
 * Retrieves versions of software defined in nextflow.config
 */

include log_out from './log_out'

process get_software_versions {
  output:
  stdout()

  shell:
  '''
  printf "\nStarting Run $(date)\n"
  echo "VERSIONS: BWA $(${bwa} 2>&1 | grep "Version")"
  echo "VERSIONS: PICARD $(echo ${picard})"
  '''
}

workflow get_software_versions_wkflw {
  main:
    get_software_versions | log_out
}
