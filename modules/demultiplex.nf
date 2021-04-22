include { log_out as out } from './log_out'

// Takes the value of an input directory and outputs all sample sheets that should be individually processed
process task {
  label 'BSUB_OPTIONS_DEMUX'
  tag "$RUNNAME"
  clusterOptions = { "-M 6" }

  input:
    env SAMPLESHEET
    env RUN_TO_DEMUX_DIR
    val RUNNAME
    env CELL_RANGER_ATAC
    env DEMUX_ALL
    env DATA_TEAM_EMAIL

  output:
    stdout()
    env DEMUXED_DIR, emit: DEMUXED_DIR
    env SAMPLESHEET, emit: SAMPLESHEET

  shell:
    template 'demultiplex.sh'
}

workflow demultiplex_wkflw {
  take:
    split_sample_sheets_path
    RUN_TO_DEMUX_DIR
    RUNNAME
    CELL_RANGER_ATAC
    DEMUX_ALL
    DATA_TEAM_EMAIL

  main:
    // splitText() will submit each line (a split sample sheet .csv) of @split_sample_sheets_path seperately
    split_sample_sheets_path.splitText().set{ SPLIT_SAMPLE_SHEET_CH }
    task( SPLIT_SAMPLE_SHEET_CH, RUN_TO_DEMUX_DIR, RUNNAME, CELL_RANGER_ATAC, DEMUX_ALL, DATA_TEAM_EMAIL )
    out( task.out[0], "demultiplex" )

  emit:
    DEMUXED_DIR = task.out.DEMUXED_DIR
    SAMPLESHEET = task.out.SAMPLESHEET
}
