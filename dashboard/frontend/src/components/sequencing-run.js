import React, {useState} from 'react';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import NextflowViewer from './nextflow-viewer';

function SequencingRun({sequencingRun}) {
    const [showHistory, setShowHistory] = useState(true);
    /*
    <Row className={'margin-top-15'}>
        <Col xs={6} sm={3}>
            <p className={'text-align-center'}>RUN</p>
        </Col>
        <Col xs={6} sm={9}>
            <p className={'text-align-center'}>PIPELINE INFO</p>
        </Col>
    </Row>
    */
    return <div className={'seq-table'}>
                <Row className={'height-row'}>
                    <Col xs={6} md={5} className={'sequencing-run-info'}>
                        <div>
                            <p className={'margin-top-15'}>{sequencingRun['run']}</p>
                        </div>
                        {
                            showHistory ? <div>
                            <p className={'text-align-right margin-0'}>Total: {sequencingRun['totalRuns']}</p>
                            <p className={'text-align-right margin-0'}>Failed: {sequencingRun['failedRuns']}</p>
                            <p className={'text-align-right margin-0'}>Successful: {sequencingRun['successfulRuns']}</p>
                        </div> : <div></div>
                        }
                    </Col>
                    <Col xs={6} md={7} className={'height-inherit'}>
                        <NextflowViewer
                            nxfRuns={sequencingRun['nxfRuns']}></NextflowViewer>
                    </Col>
                </Row>
    </div>;
}

export default SequencingRun;
