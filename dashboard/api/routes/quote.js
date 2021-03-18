var express = require('express');
const QuotesController = require('../controllers/NextflowUpdatesController');
var router = express.Router();

router.get('/get-pipeline-update', QuotesController.getPipelineUpdate);
router.post('/send-nextflow-event', QuotesController.sendEvent);

module.exports = router;
