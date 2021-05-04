include { log_out as out } from './log_out'

process task {
  label 'BSUB_OPTIONS_SMALL'

  tag "$INPUT_ID"

  input:
    path PARAMS
    path BAM_FILES
    val INPUT_ID
    env RUN_PARAMS_FILE
    env CMD_FILE
    env PICARD
    env STATSDONEDIR

  output:
    stdout()

  shell:
    template 'cellranger.sh'
}

workflow cellranger_wkflw {
  take:
    PARAMS
    BAM_FILES
    INPUT_ID
    RUN_PARAMS_FILE
    CMD_FILE
    PICARD
    STATSDONEDIR
  main:
    task( PARAMS, BAM_FILES, INPUT_ID, RUN_PARAMS_FILE, CMD_FILE, PICARD, STATSDONEDIR )
    out( task.out[0], "10x" )
}
