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
  stdin detect_runs 
  // Add "stdin {PROCESS}" (Note: does NOT need to process name)

  shell:
  '''
  # Read ech line from stdin & write to log file w/ timestamp
  while IFS='$\n' read -r line; do
    echo "$(date): $line" >> ${LOG_FILE}
  done
  '''
}

workflow {
  detect_runs()
  log_out( detect_runs.out[1] )
}
