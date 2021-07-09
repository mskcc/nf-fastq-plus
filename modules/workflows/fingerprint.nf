include { log_out as out } from '../utils/log_out'

process task {
  label 'BSUB_OPTIONS_SMALL'

  input:
    env SAMPLESHEET
    path READY_TO_FINGERPRINT

  shell:
    template 'fingerprint.sh'
}

workflow fingerprint_wkflw {
  take:
    SAMPLESHEET
    READY_TO_FINGERPRINT
  main:
    task( SAMPLESHEET, READY_TO_FINGERPRINT )
}

