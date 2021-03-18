import React, { useState, useEffect } from 'react';

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
    events.map((evt) => {
      return <div>
      <div>{evt["runId"]}</div>
      {evt["updates"].map((update) => {
        return <div className={"update-container"}>
            <p className={"text-align-left "}>{update.name}</p>
            <p className={"text-align-right"}>{update.status}</p>
            <p className={"text-align-right"}>{update.time}</p>
            </div>
      })}
    </div>
    })
  }
  </div>
}

export default TrackerView;
