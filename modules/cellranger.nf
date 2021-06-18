include { log_out as out } from './log_out'

process task {
  label 'BSUB_OPTIONS_SMALL'

  tag "$INPUT_ID"

  input:
    path PARAMS
    path BAM_FILES
    val INPUT_ID
    env CELL_RANGER_ATAC
    env CELL_RANGER
    env CELL_RANGER_CNV
    env RUN_PARAMS_FILE
    env CMD_FILE
    env PICARD
    env STATSDONEDIR

  output:
    stdout()
    path "launched_cellranger_dirs.txt", emit: LAUNCHED_CELLRANGER

  shell:
    template 'cellranger.sh'
}

workflow cellranger_wkflw {
  take:
    PARAMS
    BAM_FILES
    INPUT_ID
    CELL_RANGER_ATAC
    CELL_RANGER
    CELL_RANGER_CNV
    RUN_PARAMS_FILE
    CMD_FILE
    PICARD
    STATSDONEDIR
  main:
    task( PARAMS, BAM_FILES, INPUT_ID, CELL_RANGER_ATAC, CELL_RANGER, CELL_RANGER_CNV, RUN_PARAMS_FILE, CMD_FILE, PICARD,
      STATSDONEDIR )
    out( task.out[0], "10x" )
  emit:
    LAUNCHED_CELLRANGER = task.out.LAUNCHED_CELLRANGER
}
