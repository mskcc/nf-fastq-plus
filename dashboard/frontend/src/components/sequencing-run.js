import React from 'react';
import NextflowRun from "./nextflow-run";
function SequencingRun({sequencingRun}) {
    return <div>
            <div className={'sequencing-run-info'}>
                <div>{sequencingRun['run']}</div>
                <div>
                    <p className={'text-align-right'}>Total Runs: {sequencingRun['totalRuns']}</p>
                    <p className={'text-align-right'}>Failed Runs: {sequencingRun['failedRuns']}</p>
                    <p className={'text-align-right'}>Successful Runs: {sequencingRun['successfulRuns']}</p>
                </div>
            </div>
        {sequencingRun['nxfRuns'].map((nextflowRun) => {
            return <NextflowRun nextflowRun={nextflowRun}></NextflowRun>
        })
        }
    </div>
}

export default SequencingRun;
