nextflow.preview.dsl=2

include { dependency_check_wkflw } from './modules/dependency_check';
include { detect_runs_wkflw } from './modules/detect_runs';
include { split_sample_sheet_wkflw } from './modules/split_sample_sheet';
include { demultiplex_wkflw } from './modules/demultiplex';
include { generate_run_params_wkflw } from './modules/generate_run_params';
include { align_to_reference_wkflw } from './modules/align_to_reference';
include { add_or_replace_read_groups_wkflw } from './modules/add_or_replace_read_groups';
include { merge_sams_wkflw } from './modules/merge_sams';
include { mark_duplicates_wkflw } from './modules/mark_duplicates';
include { alignment_summary_wkflw } from './modules/collect_alignment_summary_metrics';
include { collect_hs_metrics_wkflw } from './modules/collect_hs_metrics';
include { collect_oxoG_metrics_wkflw } from './modules/collect_oxoG_metrics';
include { collect_wgs_metrics_wkflw } from './modules/collect_wgs_metrics';
include { collect_rna_metrics_wkflw } from './modules/collect_rna_metrics';
include { collect_gc_bias_wkflw } from './modules/collect_gc_bias_metrics';
include { upload_stats_wkflw } from './modules/upload_stats';
include { fingerprint_wkflw } from './modules/fingerprint';

/**
 * Processes input parameters that are booleans
 */
def process_bool(bool) {
  if( bool == null )
    return false
  return bool.toBoolean()
}

RUN=params.run
DEMUX_ALL=process_bool(params.force)	// Whether to demux all runs, including w/ FASTQs already generated

println """\
                  I G O   P I P E L I N E
         ==========================================
         RUN=${RUN}

         DEMUX_ALL=${DEMUX_ALL}

         SEQUENCER_DIR="${SEQUENCER_DIR}"
         LAB_SAMPLE_SHEET_DIR=${LAB_SAMPLE_SHEET_DIR}
         PROCESSED_SAMPLE_SHEET_DIR=${PROCESSED_SAMPLE_SHEET_DIR}
         FASTQ_DIR=${FASTQ_DIR}
         STATS_DIR=${STATS_DIR}
         LOG_FILE=${LOG_FILE}
         CMD_FILE=${CMD_FILE}

         VERSIONS
         BWA: ${BWA}
         PICARD: ${PICARD}
         CELL_RANGER_ATAC: ${CELL_RANGER_ATAC}
         """
         .stripIndent()

workflow {
  dependency_check_wkflw()
  detect_runs_wkflw( RUN, DEMUX_ALL, SEQUENCER_DIR, FASTQ_DIR )
  split_sample_sheet_wkflw( detect_runs_wkflw.out.RUNPATH, PROCESSED_SAMPLE_SHEET_DIR )
  demultiplex_wkflw( split_sample_sheet_wkflw.out.SPLIT_SAMPLE_SHEETS, split_sample_sheet_wkflw.out.RUN_TO_DEMUX_DIR, CELL_RANGER_ATAC, DEMUX_ALL )
  generate_run_params_wkflw( detect_runs_wkflw.out.RUNNAME, demultiplex_wkflw.out.DEMUXED_DIR, demultiplex_wkflw.out.SAMPLESHEET, RUN_PARAMS_FILE )
  align_to_reference_wkflw( generate_run_params_wkflw.out.LANE_PARAM_FILES, RUN_PARAMS_FILE, CMD_FILE )
  merge_sams_wkflw( align_to_reference_wkflw.out.PARAMS, align_to_reference_wkflw.out.SAM_CH, align_to_reference_wkflw.out.OUTPUT_ID )
  add_or_replace_read_groups_wkflw( merge_sams_wkflw.out.PARAMS, merge_sams_wkflw.out.BAM_CH, merge_sams_wkflw.out.OUTPUT_ID )
  // mark_duplicates_wkflw will output the input BAM if MD=no, otherwise it will output the MD BAM
  mark_duplicates_wkflw( add_or_replace_read_groups_wkflw.out.PARAMS, add_or_replace_read_groups_wkflw.out.BAM_CH, add_or_replace_read_groups_wkflw.out.OUTPUT_ID, SKIP_FILE_KEYWORD )
  alignment_summary_wkflw( mark_duplicates_wkflw.out.PARAMS, mark_duplicates_wkflw.out.MD_BAM_CH, mark_duplicates_wkflw.out.OUTPUT_ID, SKIP_FILE_KEYWORD )
  collect_hs_metrics_wkflw( mark_duplicates_wkflw.out.PARAMS, mark_duplicates_wkflw.out.MD_BAM_CH, mark_duplicates_wkflw.out.OUTPUT_ID, SKIP_FILE_KEYWORD )
  collect_oxoG_metrics_wkflw( mark_duplicates_wkflw.out.PARAMS, mark_duplicates_wkflw.out.MD_BAM_CH, mark_duplicates_wkflw.out.OUTPUT_ID, SKIP_FILE_KEYWORD )
  collect_wgs_metrics_wkflw( mark_duplicates_wkflw.out.PARAMS, mark_duplicates_wkflw.out.MD_BAM_CH, mark_duplicates_wkflw.out.OUTPUT_ID, SKIP_FILE_KEYWORD )
  collect_rna_metrics_wkflw( mark_duplicates_wkflw.out.PARAMS, mark_duplicates_wkflw.out.MD_BAM_CH, mark_duplicates_wkflw.out.OUTPUT_ID, SKIP_FILE_KEYWORD )
  collect_gc_bias_wkflw( mark_duplicates_wkflw.out.PARAMS, mark_duplicates_wkflw.out.MD_BAM_CH, mark_duplicates_wkflw.out.OUTPUT_ID, SKIP_FILE_KEYWORD )
  upload_stats_wkflw( mark_duplicates_wkflw.out.METRICS_FILE, alignment_summary_wkflw.out.METRICS_FILE, collect_hs_metrics_wkflw.out.METRICS_FILE, 
    collect_oxoG_metrics_wkflw.out.METRICS_FILE, collect_wgs_metrics_wkflw.out.METRICS_FILE, collect_rna_metrics_wkflw.out.METRICS_FILE, collect_gc_bias_wkflw.out.METRICS_FILE,
    RUN, STATSDONEDIR, SKIP_FILE_KEYWORD
  )
  fingerprint_wkflw( split_sample_sheet_wkflw.out.SPLIT_SAMPLE_SHEETS, CROSSCHECK_DIR, upload_stats_wkflw.out.UPLOAD_DONE )
}
