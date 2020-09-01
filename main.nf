nextflow.preview.dsl=2

include { dependency_check_wkflw } from './modules/dependency_check';
include { detect_runs_wkflw } from './modules/detect_runs';
include { demultiplex_wkflw } from './modules/demultiplex';
include { generate_run_params_wkflw } from './modules/generate_run_params';
include { send_project_params_wkflw } from './modules/send_project_params';
include { align_to_reference_wkflw } from './modules/align_to_reference';

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
         BWA: ${bwa}
         PICARD: ${picard}
         """
         .stripIndent()

workflow {
  dependency_check_wkflw()
  detect_runs_wkflw( DEMUX_ALL, dependency_check_wkflw.out )
  demultiplex_wkflw( detect_runs_wkflw.out )
  generate_run_params_wkflw( demultiplex_wkflw.out )
  send_project_params_wkflw( generate_run_params_wkflw.out )
  align_to_reference_wkflw( send_project_params_wkflw.out )
}
