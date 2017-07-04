//werewolf.js

var socket;
var canvasImage;
var touchDraw;

function setup() {
	var canvas = createCanvas(windowWidth, (windowHeight>1300? 1300 : windowHeight));
	socket = io.connect('http://localhost:3000');
	socket.on('mouse', newDrawing)
	canvasImage = createGraphics(width, height);
}

function draw() {
	background(200);
	if (mouseIsPressed || touchDraw) {
		canvasImage.fill(0);
		canvasImage.ellipse(mouseX, mouseY, 50, 50);
		sendInfo();
	}
	image(canvasImage, 0, 0);
	ellipse(mouseX, mouseY, 50, 50);
}

function newDrawing(data) {
	canvasImage.fill(255,0,0);
	canvasImage.ellipse(data.x, data.y, 50, 50);
}

function sendInfo() {
	var data = {
		x: mouseX,
		y: mouseY
	}

	socket.emit('mouse', data);
}

function touchStarted() {
	touchDraw = true;
	return false;
}

function touchMoved() {
	return false;
}

function touchEnded() {
	touchDraw = false;
}