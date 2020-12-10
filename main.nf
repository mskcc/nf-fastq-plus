nextflow.preview.dsl=2

include { dependency_check_wkflw } from './modules/dependency_check';
include { detect_runs_wkflw } from './modules/detect_runs';
include { split_sample_sheet_wkflw } from './modules/split_sample_sheet';
include { demultiplex_wkflw } from './modules/demultiplex';
include { generate_run_params_wkflw } from './modules/generate_run_params';
include { send_project_params_wkflw } from './modules/send_project_params';
include { align_to_reference_wkflw } from './modules/align_to_reference';
include { merge_sams_wkflw } from './modules/merge_sams';
include { mark_duplicates_wkflw } from './modules/mark_duplicates';
include { alignment_summary_wkflw } from './modules/collect_alignment_summary_metrics';
include { collect_hs_metrics_wkflw } from './modules/collect_hs_metrics';
include { collect_oxoG_metrics_wkflw } from './modules/collect_oxoG_metrics';
include { collect_wgs_metrics_wkflw } from './modules/collect_wgs_metrics';
include { collect_rna_metrics_wkflw } from './modules/collect_rna_metrics';
include { collect_gc_bias_wkflw } from './modules/collect_gc_bias_metrics';

/**
 * Processes input parameters that are booleans
 */
def process_bool(bool) {
  if( bool == null )
    return false
  return bool.toBoolean()
}


DEMUX_ALL=process_bool(params.force)	// Whether to demux all runs, including w/ FASTQs already generated

println """\
                  I G O   P I P E L I N E
         ==========================================
         PARAMS
         DEMUX_ALL=${DEMUX_ALL}

         SEQUENCER_DIR="${SEQUENCER_DIR}"
         RUNS_TO_DEMUX_FILE="${RUNS_TO_DEMUX_FILE}"
         Output=${PIPELINE_OUT}
         Log=${LOG_FILE}

         VERSIONS
         BWA: ${BWA}
         PICARD: ${PICARD}
         """
         .stripIndent()

workflow {
  dependency_check_wkflw()
  detect_runs_wkflw( DEMUX_ALL, dependency_check_wkflw.out )
  split_sample_sheet_wkflw( detect_runs_wkflw.out )
  demultiplex_wkflw( split_sample_sheet_wkflw.out )
  generate_run_params_wkflw( demultiplex_wkflw.out.FASTQ_DIR )
  send_project_params_wkflw( generate_run_params_wkflw.out )
  align_to_reference_wkflw( send_project_params_wkflw.out.REFERENCE, send_project_params_wkflw.out.FASTQ_CH, send_project_params_wkflw.out.TYPE, send_project_params_wkflw.out.DUAL, send_project_params_wkflw.out.RUN_TAG, send_project_params_wkflw.out.PROJECT_TAG, send_project_params_wkflw.out.SAMPLE_TAG )
  merge_sams_wkflw( send_project_params_wkflw.out.RUN_TAG, align_to_reference_wkflw.out )
  // mark_duplicates_wkflw will output the input BAM if MD=no, otherwise it will output the MD BAM
  mark_duplicates_wkflw( merge_sams_wkflw.out.BAM_CH, send_project_params_wkflw.out.MD, send_project_params_wkflw.out.RUNNAME, merge_sams_wkflw.out.RUN_TAG )
  alignment_summary_wkflw( mark_duplicates_wkflw.out, send_project_params_wkflw.out.REFERENCE, send_project_params_wkflw.out.RUNNAME, send_project_params_wkflw.out.RUN_TAG )
  collect_hs_metrics_wkflw( mark_duplicates_wkflw.out, send_project_params_wkflw.out.BAITS, send_project_params_wkflw.out.TARGETS, send_project_params_wkflw.out.RUNNAME, send_project_params_wkflw.out.RUN_TAG )
  collect_oxoG_metrics_wkflw( mark_duplicates_wkflw.out, send_project_params_wkflw.out.BAITS, send_project_params_wkflw.out.TARGETS, send_project_params_wkflw.out.MSKQ, send_project_params_wkflw.out.REFERENCE, send_project_params_wkflw.out.RUNNAME, send_project_params_wkflw.out.RUN_TAG )
  collect_wgs_metrics_wkflw( mark_duplicates_wkflw.out, send_project_params_wkflw.out.GTAG, send_project_params_wkflw.out.TYPE, send_project_params_wkflw.out.REFERENCE, send_project_params_wkflw.out.RUNNAME, send_project_params_wkflw.out.RUN_TAG )
  collect_rna_metrics_wkflw( mark_duplicates_wkflw.out, send_project_params_wkflw.out.RIBOSOMAL_INTERVALS, send_project_params_wkflw.out.REF_FLAT, send_project_params_wkflw.out.RUNNAME, send_project_params_wkflw.out.RUN_TAG )
  collect_gc_bias_wkflw( mark_duplicates_wkflw.out, send_project_params_wkflw.out.REFERENCE, send_project_params_wkflw.out.RUNNAME, send_project_params_wkflw.out.RUN_TAG )
}
