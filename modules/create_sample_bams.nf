include { retrieve_all_sample_runs_wkflw } from './retrieve_all_sample_runs';
include { create_run_bams_wkflw } from './create_run_bams';
include { get_sample_merge_commands_wkflw } from './get_sample_merge_commands'
include { log_out as out } from './log_out'

process task {
  label 'BSUB_OPTIONS_SMALL'

  tag 'SAMPLE_BAM_$OUTPUT_ID'

  input:
    env MERGE_CMD
    env CMD_FILE

  output:
    stdout()

  script:
    '''
    # Evaluate the merge command (e.g. "samtools merge ${TARGET_BAM} ${SRC_BAM_1} ${SRC_BAM_2}...")
    echo ${MERGE_CMD} > ${CMD_FILE}
    eval ${MERGE_CMD}
    '''
}

workflow OTHER_create_sample_bams_wkflw {
  take:
    OUTPUT_ID
    DEMUXED_DIR
    ARCHIVED_DIR
    STATS_DIR
    STATSDONEDIR
    CMD_FILE

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
}
