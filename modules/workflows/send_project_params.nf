include { log_out as out } from '../utils/log_out'

process task {
  input:
    env PARAM_LINE

  output:
    stdout()
    env GENOME, emit: GENOME
    env REFERENCE, emit: REFERENCE
    env REF_FLAT, emit: REF_FLAT
    env RIBOSOMAL_INTERVALS, emit: RIBOSOMAL_INTERVALS
    env GTAG, emit: GTAG
    path '*.fastq.gz', emit: FASTQ_CH
    env BAITS, emit: BAITS
    env TARGETS, emit: TARGETS
    env MSKQ, emit: MSKQ
    env MD, emit: MD
    env TYPE, emit: TYPE
    env RUN_TYPE, emit: RUN_TYPE
    env DUAL, emit: DUAL
    env SAMPLE_TAG, emit: SAMPLE_TAG
    env PROJECT_TAG, emit: PROJECT_TAG
    env RUN_TAG, emit: RUN_TAG
    env RUNNAME, emit: RUNNAME

  shell:
    template 'send_project_params.sh'
}

workflow send_project_params_wkflw {
  take:
    run_params_path

  main:
    // Submit each run seperately through the workflow so that each can execute independently
    run_params_path.splitText().set{ params_ch }
    task( params_ch )
    out( task.out[0], "send_project_params" )

  emit:
    GENOME = task.out.GENOME
    REFERENCE = task.out.REFERENCE
    REF_FLAT = task.out.REF_FLAT
    RIBOSOMAL_INTERVALS = task.out.RIBOSOMAL_INTERVALS
    GTAG = task.out.GTAG
    FASTQ_CH = task.out.FASTQ_CH
    BAITS = task.out.BAITS
    TARGETS = task.out.TARGETS
    MSKQ = task.out.MSKQ
    MD = task.out.MD
    TYPE = task.out.TYPE
    RUN_TYPE = task.out.RUN_TYPE
    DUAL = task.out.DUAL
    SAMPLE_TAG = task.out.SAMPLE_TAG
    PROJECT_TAG = task.out.PROJECT_TAG
    RUN_TAG = task.out.RUN_TAG
    RUNNAME = task.out.RUNNAME
}


