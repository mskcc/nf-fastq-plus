import React, {useState} from 'react';
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import IconButton from "@material-ui/core/IconButton";
import {faFileAlt} from "@fortawesome/free-solid-svg-icons";

import TraceView from "./trace-view";

function NextflowRun({nextflowRun}) {
    const [showLogs, setShowLogs] = useState(true);

    return <div className={"inline-block"}>
        <div className={"sequencing-run-info"}>
            <IconButton aria-label="show-logs"
                        onClick={() => setShowLogs(!showLogs)}
                        className={"bottom-left"}>
                <FontAwesomeIcon className={""}
                                 icon={faFileAlt}/>
            </IconButton>
            <div>
                <p className={'text-align-left'}>{nextflowRun.runName}</p>
                <p className={'text-align-right'}>Completed: {nextflowRun.completed.toString()}</p>
                <p className={'text-align-right'}>Success: {nextflowRun.success.toString()}</p>
                <p className={'text-align-right'}>{nextflowRun.time}</p>
            </div>
        </div>
        <div className={'flex-container'}>
            {
                showLogs ? <TraceView traceEvents={nextflowRun['trace']}></TraceView> : <div></div>
            }
        </div>
    </div>
}

export default NextflowRun;
