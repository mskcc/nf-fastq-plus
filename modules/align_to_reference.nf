include { log_out as out } from './log_out'

process task {
  input:
    env GENOME
    env REFERENCE
    env REF_FLAT
    env RIBOSOMAL_INTERVALS
    env FASTQ1
    env FASTQ2
    env REFERENCE
    env GENOME
    env BAITS
    env TARGETS
    env MSKQ
    env MD
    env TYPE

  output:
    stdout()

  shell:
    template 'align_to_reference.sh'
}

workflow align_to_reference_wkflw {
  take:
    stats_params

  main:
    task( stats_params )
    out( task.out[0], "align_to_reference" )

  emit:
    task.out[1]
}


