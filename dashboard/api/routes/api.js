var express = require('express');
var quoteRouter = require('./quote');

var app = express();

app.use('/nextflow', quoteRouter);

module.exports = app;
