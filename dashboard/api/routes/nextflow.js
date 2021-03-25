var express = require('express');
const NextflowUpdatesController = require('../controllers/NextflowUpdatesController');
var router = express.Router();

router.get('/recent-runs', NextflowUpdatesController.getRecentRuns);
router.get('/get-pipeline-update', NextflowUpdatesController.getPipelineUpdate);
router.post('/send-nextflow-event', NextflowUpdatesController.sendEvent);

module.exports = router;
