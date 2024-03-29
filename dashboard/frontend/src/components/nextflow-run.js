import React, {useState} from 'react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

import {faCheck, faExclamationCircle, faEllipsisH} from '@fortawesome/free-solid-svg-icons';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';

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

    /**
     * Reads through all recorded trace events of a nextflow run and returns the failed task if present
     * @param nxfRun {
          nxfRuns: [
            {
              trace: [
                {
                    isFailed: bool
                    process: string
                }
              ],
            },
        }
     * @returns {string|*|string}
     */
    const failedStep = (nxfRun) => {
        const traces = nxfRun.trace || [];
        const failed = traces.filter(t => t.isFailed);
        if(failed.length > 1){
            console.log(failed);
            return 'Multiple failed';
        }
        if(failed.length === 1){
            const failedTasks = failed[0]['process'] || '';
            return failedTasks;
        }
        return '';
    };

    const [icon, color] = getIcon(nextflowRun);
    return <Row className={'simple-border height-inherit'}>
        <Col xs={2}>
            <FontAwesomeIcon className={`hv-align ${color} font-size-24`} icon={icon}/>
        </Col>
        <Col xs={2}>
            <p className={'hv-align'}>{new Date(nextflowRun.time).toLocaleString()}</p>
        </Col>
        <Col xs={8} className={'height-inherit word-wrap scroll-y'}>
            <p className={'bold text-align-center'}>{ failedStep(nextflowRun) }</p>
            {
                nextflowRun.errorMessage ? nextflowRun.errorMessage.map((line) => {
                    return <p
                        key={line}
                        className={'text-align-left code'}>{line}</p>;
                }) : <p></p>
            }
        </Col>
    </Row>;
}

export default NextflowRun;
