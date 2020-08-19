process log_out {
  input:
  stdin stuff

  output:
  stdout()

  shell:
  '''
  # Read ech line from stdin & write to log file w/ timestamp
  while IFS='$\n' read -r line; do
    LOG_LINE="$(date): $line" 
    echo $LOG_LINE >> ${LOG_FILE}
    echo $LOG_LINE	# Also log to .command.out
  done
  '''
}
