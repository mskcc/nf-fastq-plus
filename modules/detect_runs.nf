// Import configs
RUN_AGE=config.RUN_AGE
SEQUENCER_DIR=config.SEQUENCER_DIR
RUNS_TO_DEMUX_FILE=config.RUNS_TO_DEMUX_FILE

process DETECT_RUNS {
  output:
  stdout()

  shell:
  '''
  sequencer_files=( !{SEQUENCER_DIR}/johnsawyers/*/RTAComplete.txt
    !{SEQUENCER_DIR}/johnsawyers/*/RTAComplete.txt
    !{SEQUENCER_DIR}/kim/*/RTAComplete.txt
    !{SEQUENCER_DIR}/momo/*/RTAComplete.txt
    !{SEQUENCER_DIR}/toms/*/RTAComplete.txt
    !{SEQUENCER_DIR}/vic/*/RTAComplete.txt
    !{SEQUENCER_DIR}/diana/*/CopyComplete.txt
    !{SEQUENCER_DIR}/michelle/*/CopyComplete.txt
    !{SEQUENCER_DIR}/jax/*/SequencingComplete.txt
    !{SEQUENCER_DIR}/pitt/*/SequencingComplete.txt
    !{SEQUENCER_DIR}/scott/*/RunCompletionStatus.xml
    !{SEQUENCER_DIR}/ayyan/*/RTAComplete.txt
  )
  
  for file in ${sequencer_files[@]}; do
    find $(ls $file) -mmin -!{RUN_AGE} >> !{RUNS_TO_DEMUX_FILE}
  done

  cat !{RUNS_TO_DEMUX_FILE}
  '''
}
