include { log_out as out } from './log_out'

process task {
  label 'LOCAL'

  input:
    path BAM_LIST_FILE
    env RUNNAME

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

  main:
    task( BAM_LIST_FILE, RUNNAME )
    out( task.out[0], "get_sample_merge_commands" )

  emit:
    MERGE_COMMANDS = task.out.MERGE_COMMANDS
}
