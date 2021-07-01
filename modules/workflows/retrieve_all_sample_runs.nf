include { log_out as out } from '../utils/log_out'

process task {
  label 'LOCAL'

  input:
    env DEMUXED_DIR
    env ARCHIVED_DIR
    env RUNNAME

  output:
    stdout()
    path "run_samplesheet.txt", emit: RUNS_TO_ALIGN_FILE

  shell:
    template 'retrieve_all_sample_runs.sh'
}

workflow retrieve_all_sample_runs_wkflw {
  take:
    DEMUXED_DIR
    ARCHIVED_DIR
    RUNNAME
  main:
    task( DEMUXED_DIR, ARCHIVED_DIR, RUNNAME )
    out( task.out[0], "retrieve_all_sample_runs" )
  emit:
    RUNS_TO_ALIGN_FILE = task.out.RUNS_TO_ALIGN_FILE
}
