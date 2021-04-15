import React, { useState, useEffect } from 'react';
import SequencingRun from './sequencing-run';
import NonNextflowRun from './not-nextflow';
import { getEvents, getSequencingRuns } from '../services/tracker-service';
import {getLatestNextflowRunFromSeqRun} from '../services/util';

function TrackerView() {
  const [sequencingRuns, setSequencingRuns] = useState([]);
  const [nxfEvents, setNxfEvents] = useState([]);             //
  const [nonNxfSeqRuns, setNonNxfSeqRuns] = useState([]);     // Sequencing runs that have been processed by nextflow

  // Set up our eventSource to listen
  useEffect(() => {
    (async () => {
      /* Send out requests to populate run data and wait */
      const seqRunsRequests = [];
      const seqRunsToTrack = new Set();
      for(const run of sequencingRuns){
        const runName = run['run'];
        seqRunsToTrack.add(runName);
        if(runName) {
          seqRunsRequests.push(getEvents(runName));
        } else {
          console.log(`Couldn't extract runName from ${JSON.stringify(run)}`);
        }
      }
      const responses = await Promise.all(seqRunsRequests);

      /* Populate seq runs w/ their data or mark the ones that have no data */
      const nextflowEvents = [];
      const nonNextflowEvents = [];
      for(const seqNextflowEvents of responses){
        if(Object.keys(seqNextflowEvents).length > 0){
          const populatedRun = seqNextflowEvents['run'];
          seqRunsToTrack.delete(populatedRun);
          nextflowEvents.push(seqNextflowEvents);
        }
      }
      for(const runName of Array.from(seqRunsToTrack)){
        nonNextflowEvents.push(runName);
      }

      // Sort nextflow events from most recent
      nextflowEvents.sort((e1, e2) => {
        const r1 = e1.nxfRuns;
        const r2 = e2.nxfRuns;

        const runTimes1 = r1.map(r => new Date(r.time));
        const runTimes2 = r2.map(r => new Date(r.time));

        const mostRecentTime1 = runTimes1.reduce((t1, t2) => t1 > t2 ? t1 : t2);
        const mostRecentTime2 = runTimes2.reduce((t1, t2) => t1 > t2 ? t1 : t2);

        return mostRecentTime2 - mostRecentTime1;
      });

      setNxfEvents(nextflowEvents);
      setNonNxfSeqRuns(nonNextflowEvents);
    })();
  }, [sequencingRuns]);
  useEffect(() => {
    getSequencingRuns(21).then((runs) => {
      setSequencingRuns(runs);
    });
  }, []);

  const isSuccessfulRun = (nxfEvt) => {
    const latest = getLatestNextflowRunFromSeqRun(nxfEvt);
    return latest.success && nxfEvt['successfulRuns'] > 0 && !nxfEvt['pending'];
  };

  const isFailedRun = (nxfEvt) => {
    const latest = getLatestNextflowRunFromSeqRun(nxfEvt);
    return !latest.success && nxfEvt['totalRuns'] === nxfEvt['failedRuns'] && !nxfEvt['pending'];
  };

  const isPendingRun = (nxfEvt) => {
    return nxfEvt['pending'];
  };

  const pendingRuns = nxfEvents.filter(isPendingRun);
  const failedRuns = nxfEvents.filter(isFailedRun);
  const successfulRuns = nxfEvents.filter(isSuccessfulRun);

  return <div className={'seq-run-container'}>
    {
      nonNxfSeqRuns.length === 0 ? <div></div> :
          <NonNextflowRun sequencingRuns={nonNxfSeqRuns}></NonNextflowRun>
    }
    <h2>Pending ({pendingRuns.length})</h2>
    {
      pendingRuns.map((sequencingRun) => {
        return <SequencingRun
            key={sequencingRun.run}
            sequencingRun={sequencingRun}></SequencingRun>;
      })
    }
    <h2>Failed ({failedRuns.length})</h2>
    {
      failedRuns.map((sequencingRun) => {
        return <SequencingRun
            key={sequencingRun.run}
            sequencingRun={sequencingRun}></SequencingRun>;
      })
    }
    <h2>Successful ({successfulRuns.length})</h2>
    {
      successfulRuns.map((sequencingRun) => {
        return <SequencingRun
            key={sequencingRun.run}
            sequencingRun={sequencingRun}></SequencingRun>;
      })
    }
  </div>;
}

export default TrackerView;
