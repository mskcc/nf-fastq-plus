var express = require('express');
var router = express.Router();
var path = require('path');

/**
 * GET home page - react-scripts build front-end app and move to public, i.e. so that ../public/index.html is present
 */
router.get('*', function(req, res) {
  res.sendFile(path.join(__dirname + '/../public/index.html'));
});

module.exports = router;
