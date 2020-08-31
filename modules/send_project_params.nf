include { log_out as out } from './log_out'

process task {
  input:
    env PARAM_LINE

  output:
    stdout()
    env GENOME
    env REFERENCE
    env REF_FLAT
    env RIBO_INTER
    env GTAG
    env FASTQ1
    env FASTQ2
    env REFERENCE
    env GENOME
    env BAIT
    env TARGET
    env CAPTURE
    env MSKQ
    env MARKDUPLICATES

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
    task.out[1]
}


