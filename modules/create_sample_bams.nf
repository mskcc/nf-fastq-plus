include { retrieve_all_sample_runs_wkflw } from './retrieve_all_sample_runs';
include { create_run_bams_wkflw } from './create_run_bams';

process task {
  label 'BSUB_OPTIONS_SMALL'

  input:
    env MERGE_CMD

  output:
    stdout()

  shell:
    ```
    SAMPLE_MERGE_FILE="merge.sh"
    echo ${MERGE_CMD} > ${SAMPLE_MERGE_FILE}
    cat ${merge.sh}
    ./${SAMPLE_MERGE_FILE}
    ```
}

workflow create_sample_bams_wkflw {
  take:
    DEMUXED_DIR
    ARCHIVED_DIR
    STATS_DIR
    STATSDONEDIR

  main:
    retrieve_all_sample_runs_wkflw( DEMUXED_DIR, ARCHIVED_DIR )
    retrieve_all_sample_runs_wkflw.out.RUNS_TO_ALIGN_FILE
      .splitText()
      .multiMap { it ->
        RUN_DEMUX_DIR: it.split(' ')[0]
        RUN_SAMPLE_SHEET: it.split(' ')[1]
        BAM_DIR: it.split(' ')[2]
      }
      .set{ related_runs_ch }
    create_run_bams_wkflw( related_runs_ch.RUN_DEMUX_DIR, related_runs_ch.RUN_SAMPLE_SHEET, STATS_DIR, STATSDONEDIR )
    create_run_bams_wkflw.out.BAM_CH
      .collectFile( name: 'run_bams.txt', newLine: true)
      .set{ run_bams_ch }
    get_sample_merge_commands_wkflw( run_bams_ch, create_run_bams_wkflw.out.RUNNAME )
    get_sample_merge_commands_wkflw.out.MERGE_COMMANDS
      .splitText()
      .set { merge_cmd_ch }
    task( merge_cmd_ch )
}
