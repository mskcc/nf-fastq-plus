include { log_out as out } from './log_out'

process task {
  label 'BSUB_OPTIONS_SMALL'

  input:
    path SAMPLESHEET_CH
    env CROSSCHECK_DIR
    path READY_TO_FINGERPRINT

  shell:
    template 'fingerprint.sh'
}

workflow fingerprint_wkflw {
  take:
    SAMPLESHEET_CH
    CROSSCHECK_DIR
    READY_TO_FINGERPRINT
  main:
    task( SAMPLESHEET_CH, CROSSCHECK_DIR, READY_TO_FINGERPRINT )
}

