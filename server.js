// https://devcenter.heroku.com/articles/getting-started-with-nodejs

var express = require("express");
var logfmt = require("logfmt");
var app = express();

app.use(logfmt.requestLogger());

var buildRedirectURL = function(req, path) {
  return path + (req._parsedUrl.search || '');
};


// Example of a redirect
// app.get('/redirect', function(req, res){
//   res.redirect(301, buildRedirectURL(req, '/'));
// });

app.use(express.static(__dirname + '/dist'));

// REQUEST.HTML
app.get(/^\/.*/, function(req, res){
  res.sendfile('index.html', {root: './dist'});
});

module.exports = app;
