include { log_out as out } from './log_out'

// Takes the value of an input directory and outputs all sample sheets that should be individually processed.
// We specifically name it "split_sample_sheet_task" because this process specifically needs to be run locally
// where the lab directory of sample sheets is mounted (it's not mounted on the other LSF nodes)
process split_sample_sheet_task {
  input:
    path PARAMS
    env RUN_TO_DEMUX_DIR

  output:
    stdout()
    path "${RUN_PARAMS_FILE}", emit: PARAMS
    path "${SPLIT_SAMPLE_SHEETS}", emit: SPLIT_SAMPLE_SHEETS
    env RUN_TO_DEMUX_DIR, emit: RUN_TO_DEMUX_DIR

  shell:
    template 'split_sample_sheet.sh'
}

workflow split_sample_sheet_wkflw {
  take:
    PARAMS
    runs_to_demux_path

  main:
    // splitText() will submit each line of @runs_to_demux_path seperately, i.e. allows for distributed tasks
    split_sample_sheet_task( runs_to_demux_path )
    out( split_sample_sheet_task.out[0], "split_sample_sheet" )

  emit:
    PARAMS = task.out.PARAMS
    SPLIT_SAMPLE_SHEETS = split_sample_sheet_task.out.SPLIT_SAMPLE_SHEETS
    RUN_TO_DEMUX_DIR = split_sample_sheet_task.out.RUN_TO_DEMUX_DIR
}


