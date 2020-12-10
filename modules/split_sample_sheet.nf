include { log_out as out } from './log_out'

// Takes the value of an input directory and outputs all sample sheets that should be individually processed.
// We specifically name it "split_sample_sheet_task" because this process specifically needs to be run locally
// where the lab directory of sample sheets is mounted (it's not mounted on the other LSF nodes)
process split_sample_sheet_task {
  input:
    env RUN_TO_DEMUX_DIR

  output:
    stdout()
    path "${SPLIT_SAMPLE_SHEETS}"

  shell:
    template 'split_sample_sheet.sh'
}

workflow split_sample_sheet_wkflw {
  take: 
    runs_to_demux_path

  main:
    // splitText() will submit each line of @runs_to_demux_path seperately, i.e. allows for distributed tasks
    runs_to_demux_path.splitText().set{ run_ch }
    split_sample_sheet_task( run_ch ) 
    out( split_sample_sheet_task.out[0], "split_sample_sheet" )

  emit:
    split_sample_sheet_task.out[1]
}


