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
    env BCL2FASTQ
    env CELL_RANGER_ATAC
    env FASTQ_DIR
    env DEMUX_ALL
    env DATA_TEAM_EMAIL
    env CMD_FILE
    env DEMUX_LOG_FILE
    env EXECUTOR
    env LOCAL_MEM

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
    BCL2FASTQ
    CELL_RANGER_ATAC
    FASTQ_DIR
    DEMUX_ALL
    DATA_TEAM_EMAIL
    CMD_FILE
    DEMUX_LOG_FILE
    EXECUTOR
    LOCAL_MEM

  main:
    // splitText() will submit each line (a split sample sheet .csv) of @split_sample_sheets_path seperately
    split_sample_sheets_path
      .splitText()
      .multiMap { it ->
        SAMPLE_SHEET: it                                    // /path/to/SampleSheet.csv
        RUNNAME: it.split('/')[-1].tokenize(".")[0]         // SampleSheet
      }
      .set{ split_ch }
    task( split_ch.SAMPLE_SHEET, RUN_TO_DEMUX_DIR, split_ch.RUNNAME, BCL2FASTQ, CELL_RANGER_ATAC, FASTQ_DIR, DEMUX_ALL,
      DATA_TEAM_EMAIL, CMD_FILE, DEMUX_LOG_FILE, EXECUTOR, LOCAL_MEM )
    out( task.out[0], "demultiplex" )

  emit:
    DEMUXED_DIR = task.out.DEMUXED_DIR
    SAMPLESHEET = task.out.SAMPLESHEET
}
