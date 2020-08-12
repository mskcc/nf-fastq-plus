nextflow.preview.dsl=2

include DETECT_RUNS from './modules/detect_runs';

println """\
                  I G O   P I P E L I N E
         ==========================================
         SEQUENCER_DIR="${SEQUENCER_DIR}"
         RUNS_TO_DEMUX_FILE="${RUNS_TO_DEMUX_FILE}"

         Output=${PIPELINE_OUT}
         """
         .stripIndent()

process process_runs {
  input:
  stdin runs_to_demux

  publishDir PIPELINE_OUT, mode:'move'

  output:
  path "${RUNS_TO_DEMUX_FILE}"

  script:
  """
  cat - > ${RUNS_TO_DEMUX_FILE}
  echo "Outputing New Runs to ${PIPELINE_OUT}"
  echo ${RUNS_TO_DEMUX_FILE}
  """
}

workflow {
  DETECT_RUNS | filter { it != "" } | process_runs
}
