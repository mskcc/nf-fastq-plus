import React, { useState, useEffect } from 'react';
import SequencingRun from './sequencing-run';
import { getEvents } from '../services/tracker-service';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';

function TrackerView() {
  const [events, setEvents] = useState([]);

  // Set up our eventSource to listen
  useEffect(() => {
    getEvents().then((update) => {
      if(update.status && update.data){
        setEvents(update.data);
      }
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
