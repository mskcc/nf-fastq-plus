process log_out {
  input:
  stdin stuff

  shell:
  '''
  # Read ech line from stdin & write to log file w/ timestamp
  while IFS='$\n' read -r line; do
    echo "$(date): $line" >> ${LOG_FILE}
  done
  '''
}
