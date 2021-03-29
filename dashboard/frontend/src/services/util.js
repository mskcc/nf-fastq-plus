/**
 * Retrieve latest nextflow run for a sequencing run
 * @param seqRunEvent {
 *    nxfRuns: [
 *        { ... },
 *        ...
 *    ]
 * }
 * @returns {null|*}
 */
export function getLatestNextflowRunFromSeqRun(seqRunEvent) {
    const nxfRuns = seqRunEvent.nxfRuns || [];

    if(nxfRuns.length === 0) {
        console.log("Couldn't retrieve nxfRuns from sequencing event");
        return {};
    };
    // nxfRuns should be sorted
    return nxfRuns[0];
}
