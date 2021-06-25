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

  main:
    // splitText() will submit each line (a split sample sheet .csv) of @split_sample_sheets_path seperately
    split_sample_sheets_path
      .splitText()
      .multiMap { it ->
        SAMPLE_SHEET: it                                    // /path/to/SampleSheet.csv
        RUNNAME: it.split('/')[-1].tokenize(".")[0]         // SampleSheet
      }
      .set{ split_ch }
    task( split_ch.SAMPLE_SHEET, RUN_TO_DEMUX_DIR, split_ch.RUNNAME )
    out( task.out[0], "demultiplex" )

  emit:
    DEMUXED_DIR = task.out.DEMUXED_DIR
    SAMPLESHEET = task.out.SAMPLESHEET
}
