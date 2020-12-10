include { log_out as out } from './log_out'

// Takes the value of an input directory and outputs all sample sheets that should be individually processed
process task {
  input:
    env SAMPLESHEET

  output:
    stdout()
    env FASTQ_DIR, emit: FASTQ_DIR

  shell:
    template 'demultiplex.sh'
}

workflow demultiplex_wkflw {
  take: 
    split_sample_sheets_path

  main:
    // splitText() will submit each line (a split sample sheet .csv) of @split_sample_sheets_path seperately
    split_sample_sheets_path.splitText().set{ SPLIT_SAMPLE_SHEET_CH }
    task( SPLIT_SAMPLE_SHEET_CH ) 
    out( task.out[0], "demultiplex" )

  emit:
    FASTQ_DIR = task.out.FASTQ_DIR
}
