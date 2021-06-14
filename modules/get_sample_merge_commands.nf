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
    '''
    INPUT_FILE='run_bams.txt'
    if [[ -f ${INPUT_FILE} ]]; then
      echo "Couldn't find ${INPUT_FILE}. Exiting"
      exit 1
    fi

    bam_files=$(cat !{INPUT_FILE})
    OUTPUT_FILE="merge_commands.sh"
    create_merge_commands.py ${OUTPUT_FILE} ${RUNNAME} $bam_files
    '''
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
