var express = require('express');
var nextflowRouter = require('./nextflow');

var app = express();

app.use('/nextflow', nextflowRouter);

module.exports = app;
