import React, {useState} from 'react';
import NextflowRun from './nextflow-run';
import Row from 'react-bootstrap/Row';
import Container from 'react-bootstrap/Container';

function NextflowViewer({nxfRuns}) {
    const [numRuns, setNumRuns] = useState(1);
    const sortedRuns = nxfRuns.sort((r1, r2) => {
        return new Date(r2.time) - new Date(r1.time);
    });

    return <div className={'height-inherit'}>
        {
                    sortedRuns.slice(0,numRuns).map((nextflowRun) => {
                        return <NextflowRun nextflowRun={nextflowRun}></NextflowRun>;
                    })
                }
    </div>;
}

export default NextflowViewer;
