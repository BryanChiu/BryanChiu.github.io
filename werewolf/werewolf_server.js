//werewolf_server.js

var express = require('express');
var app = express();
//var server = app.listen(3000);

var server = app.listen(3000);


app.use(express.static('public'));

console.log("Werewolf server running");

// var socket = require('socket.io');
// var io = socket(server);

var io = require('socket.io')(server);

io.sockets.on('connection', newConnection);

function newConnection(socket) {
	console.log('New connection: ' + socket.id);

	socket.on('mouse', mouseMsg);

	function mouseMsg(data) {
		socket.broadcast.emit('mouse', data);
		//io.sockets.emit('mouse', data);

		console.log(data);
	}

	socket.on('disconnect', function() {
      console.log("Client has disconnected");
    });
}