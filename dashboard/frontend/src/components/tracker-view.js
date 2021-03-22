import React, { useState, useEffect } from 'react';
import SequencingRun from './sequencing-run';
import { getEvents } from '../services/tracker-service'

function TrackerView() {
  const [events, setEvents] = useState([]);

  // Set up our eventSource to listen
  useEffect(() => {
    getEvents().then((update) => {
      if(update.status && update.data){
        setEvents(update.data);
      }
    })
  }, []);

  return <div>
  <h1>Current Jobs</h1>
  {
    events.map((sequencingRun) => {
      return <SequencingRun sequencingRun={sequencingRun}></SequencingRun>
    })
  }
  </div>
}

export default TrackerView;
