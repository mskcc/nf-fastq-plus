const { SequenceRunModel, NextflowRunModel, TraceModel } = require('../models/NextflowUpdateModel');
const { logger } = require('../helpers/winston');
const { safe_get } = require('../helpers/utils');

/**
 * Returns list of all sequencing runs passed through nextflow
 * @returns List of Sequencing Run Objects
 */
exports.getUpdates = async function () {
  const savedUpdates = await SequenceRunModel
      .find({})
      .populate({
        path: 'nxfRuns',
        model: 'NextflowRunUpdate',
        populate: {
          path: 'trace',
          model: 'TraceUpdate'
        }
      })
      .exec();
  if(savedUpdates){
    console.log(`Found ${savedUpdates.length} run(s): ${savedUpdates.map(update => update.run)}`);
    const updates = savedUpdates.map(update => update.toJSON());
    return updates;
  }
  console.log("No runs found");
  return [];
};

/**
 *  Returns whether the nextflow event is a start event
 *
 *   START EVENT
 *   {
 *     "metadata":{
 *       "parameters":{
 *         "run":"210315_SCOTT_0313_AHT25CAFX2"
 *       },
 *       "workflow":{ ... }
 *     },
 *     "runId":"cc92cf46-022c-49fe-9052-3bfbc688d534",
 *       "event":"started",
 *       "runName":"trusting_coulomb",
 *       "utcTime":"2021-03-18T19:21:20Z"
 *   }
 */
const is_run_event = function(nxf_event) {
  const metadata = nxf_event['metadata'];
  const has_metadata = metadata !== null && metadata !== undefined;

  if(!has_metadata) {
    return false
  };

  const parameters = metadata['parameters'] || {};
  const run_param = parameters["run"];

  return run_param !== null;
}

/**
 *  Returns whether the nextflow event is a trace event
 *
 *   TRACE EVENT
 *   {
 *     "trace":{
 *       "task_id":1,
 *       "status":"SUBMITTED",
 *       "hash":"1e/9ca43c",
 *       ...
 *     },
 *     "runId":"cc92cf46-022c-49fe-9052-3bfbc688d534",
 *     "event":"process_submitted",
 *     "runName":"trusting_coulomb",
 *     "utcTime":"2021-03-18T19:21:24Z"
 *   }
 */
const is_trace_event = function(nxf_event){
  return nxf_event['trace'] !== null && nxf_event['trace'] !== undefined;
};

const is_error_event = function(nxf_event) {
  const event = nxf_event['event'];
  return 'error' === event;
}
/**
 * Returns query for NextflowRunUpdate document based on input nextflow event
 * @param nextflowEvent, { runId: '...', runName: '...', ... }
 * @returns {{runName: *, runId: *}}
 */
const getNxfRunQry = function(nextflowEvent) {
  const runId = nextflowEvent['runId'];
  const runName = nextflowEvent['runName'];
  return { runId, runName };
};

/**
 * Updates SequenceRunModel
 * @param nextflowEvent
 * @param nxfRunModel
 * @returns {Promise<void>}
 */
const updateSeqRunModel = async function(nextflowEvent, nxfRunModel) {
  const metadata = nextflowEvent['metadata'] || {};
  const parameters = metadata['parameters'];
  const run = parameters['run'];
  const seqRunQuery = { run };
  const workflow = metadata['workflow'] || {};
  const success = workflow['success'];
  const status = nextflowEvent['event'];
  const completed = status.includes('completed');

  let seqRunDoc = await SequenceRunModel.findOne(seqRunQuery);
  if(seqRunDoc !== null){
    console.log("UPDATE: SequenceRunModel");
    if(completed){
      seqRunDoc.pending = false;
      seqRunDoc.totalRuns += 1;
      if(success){
        seqRunDoc.successfulRuns += 1;
      } else {
        seqRunDoc.failedRuns += 1;
      }

    } else {
      // NOTHING TO UPDATE
    }
  } else {
    console.log("CREATE: SequenceRunModel");
    seqRunDoc = Object.assign({
      pending: true,
      totalRuns: 0,
      successfulRuns: 0,
      nxfRuns: [],
      failedRuns: 0
    }, seqRunQuery);
  }

  if(!seqRunDoc.nxfRuns.includes(nxfRunModel._id)){
    seqRunDoc.nxfRuns.push(nxfRunModel._id);
  }

  await SequenceRunModel(seqRunDoc).save();

  SequenceRunModel.findOne()
      .populate({
        path: 'nxfRuns',
        model: 'NextflowRunUpdate',
        populate: {
          path: 'trace',
          model: 'TraceUpdate'
        }
      })
      .exec((err, doc) => {
        if (err) {
          console.log(err.message);
        }
        console.log(`Successfully populated SequenceRun document for ${doc.run}`);
      });
};

