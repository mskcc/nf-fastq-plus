include { log_out as out } from './log_out'

process task {
  label 'BSUB_OPTIONS_SMALL'

  tag "$INPUT_ID"

  input:
    path PARAMS
    path BAM_FILES
    val INPUT_ID
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
    STATSDONEDIR
  main:
    task( PARAMS, BAM_FILES, INPUT_ID, STATSDONEDIR )
    out( task.out[0], "10x" )
  emit:
    LAUNCHED_CELLRANGER = task.out.LAUNCHED_CELLRANGER
}
