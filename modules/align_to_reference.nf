include { log_out as out } from './log_out'

process task {
  input:
    env REFERENCE
    env FASTQ1
    env FASTQ2
    env TYPE
    env PAIRED_END

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
    PAIRED_END
  main:
    task( stats_params )
    out( task.out[0], "align_to_reference" )

  emit:
    task.out[1]
}