/**
 * Retrieves the error message from the nextflow event in the form of a list delimited by the new line characters
 *
 * @param nextflowEvent
 *    {
 *        metadata: {
 *            workflow: {
 *                errorMessage: "... \n ..."
 *            }
 *        }
 *    }
 * @returns {string[]}
 */
const getErrorMessage = function(nextflowEvent) {
  const metaData = nextflowEvent['metadata'] || {};
  const workflow = metaData['workflow'] || {};
  const errorMessage = workflow['errorMessage'] || '';

  return errorMessage.split("\n");
};

/**
 * Updates NextflowRunModel
 *
 * @param nextflowEvent
 * @returns {Promise<FindAndModifyWriteOpResultObject<{success: *, time: *, completed: *}>|*>}
 */
const updateNxfRunModel = async function(nextflowEvent) {
  const nxfRunQuery = getNxfRunQry(nextflowEvent);

  const metadata = nextflowEvent['metadata'] || {};
  const workflow = metadata['workflow'] || {};
  const success = workflow['success'];
  const status = nextflowEvent['event'];
  const completed = status === 'completed' || status.includes('completed');
  let existingNxfRunDoc = await NextflowRunModel.findOne(nxfRunQuery);
  const utcTime = nextflowEvent['utcTime'];
  const time = Date.parse(utcTime);
  const workDir = workflow['workDir'];
  const command = workflow['commandLine'];
  const parameters = metadata['parameters'];
  const run = parameters['run'];
  const errorMessage = getErrorMessage(nextflowEvent);
  if(existingNxfRunDoc !== null){
    const update = { time, completed, success, errorMessage };
    const newDoc = await NextflowRunModel.findOneAndUpdate(nxfRunQuery, update, {
      returnOriginal: false
    });
    return newDoc;
  }

  console.log("CREATE: NextflowRunModel");
  existingNxfRunDoc = Object.assign({
    time,
    completed,
    success,
    workDir,
    command,
    parameters,
    run,
    errorMessage,
    trace: []
  }, nxfRunQuery);
  const nxfRunModel = await NextflowRunModel(existingNxfRunDoc).save();
  if(nxfRunModel === null){
    // Trying to add err-callback to save function removes this
    console.log("ERROR");
  }
  return nxfRunModel;
};

/**
 * Updates TraceModel
 *
 * @param nextflowEvent
 * @returns {Promise<void>}
 */
const updateTraceModel = async function(nextflowEvent) {
  const trace = nextflowEvent['trace'] || {};
  const utcTime = nextflowEvent['utcTime'];
  const time = Date.parse(utcTime);
  const runId = nextflowEvent['runId'];
  const runName = nextflowEvent['runName'];
  const status = nextflowEvent['event'];
  const workDir = trace['workdir'];
  const process = trace['process'];

  const traceInfo = {
    status, runName, runId, time, trace, workDir, process
  };
  const traceDoc = await TraceModel(traceInfo).save();
  if(traceDoc === null){
    console.log("BIG PROBLEM - Couldn't save trace");
  }

  const nxfRunQuery = getNxfRunQry(nextflowEvent);
  const existingNxfRunDoc = await NextflowRunModel.findOne(nxfRunQuery);
  if (existingNxfRunDoc === null) {
    console.log(`BIG PROBLEM: nextflow run does not exist - ${JSON.stringify(nxfRunQuery)}`);
  } else {
    existingNxfRunDoc.trace.push(traceDoc._id);
    existingNxfRunDoc.save((err) => {
      if(err){
        console.log(err.message);
      }
    });
  }
};

const updateSeqRun = async function(nextflowEvent) {
  const nxfRunModel = await updateNxfRunModel(nextflowEvent);
  await updateSeqRunModel(nextflowEvent, nxfRunModel);
};

exports.saveNextflowUpdate = async function (nextflowEvent){
  if(!nextflowEvent['runId']){
    return false;
  }
  if(is_run_event(nextflowEvent)){
    await updateSeqRun(nextflowEvent);
  } else if(is_trace_event(nextflowEvent)){
    await updateTraceModel(nextflowEvent);
  } else if(is_error_event(nextflowEvent)) {
    const runId = nextflowEvent['runId'];
    const runName = nextflowEvent['runName'];
    console.log(`ERROR - runId: ${runId}, runName: ${runName}`);
    /* ERROR looks like this -
    {
      runId: 'ac75a853-5aa9-46b4-8922-a107ea1a1990',
      event: 'error',
      runName: 'festering_einstein',
      utcTime: '2021-03-23T13:42:32Z'
    }
     */
  }
  return true;
};
