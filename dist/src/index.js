var express = require('express');
var Syslog = require('node-syslog');

// Constants
var PORT = 8080;

// App initialization
Syslog.init("node-syslog", Syslog.LOG_PID | Syslog.LOG_ODELAY, Syslog.LOG_LOCAL0);

// App
var app = express();
app.get('/', function (req, res) {
    Syslog.log(
        Syslog.LOG_INFO,
        "incoming request (client='" + req.connection.remoteAddress + "')"
    );
    res.send('Hello world\n');
    
});

app.listen(PORT);
console.log('Running on http://localhost:' + PORT);
