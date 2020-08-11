nextflow.preview.dsl=2

include DETECT_RUNS from './modules/detect_runs';

RUNS_TO_DEMUX_FILE=config.RUNS_TO_DEMUX_FILE
SEQUENCER_DIR=config.SEQUENCER_DIR
PIPELINE_OUT=config.RESULTS_DIR

println """\
         I G O  P I P E L I N E
         ===================================
         SEQUENCER_DIR="${SEQUENCER_DIR}"
         RUNS_TO_DEMUX_FILE="${RUNS_TO_DEMUX_FILE}"

         Output=${PIPELINE_OUT}
         """
         .stripIndent()

process process_runs {
  publishDir PIPELINE_OUT, mode:'move'
 
  input:
  file runs_to_demux_file

  output:
  path "${RUNS_TO_DEMUX_FILE}"

  script:
  """
  echo "Outputting ${runs_to_demux_file}"
  """
}

workflow {
  DETECT_RUNS()
  process_runs( DETECT_RUNS.out )
}
 
