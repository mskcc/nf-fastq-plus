const apiResponse = require('../helpers/apiResponse');
const { getUpdates, saveNextflowUpdate } = require('../services/services');
const { logger } = require('../helpers/winston');

/**
 * Returns a random quote
 *
 * @type {*[]}
 */
exports.getPipelineUpdate = [
  function (req, res) {
    getUpdates().then((updates) => {
      return apiResponse.successResponseWithData(res, 'success', updates);
    });
  },
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
