import React from 'react';

function TraceView({traceEvents}) {
    const taskProcesses = traceEvents.filter(evt => !evt.process.includes(":out"));

    const processes = new Set(taskProcesses.map(evt => evt.process));

    const getCount = (events, process) => {
        const filtered = getProcessFromEvents(events, process);
        const count = filtered.length;
        return count;
    };

    const getProcessTimeStamp = (events, process) => {
        // const times =
    };

    const getProcessFromEvents = (events, process) => {
        const filtered =  events.filter(evt => evt.process === process);
        const workDirs = new Set(filtered.map(evt => evt.workDir));

        const processList = [];
        for(const wd of workDirs) {
            processList.push(filtered.filter(evt => evt.workDir === wd));
        }


        return processList;
    };

    return <div className={"trace-event-log"}>{
        processes.map((process) => {
            const processEvents = getProcessFromEvents(traceEvents, process);
            const count = processEvents.length;
            const furthest_to_count_map = processEvents.reduce((mapping, events) => {
                const furthest = events.reduce((latest, evt) => {
                    return new Date(latest.time) > new Date(evt.time) ? latest : evt;
                }, events[0]);
                const status = furthest.status;
                if (status in mapping){
                    mapping[status] += 1;
                } else {
                    mapping[status] = 1;
                }
                return mapping;
            }, {});

            const entries = Object.entries(furthest_to_count_map);

            return <div>
                <div>
                    <p className={"inline-block float-left"}>{process}</p>
                    <p className={"inline-block float-right"}>{count}</p>
                </div>

                { Object.entries(furthest_to_count_map).map(e => {
                    return <div className={"trace-event"}>
                        <p className={"inline-block"}>{e[0]}</p>: <p className={"inline-block"}>{e[1]}</p> </div>
                })}
            </div>
        })
    }</div>

    /*
    return <div>{ traceEvents.map((trace) => {
            return <div>
                <p>{trace.process}</p>
                <p>{trace.status}</p>
                <p>{trace.time}</p>
                <p>{trace.workDir}</p>
            </div>
    })}</div>
     */
}

export default TraceView;
