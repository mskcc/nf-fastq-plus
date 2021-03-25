const apiResponse = require('../helpers/apiResponse');
const { getUpdates, saveNextflowUpdate, getRecentRuns } = require('../services/services');
const { logger } = require('../helpers/winston');

/**
 * Returns a random quote
 *
 * @type {*[]}
 */
exports.getPipelineUpdate = [
  function (req, res) {
    const query = req.query || {};
    const run = query.run;
    getUpdates(run).then((updates) => {
      return apiResponse.successResponseWithData(res, 'success', updates);
    });
  },
];

/**
 * Retrieves recent sequencing runs
 *
 * @type {Function[]}
 */
exports.getRecentRuns = [
    function (req, res) {
        const query = req.query || {};
        const numDays = query.days || 30;
        getRecentRuns(numDays).then((runs) => {
            return apiResponse.successResponseWithData(res, 'success', runs);
          })
        }
    ];

exports.sendEvent = [
  function (req, res) {
    logger.info('Received event');

    const body = req.body;
    saveNextflowUpdate(body).then((result) => {
      return apiResponse.successResponseWithData(res, 'success', result);
    });
  },
];
