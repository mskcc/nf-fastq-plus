include { log_out as out } from './log_out'

process task {
  input:
    env REFERENCE
    env FASTQ1
    env FASTQ2
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
    FASTQ1
    FASTQ2
    TYPE
    DUAL
  main:
    task( REFERENCE, FASTQ1, FASTQ2, TYPE, DUAL )
    out( task.out[0], "align_to_reference" )

  emit:
    task.out[1]
}


