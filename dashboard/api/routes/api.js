var express = require('express');
var quoteRouter = require('./nextflow');

var app = express();

app.use('/nextflow', quoteRouter);

module.exports = app;
