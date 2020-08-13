nextflow.preview.dsl=2

include detect_runs from './modules/detect_runs';
include get_software_versions from './modules/get_software_versions';
include log_out as dr_log from './modules/log_out'
include log_out as gsw_log from './modules/log_out'

println """\
                  I G O   P I P E L I N E
         ==========================================
         SEQUENCER_DIR="${SEQUENCER_DIR}"
         RUNS_TO_DEMUX_FILE="${RUNS_TO_DEMUX_FILE}"

         Output=${PIPELINE_OUT}
         Log=${LOG_FILE}
         """
         .stripIndent()

workflow {
  get_software_versions()
  detect_runs() 

  // TODO: Find cleaner way, hopefully one function
  gsw_log( get_software_versions.out )
  dr_log( detect_runs.out[1] )
}
