import React, { useState, useEffect } from 'react';
import SequencingRun from './sequencing-run';
import { getEvents, getSequencingRuns } from '../services/tracker-service';

function TrackerView() {
  const [sequencingRuns, setSequencingRuns] = useState([]);

  const [nxfEvents, setNxfEvents] = useState([]);

  // Set up our eventSource to listen
  useEffect(() => {
    const receivedEvents = [];
    for(const run of sequencingRuns){
      const runName = run['run'];
      if(runName) {
        console.log(`Querying for: ${runName}`);
        getEvents(runName).then((nextflowEvents) => {
          // TODO - replace w/ better validator
          if(Object.keys(nextflowEvents).length > 0){
            const updatedNxfEvents = [...nxfEvents];
            updatedNxfEvents.push(nextflowEvents);
            console.log(`Pushed: ${runName}`);
            setNxfEvents(updatedNxfEvents);
          }
        });
      } else {
        console.log(`Couldn't extract runName from ${JSON.stringify(run)}`);
      }
      console.log(`Loop done: ${runName}`);
    }
  }, [sequencingRuns]);
  useEffect(() => {
    getSequencingRuns().then((runs) => {
      console.log('Received sequencing events');
      setSequencingRuns(runs);
    });
  }, []);

  const isSuccessfulRun = (nxfEvt) => {
    return nxfEvt['successfulRuns'] > 0 && !nxfEvt['pending'];
  };

  const isFailedRun = (nxfEvt) => {
    return nxfEvt['totalRuns'] === nxfEvt['failedRuns'] && !nxfEvt['pending'];
  };

  const isPendingRun = (nxfEvt) => {
      return nxfEvt['pending'];
  };

  const pendingRuns = nxfEvents.filter(isPendingRun);
  const failedRuns = nxfEvents.filter(isFailedRun);
  const successfulRuns = nxfEvents.filter(isSuccessfulRun);

  return <div className={'seq-run-container'}>
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
