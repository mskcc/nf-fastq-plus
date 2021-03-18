const apiResponse = require('../helpers/apiResponse');
const { getUpdates, saveNextflowUpdate } = require('../services/services');
const { logger } = require('../helpers/winston');
const { safe_get } = require('../helpers/utils');

/**
 * Returns a random quote
 *
 * @type {*[]}
 */
exports.getPipelineUpdate = [
  function (req, res) {
    console.log('Making query');
    logger.info('Making query');
    getUpdates().then((updates) => {
      const run_id_map = process_updates(updates);
      return apiResponse.successResponseWithData(res, 'success', run_id_map);
    });
  },
];

exports.sendEvent = [
  function (req, res) {
    console.log('Received event');
    logger.info('Received event');

    const body = req.body;

    saveNextflowUpdate(body).then((result) => {
      return apiResponse.successResponseWithData(res, 'success', result);
    });
  },
]

const process_updates = function(updates) {
  console.log(updates);

  const run_ids = updates.map(update => update['run_id']);
  const run_id_map = {}
  for(const rid of run_ids){
    run_id_map[rid] = [];
  }

  for(const update of updates){
    const key = update['run_id'];
    if(run_id_map[key]){
      run_id_map[key].push(update);
    } else {
      run_id_map[key] = [ update ];
    }
  }

  const update_resp = [];

  for (const [run_id, updates] of Object.entries(run_id_map)) {
    console.log(run_id);

    // TODO
    // const sorted_updates = sorted(updates, key=lambda update: update['time']['$date'], reverse=True)
    const sorted_updates = updates;
    const formatted_updates = sorted_updates.map(update => format_event(update));

    update_resp.push({
      'runId': run_id,
      'updates': formatted_updates
    });
  }
  return update_resp;
}


/**
 * Formats event for API.
 * @param event
 * @returns {{time: *, status: *}}
 */
const format_event = function(event){
  const time_object = event['time'] ? event['time'] : {}
  const time = safe_get(time_object, '$date');

  const formatted = {
    time,
    'status': event['status'],
  };

  const info_object = {};
  if(is_project_event(event)){
    formatted['type'] = 'project';
    // Project events should have a 'metadata' field
    const metadata = event['metadata'];
    const workflow = metadata['workflow'];
    const projectName = safe_get(workflow, 'projectName');
    formatted['name'] = projectName;

    info_object['parameters'] = safe_get(metadata, 'parameters');
    info_object['commandLine'] = safe_get(workflow, 'commandLine');
    info_object['configFiles'] = safe_get(workflow, 'configFiles');
    info_object['projectName'] = projectName;
    info_object['success'] = safe_get(workflow, 'success');
    info_object['metadata'] = metadata;
  }
  else{
    formatted['type'] = 'process';
    // Process events should have a 'trace' field
    const trace = event['trace'];
    formatted['name'] = safe_get(trace, 'name');
    info_object['status'] = safe_get(trace, 'status');
    info_object['submitTime'] = safe_get(trace, 'submit');
    info_object['script'] = safe_get(trace, 'script');

    info_object['trace'] = trace;

    formatted['info'] = info_object;
  }


  return formatted
};

const is_project_event = function(event){
  const md = event['metadata'];
  return md !== null && md !== undefined && Object.keys(md).length > 0;
};
