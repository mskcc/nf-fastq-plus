process write_params {
  input:
    env PARAM_LINE
  output:
    stdout()
    path "${RUN_PARAMS_FILE}", emit: PARAMS
  shell:
    '''
    echo ${PARAM_LINE} > !{RUN_PARAMS_FILE}
    '''
}
