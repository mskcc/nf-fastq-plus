import React, { useState, useEffect } from 'react';
import SequencingRun from './sequencing-run';
import { getEvents, getSequencingRuns } from '../services/tracker-service';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';

function TrackerView() {
  const [events, setEvents] = useState([]);
  const [sequencingRuns, setSequencingRuns] = useState([]);

  // Set up our eventSource to listen
  useEffect(() => {
    for(const run of sequencingRuns){
      const runName = run['run'];
      if(runName) {
        getEvents(runName).then((nextflowEvents) => {
          setEvents(nextflowEvents);
        });
      } else {
        console.log(`Couldn't extract runName from ${JSON.stringify(run)}`);
      }
    }
  }, [sequencingRuns]);

  useEffect(() => {
    getSequencingRuns().then((runs) => {
      console.log(runs);
      setSequencingRuns(runs);
    });
  }, []);

  return <div>
    <Row className={'margin-top-15'}>
      <Col xs={6} sm={3}>
        <p className={'text-align-center'}>RUN</p>
      </Col>
      <Col xs={6} sm={9}>
        <p className={'text-align-center'}>PIPELINE INFO</p>
      </Col>
    </Row>
  {
    events.map((sequencingRun) => {
      return <SequencingRun sequencingRun={sequencingRun}></SequencingRun>;
    })
  }
  </div>;
}

export default TrackerView;
