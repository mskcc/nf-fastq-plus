include { log_out as out } from './log_out'

process task {
  input:
  path MRG_BAM
  env RUN_TAG
  env MD
  env RUNNAME

  output:
  path "*MD.bam", emit: MD_BAM_CH
  stdout()

  shell:
  template 'mark_duplicates.sh'
}

workflow mark_duplicates_wkflw {
  take:
    BAM_CH
    RUN_TAG
    MD
    RUNNAME
  main:
    task( BAM_CH, RUN_TAG, MD, RUNNAME )
    out( task.out[1], "mark_duplicates" )

  emit:
    task.out.MD_BAM_CH
}
