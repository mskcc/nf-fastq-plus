import React, {useState} from 'react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import IconButton from '@material-ui/core/IconButton';

import {faCheck, faExclamationCircle, faEllipsisH} from '@fortawesome/free-solid-svg-icons';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import TraceView from './trace-view';

function NextflowRun({nextflowRun}) {
    const [showLogs, setShowLogs] = useState(true);

    const getIcon = (nxfRun) => {
        if(nxfRun.success){
            return [faCheck, 'mskcc-dark-green'];
        } else if (!nxfRun.completed) {
            return [faEllipsisH, 'mskcc-dark-gray'];
        }
        return [faExclamationCircle, 'mskcc-red'];
    };

    const [icon, color] = getIcon(nextflowRun);

    // <p className={'text-align-right'}>Completed: {nextflowRun.completed.toString()}</p>
    // <p className={'text-align-right'}>Success: {nextflowRun.success.toString()}</p>

    return <Row className={'simple-border height-inherit'}>
        <Col xs={2}>
            <p className={'hv-align'}>{nextflowRun.runName}</p>
        </Col>
        <Col xs={2}>
            <FontAwesomeIcon className={`hv-align ${color} font-size-24`} icon={icon}/>
        </Col>
        <Col xs={2}>
            <p className={'hv-align'}>{new Date(nextflowRun.time).toLocaleString()}</p>
        </Col>
        <Col xs={6} className={'height-inherit word-wrap scroll-y'}>
            {
                nextflowRun.errorMessage ? nextflowRun.errorMessage.map((line) => {
                    return <p className={'text-align-left code'}>{line}</p>;
                }) : <p></p>
            }
        </Col>
    </Row>;
}

export default NextflowRun;
