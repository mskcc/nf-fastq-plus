include { log_out as out } from './log_out'

process task {
  memory '2 GB'

  input:
    path SAM_CH
    env RUN_TAG
    env PROJECT_TAG
    env SAMPLE_TAG

  output:
    stdout()

  shell:
    template 'add_replace_readgroups.sh'
}

workflow add_replace_readgroups_wkflw {
  take:
    SAM_CH
    RUN_TAG
    PROJECT_TAG
    SAMPLE_TAG
  main:
    task( SAM_CH, RUN_TAG, PROJECT_TAG, SAMPLE_TAG )
    out( task.out[0], "add_replace_readgroups" )
}
