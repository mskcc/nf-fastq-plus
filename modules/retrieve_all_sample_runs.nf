include { log_out as out } from './log_out'

process task {
  label 'LOCAL'

  input:
    env DEMUXED_DIR
    env ARCHIVED_DIR

  output:
    stdout()
    path "run_samplesheet.txt", emit: RUNS_TO_ALIGN_FILE

  shell:
    template 'create_sample_bams.sh'
}

workflow retrieve_all_sample_runs_wkflw {
  take:
    DEMUXED_DIR
    ARCHIVED_DIR
  main:
    task( DEMUXED_DIR, ARCHIVED_DIR )
    out( task.out[0], "retrieve_all_sample_runs" )
  emit:
    RUNS_TO_ALIGN_FILE = task.out.RUNS_TO_ALIGN_FILE
}
