server = require('./server.js');

var port = Number(process.env.PORT || 8080);

server.listen(port, function() {
  console.log("Listening on " + port);
});
