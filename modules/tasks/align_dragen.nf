include { log_out as out } from '../utils/log_out'

process task {
  label 'DGN'
  tag "$RUN_PARAMS"

  input:
    path RUN_PARAMS
    val RUN_PARAMS				// 2nd value is passed to provide the task's LSF job name

  output:
    stdout()
    path "${RUN_PARAMS_FILE}", emit: PARAMS
    path '*.bam', emit: BAM_CH
    env SAMPLE_TAG, emit: SAMPLE_TAG
    path "*bam", emit: ALIGN_SUCCESS 		// Used as a downstream indicator of successful alignment

  shell:
    template 'align_dragen.sh'
}

workflow align_dragen_wkflw {
  take:
    RUN_PARAMS
  main:
    task( RUN_PARAMS, RUN_PARAMS )
    out( task.out[0], "align_dragen" )

  emit:
    PARAMS = task.out.PARAMS
    BAM_CH = task.out.BAM_CH
    OUTPUT_ID = task.out.SAMPLE_TAG
    METRICS_FILE = task.out.ALIGN_SUCCESS	// TOOD - this is to make it compatible w/ create_run_bams_wkflw
}
