include { log_out as out } from './utils/log_out'

process task {
  label 'LOCAL'

  input:
    path BAM_LIST_FILE
    env RUNNAME
    env SAMPLE_BAM_DIR

  output:
    stdout()
    path "merge_commands.sh", emit: MERGE_COMMANDS

  shell:
    template 'get_sample_merge_commands.sh'
}

workflow get_sample_merge_commands_wkflw {
  take:
    BAM_LIST_FILE
    RUNNAME
    SAMPLE_BAM_DIR

  main:
    task( BAM_LIST_FILE, RUNNAME, SAMPLE_BAM_DIR )
    out( task.out[0], "get_sample_merge_commands" )

  emit:
    MERGE_COMMANDS = task.out.MERGE_COMMANDS
}
