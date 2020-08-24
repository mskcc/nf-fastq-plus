nextflow.preview.dsl=2

include { dependency_check_wkflw } from './modules/dependency_check';
include { detect_runs_wkflw } from './modules/detect_runs';
include { demultiplex_wkflw } from './modules/demultiplex';
include { launch_stats_wkflw } from './modules/launch_stats';

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
  launch_stats_wkflw( demultiplex_wkflw.out )
}
