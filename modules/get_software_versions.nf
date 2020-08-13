/*
 * Parse software version numbers
 */
process get_software_versions {
    output:
    stdout()

    shell:
    '''
    printf "\nStarting Run $(date)\n"
    echo "VERSIONS: BWA $(${bwa} 2>&1 | grep "Version")"
    echo "VERSIONS: PICARD $(echo ${picard})"
    '''
}
