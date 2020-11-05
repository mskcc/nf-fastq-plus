include { log_out as out } from './log_out'

process task {
  memory '2 GB'

  input:
    env REFERENCE
    path FASTQ_CH
    env TYPE
    env DUAL
    env PROJECT_TAG
    env SAMPLE_TAG
    env RUN_TAG

  output:
    stdout()
    path '*.sam', emit: SAM_CH

  shell:
    template 'align_to_reference.sh'
}

workflow align_to_reference_wkflw {
  take:
    REFERENCE
    FASTQ_CH
    TYPE
    DUAL
    PROJECT_TAG
    SAMPLE_TAG
    RUN_TAG
  main:
    task( REFERENCE, FASTQ_CH, TYPE, DUAL, PROJECT_TAG, SAMPLE_TAG, RUN_TAG )
    out( task.out[0], "align_to_reference" )

  emit:
    SAM_CH = task.out.SAM_CH
}


