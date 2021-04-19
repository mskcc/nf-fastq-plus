include { log_out as out } from './log_out'

process task {
  label 'LOCAL'

  input:
    path MD_METRICS_FILE_CH
    path AM_METRICS_FILE_CH
    path HS_METRICS_FILE_CH
    path OXOG_METRICS_FILE_CH
    path WGS_METRICS_FILE_CH
    path RNA_METRICS_FILE_CH
    path GC_BIAS_METRICS_FILE_CH
    env RUNNAME
    env STATSDONEDIR

  output:
    stdout()
    path "UPLOAD_DONE.txt", emit: UPLOAD_DONE

  shell:
    template 'upload_stats.sh'
}

process email {
  label 'LOCAL'

  input:
    env RUNNAME
    env IGO_EMAIL

  shell:
  '''
    echo "Emailing Stats Complete: ${RUNNAME}"
    echo ${RUNNAME} | mail -s " Stats calculated for Run ${RUNNAME} " ${IGO_EMAIL}
    touch ${RUNNAME}_DONE.txt
  '''
}

workflow upload_stats_wkflw {
  take:
    MD_METRICS_FILE_CH
    AM_METRICS_FILE_CH
    HS_METRICS_FILE_CH
    OXOG_METRICS_FILE_CH
    WGS_METRICS_FILE_CH
    RNA_METRICS_FILE_CH
    GC_BIAS_METRICS_FILE_CH
    RUNNAME
    STATSDONEDIR
    IGO_EMAIL

  main:
    task(
        MD_METRICS_FILE_CH,
        AM_METRICS_FILE_CH,
        HS_METRICS_FILE_CH,
        OXOG_METRICS_FILE_CH,
        WGS_METRICS_FILE_CH,
        RNA_METRICS_FILE_CH,
        GC_BIAS_METRICS_FILE_CH,
        RUNNAME,
        STATSDONEDIR )
    email(
        RUNNAME,
        IGO_EMAIL )
    out( task.out[0], "upload_stats" )

  emit:
    UPLOAD_DONE = task.out.UPLOAD_DONE
}
