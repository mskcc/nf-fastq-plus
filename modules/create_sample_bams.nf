/**
 * Creates a Sample BAM by merging across all runs w/ FASTQs for that sample
 */
include { create_run_bams_wkflw } from './create_run_bams';
include { retrieve_all_sample_runs_wkflw } from './workflows/retrieve_all_sample_runs';
include { get_sample_merge_commands_wkflw } from './workflows/get_sample_merge_commands';
include { wait_for_bams_to_finish_wkflw } from './workflows/wait_for_bams_to_finish';
include { log_out as out } from './utils/log_out';

process task {
  label 'BSUB_OPTIONS_SMALL'

  tag "SAMPLE_BAM_$OUTPUT_ID"

  input:
    env MERGE_CMD
    env CMD_FILE
    val OUTPUT_ID

  output:
    stdout()

  script:
    '''
    # Evaluate the merge command (e.g. "samtools merge ${TARGET_BAM} ${SRC_BAM_1} ${SRC_BAM_2}...")
    echo ${MERGE_CMD} >> ${CMD_FILE}
    echo ${MERGE_CMD}
    eval ${MERGE_CMD}
    '''
}

workflow create_sample_bams_wkflw {
  take:
    OUTPUT_ID
    RUN_BAMS_CH
    RUNNAME
    DEMUXED_DIR
    ARCHIVED_DIR
    STATS_DIR
    STATSDONEDIR
    CMD_FILE
    SAMPLE_BAM_DIR

  main:
    retrieve_all_sample_runs_wkflw( DEMUXED_DIR, ARCHIVED_DIR, RUNNAME )
    retrieve_all_sample_runs_wkflw.out.RUNS_TO_ALIGN_FILE
      .splitText()
      .multiMap { it ->
        RUN_DEMUX_DIR: it.split(' ')[0]
        RUN_SAMPLE_SHEET: it.split(' ')[1]
        BAM_DIR: it.split(' ')[2]
      }
      .set{ related_runs_ch }
    create_run_bams_wkflw( related_runs_ch.RUN_DEMUX_DIR, related_runs_ch.RUN_SAMPLE_SHEET, STATS_DIR, STATSDONEDIR )
    create_run_bams_wkflw.out.RUN_BAMS_CH
      .set{ legacy_bams_ch }
    RUN_BAMS_CH
      .set{ run_bams_ch }

    run_bams_ch
      .concat( legacy_bams_ch )
      .set{ all_bams_file }

    wait_for_bams_to_finish_wkflw( all_bams_file, STATSDONEDIR )
    wait_for_bams_to_finish_wkflw.out.OUTPUT_BAMS
      .splitText()
      .multiMap { it ->
        BAM_DIR: it.split(' ')[0]
      }
      .set{ all_bams_ch }

    get_sample_merge_commands_wkflw( all_bams_ch, RUNNAME, SAMPLE_BAM_DIR )
    get_sample_merge_commands_wkflw.out.MERGE_COMMANDS
      .splitText()
      .collect()
      .flatten()
      .unique()
      .set{ merge_cmd_ch }
    task( merge_cmd_ch, CMD_FILE, OUTPUT_ID )
    out( task.out[0], "create_sample_bams" )
}
