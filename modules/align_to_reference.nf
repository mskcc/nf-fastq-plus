include { log_out as out } from './log_out'

process task {
  memory '2 GB'

  input:
    env REFERENCE
    path FASTQ_CH
    env TYPE
    env DUAL

  output:
    stdout()

  shell:
    template 'align_to_reference.sh'
}

workflow align_to_reference_wkflw {
  take:
    REFERENCE
    FASTQ_CH
    TYPE
    DUAL
  main:
    task( REFERENCE, FASTQ_CH, TYPE, DUAL )
    out( task.out[0], "align_to_reference" )

  emit:
    task.out[1]
}


