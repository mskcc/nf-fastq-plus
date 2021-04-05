include { log_out as out } from './log_out'

process task {
  label 'BSUB_OPTIONS_SMALL'

  input:
    env SAMPLESHEET
    env CROSSCHECK_DIR

  shell:
    template 'fingerprint.sh'
}

workflow fingerprint_wkflw {
  take:
    SAMPLE_SHEET_LIST
    CROSSCHECK_DIR
    READY_TO_FINGERPRINT
  main:
    // splitText() will submit each line (a split sample sheet .csv) of @split_sample_sheets_path separately
    SAMPLE_SHEET_LIST.splitText().set{ SPLIT_SAMPLE_SHEET_CH }
    task( SPLIT_SAMPLE_SHEET_CH, CROSSCHECK_DIR )
    out( task.out[0], "fingerprint" )
}

