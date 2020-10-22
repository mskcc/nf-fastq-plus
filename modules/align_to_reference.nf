include { log_out as out } from './log_out'

process task {
  memory '2 GB'

  input:
    env REFERENCE
    path FASTQ_CH
    env TYPE
    env DUAL
    env RUN_TAG
    env PROJECT_TAG
    env SAMPLE_TAG

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
    RUN_TAG
    PROJECT_TAG
    SAMPLE_TAG
  main:
    task( REFERENCE, FASTQ_CH, TYPE, DUAL, RUN_TAG, PROJECT_TAG, SAMPLE_TAG )
    out( task.out[0], "align_to_reference" )

  emit:
    SAM_CH = task.out.SAM_CH
}


