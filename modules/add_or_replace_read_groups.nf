include { log_out as out } from './log_out'

process task {
  memory '2 GB'

  input:
    env RUN_TAG
    env PROJECT_TAG
    env SAMPLE_TAG
    path SAM_LIST

  output:
    stdout()
    path '*.sam', emit: SAM_CH

  shell:
    template 'add_or_replace_read_groups.sh'
}

workflow add_or_replace_read_groups_wkflw {
  take:
    RUN_TAG
    PROJECT_TAG
    SAMPLE_TAG
    SAM_FILES
  main:
    task( RUN_TAG, PROJECT_TAG, SAMPLE_TAG, SAM_FILES )
    out( task.out[0], "add_or_replace_read_groups" )
  emit:
    SAM_CH = task.out.SAM_CH
}


