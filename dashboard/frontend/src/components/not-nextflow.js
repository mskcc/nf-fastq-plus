import React from 'react';

function NonNextflowRun({sequencingRuns}) {
    return <div>
        <h2>Sequencing Runs Not Tracked in Nextflow</h2>
        { sequencingRuns.map((val, idx) => {
            const key = `seqRun_${idx}`;
            return <div className={'non-nextflow-runs inline-block'}>
                <p className={'non-nextflow-runs-text'} key={key}> {val}</p>
            </div>;
        })}
    </div>;
}

export default NonNextflowRun;
