var dropzone;
var pict;
var pictResized;
var pictUploaded;
var scaleFactor = 4;
var canvasFrame;

var dots;
var dotsAssigned;
var dotSize = 4;

function setup() {
  var canvas = createCanvas(600, 600);
  canvas.parent('sketch-holder');

  dropzone = select('#dropzone');
  dropzone.dragOver(highlight);
  dropzone.dragLeave(unhighlight);
  dropzone.drop(gotFile, unhighlight);

  pictResized = true;
  pict = createImage(600, 600);

  dots = [];
  initDots();
  dotArrayLength = 0;
  dotsAssigned = 0;
}

function highlight() {
  dropzone.style('background-color', '#cccccc');
}

function unhighlight() {
  dropzone.style('background-color', '#ffffff');
}

function gotFile(file) {
  pict = null;
  canvasFrame = null;
  document.getElementById("dropzone").innerHTML = "Processing file...this will take a few seconds";
  captureCanvas();
  pict = loadImage(file.data);
  pictResized = false;
  pictUploaded = true;
}

function captureCanvas() {
  canvasFrame = createImage(width, height);
  canvasFrame.loadPixels();
  loadPixels();

  for (var i=0; i<pixels.length; i++) {
    canvasFrame.pixels[i] = pixels[i];
  }

  canvasFrame.updatePixels();
}

function resizeImage() {
  if (pict.width>pict.height) {
    pict.resize(width/scaleFactor, 0);
  } else {
    pict.resize(0, height/scaleFactor);
  }
  pict.filter(GRAY);
  pictResized = true;
}

function draw() {
  background(255);
  noFill();
  stroke(0);
  strokeWeight(5);
  rect(0, 0, width, height);
  imageMode(CENTER);
  if (pict.get(0, 0)[3]!=0 && !pictResized) {
    dotsAssigned = 0;
    resizeImage();
    makeDithered(pict, 1);

    if (dotsAssigned<dots.length) {
      for (var i=dotsAssigned; i<dots.length; i++) {
        var randIndex = floor(random(dotsAssigned));
        var randomVec = createVector(dots[randIndex].dest.x, dots[randIndex].dest.y);
        dots[i].assignDest(0, 0);
        dots[i].dest = randomVec;
      }
    }

    image(canvasFrame, width/2, height/2);
    document.getElementById("dropzone").innerHTML = "Drop an image here";
  } else if (pictResized) {
    displayDots();
  } else {
    image(canvasFrame, width/2, height/2);
  }
}

function showImage() {
  noSmooth();
  image(pict, width/2, height/2, pict.width*scaleFactor, pict.height*scaleFactor);
}

function imageIndex(img, x, y) {
  return 4 * (x + y * img.width);
}

function getColorAtindex(img, x, y) {
  var idx = imageIndex(img, x, y);
  var pix = img.pixels;
  var grey = pix[idx];
  return color(grey, grey, grey, 255);
}

function setColorAtIndex(img, x, y, clr) {
  var idx = imageIndex(img, x, y);

  var pix = img.pixels;
  pix[idx] = red(clr);
  pix[idx + 1] = green(clr);
  pix[idx + 2] = blue(clr);
  pix[idx + 3] = alpha(clr);
}

// Finds the closest step for a given value
// The step 0 is always included, so the number of steps
// is actually steps + 1
function closestStep(max, steps, value) {
  return round(steps * value / 255) * floor(255 / steps);
}

function makeDithered(img, steps) {
  img.loadPixels();

  for (var y = 0; y < img.height; y++) {
    for (var x = 0; x < img.width; x++) {
      var clr = getColorAtindex(img, x, y);
      var oldG = red(clr);
      var newG = closestStep(255, steps, oldG);

      var newClr = color(newG, newG, newG);
      setColorAtIndex(img, x, y, newClr);

      var errG = oldG - newG;

      distributeError(img, x, y, errG);

      if (newG == 0) {
        if (dotsAssigned<dots.length) {
          dots[dotsAssigned].assignDest(x, y);
          dotsAssigned++;
        } else {
          var randIndex = floor(random(dots.length));
          var randomVec = createVector(dots[randIndex].pos.x, dots[randIndex].pos.y);
          dots.push(new Dot(dotsAssigned, 0, 0));
          dots[dots.length-1].pos = randomVec;
          dots[dots.length-1].assignDest(x, y);
          dotsAssigned++;
        }
      }
    }
  }

  img.updatePixels();
}

function distributeError(img, x, y, errG) {
  addError(img, 7 / 16.0, x + 1, y, errG);
  addError(img, 3 / 16.0, x - 1, y + 1, errG);
  addError(img, 5 / 16.0, x, y + 1, errG);
  addError(img, 1 / 16.0, x + 1, y + 1, errG);
}

function addError(img, factor, x, y, errG) {
  if (x < 0 || x >= img.width || y < 0 || y >= img.height) return;
  var clr = getColorAtindex(img, x, y);
  var r = red(clr);
  clr.setRed(r + errG * factor);
  clr.setGreen(r + errG * factor);
  clr.setBlue(r + errG * factor);

  setColorAtIndex(img, x, y, clr);
}

function displayDots() {
  noSmooth();
  var iter = 0;
  while (iter<dots.length) {
    dots[iter].display();
    if (mouseIsPressed) {
      dots[iter].pos.x += (pmouseX-mouseX)*(dots[iter].pos.x-width/2)/width;
      dots[iter].pos.y += (pmouseY-mouseY)*(dots[iter].pos.y-height/2)/height;
    } else {
      dots[iter].move();
    }
    if (dots[iter].killMe) {
      dots.splice(iter, 1);
      iter--;
    }
    iter++;
  }
}

function initDots() {
  for (var i=10; i<height; i+=10) {
    for (var j=10; j<width; j+=10) {
      dots.push(new Dot(dots.length, 0, 0));
      dots[dots.length-1].pos = createVector(j, i);
    }
  }
  dotsAssigned = dots.length;
}

function Dot(idin, xin, yin) {
  this.id = idin;
  this.pos = createVector(xin*scaleFactor+width/2-pict.width*scaleFactor/2, yin*scaleFactor+height/2-pict.height*scaleFactor/2);
  this.vel;
  this.dest;
  this.killMe;

  this.assignDest = function(dxin, dyin) {
    this.dest = null;
    this.vel = null;
    this.dest = createVector(dxin*scaleFactor+width/2-pict.width*scaleFactor/2, dyin*scaleFactor+height/2-pict.height*scaleFactor/2);
    this.vel = createVector(this.dest.x-this.pos.x, this.dest.y-this.pos.y);
    this.vel.normalize();
    this.killMe = false;
  }

  this.move = function() {
    if (this.dest == null) return;

    if (abs(this.vel.mag()) > 0.7 || dist(this.pos.x, this.pos.y, this.dest.x, this.dest.y) > 2) {
      this.pos.x += this.vel.x;
      this.pos.y += this.vel.y;

      var newVel = createVector(this.dest.x-this.pos.x, this.dest.y-this.pos.y);
      var distance = dist(this.dest.x, this.dest.y, this.pos.x, this.pos.y);
      newVel.setMag((distance*1.3)/(distance+50));
      this.vel.add(newVel);
      this.vel.mult(0.92); //0.89
    } else {
      this.pos.x = this.dest.x;
      this.pos.y = this.dest.y;
    }

    if (this.id>=dotsAssigned && this.pos.x == this.dest.x && this.pos.y == this.dest.y) {
      this.killMe = true;
    }
  }

  this.display = function() {
    noStroke();
    fill(0);
    ellipse(this.pos.x, this.pos.y, dotSize, dotSize);
  }
}