import React from 'react';

function TraceView({traceEvents}) {
    // All logging events have a suffix of ":out" instead of ":task"
    const taskProcesses = traceEvents.filter(evt => !evt.process.includes(':out'));
    const processes = new Set(taskProcesses.map(evt => evt.process));

    /**
     * Returns a list of task instances, which each are a list of processes (up to three - "process_submitted",
     * "process_started", & "process_completed")
     *
     * @param events -  Nextflow events
     * @param process - Nextflow task,      e.g. "demultplex:task"
     * @returns {[]}  - E.g. [
     *      [ { process: process_started }, { process: process_started }, { process: process_completed } ],
     *      [ { process: process_started }, { process: process_started }  ],
     * ]
     */
    const getTaskAndEvents = (events, process) => {
        const filtered =  events.filter(evt => evt.process === process);
        const workDirs = new Set(filtered.map(evt => evt.workDir));

        // Collect all events of a task by filtering on the tasks with the work directory they were run in
        const processList = [];
        for(const wd of workDirs) {
            processList.push(filtered.filter(evt => evt.workDir === wd));
        }
        return processList;
    };

    return <div className={'trace-event-log'}>{
        processes.map((process) => {
            const processEvents = getTaskAndEvents(traceEvents, process);
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
            
            return <div>
                <div>
                    <p className={'inline-block float-left'}>{process}</p>
                    <p className={'inline-block float-right'}>{count}</p>
                </div>

                { Object.entries(furthest_to_count_map).map(e => {
                    return <div className={'trace-event'}>
                        <p className={'inline-block'}>{e[0]}</p>: <p className={'inline-block'}>{e[1]}</p> </div>;
                })}
            </div>;
        })
    }</div>;
}

export default TraceView;
