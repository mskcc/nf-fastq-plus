import React, {useState} from 'react';
import NextflowRun from './nextflow-run';

function NextflowViewer({nxfRuns}) {
    const [numRuns, setNumRuns] = useState(1);
    const sortedRuns = nxfRuns.sort((r1, r2) => {
        return new Date(r2.time) - new Date(r1.time);
    });
    return <div className={'height-inherit'}>
        {
                    sortedRuns.slice(0,numRuns).map((nextflowRun) => {
                        return <NextflowRun
                            key={nextflowRun.run}
                            nextflowRun={nextflowRun}></NextflowRun>;
                    })
                }
    </div>;
}

export default NextflowViewer;
