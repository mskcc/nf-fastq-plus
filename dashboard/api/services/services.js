const NextflowUpdateModel = require('../models/NextflowUpdateModel');
const { logger } = require('../helpers/winston');
const { safe_get } = require('../helpers/utils');

/**
 * Returns a random quote in the database
 * @returns {Promise<*>}
 */
exports.getUpdates = async function () {
  /*
  const d = datetime.utcnow() - timedelta(minutes=60)
  query = NextflowUpdate.objects(time__gte=d)
  return json.loads(query.to_json())
  return {};
   */
  const savedUpdates = await NextflowUpdateModel.find({});
  if(savedUpdates){
    const updates = savedUpdates.map(update => update.toJSON());
    return updates;
  }
  return [];
};

exports.saveNextflowUpdate = async function (nextflowEvent){
  if(!nextflowEvent['runId']){
    return false;
  }

  const run_id = nextflowEvent['runId'];
  const run_name = nextflowEvent['runName'];
  const utcTime = nextflowEvent['utcTime'];
  const time = Date.parse(utcTime);
  const status = nextflowEvent['event'];
  const trace = nextflowEvent['trace'] || {};
  const metadata = nextflowEvent['metadata'] || {};

  console.log(nextflowEvent);

  const update = {run_id, run_name, status, trace, metadata, time };
  await NextflowUpdateModel(update).save(function (err) {
    if (err) {
      throw new Error(err.message);
    }
  });

  return true;
};
