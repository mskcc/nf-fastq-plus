nextflow.preview.dsl=2

include detect_runs from './modules/detect_runs';

println """\
                  I G O   P I P E L I N E
         ==========================================
         SEQUENCER_DIR="${SEQUENCER_DIR}"
         RUNS_TO_DEMUX_FILE="${RUNS_TO_DEMUX_FILE}"

         Output=${PIPELINE_OUT}
         Log=${LOG_FILE}
         """
         .stripIndent()

process log_out {
  input:
  stdin out

  script:
  """
  cat - >> ${LOG_FILE}
  """
}

workflow {
  detect_runs()
}
