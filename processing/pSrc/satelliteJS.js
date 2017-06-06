/* BY BRYAN CHIU
 This project is loosely modelled after satellites orbiting celestial objects.
 BALLS have vary speeds denoted by varying colours (blue=faster, red=slower).
 BALLS are attracted to ANCHORS (green).
 BALLS will appear on other side of frame it exits.
 BALLS will bounce off wall if it's toggled.
 ~~~~
 FEATURES:
 - LEFT click to create an ANCHOR
 - LEFT click on existing ANCHOR to convert into a CRAWLINGANCHOR (ANCHOR that moves).
 - RIGHT click on existing ANCHOR (or CRAWLINGANCHOR) to delete it
 - hold down MOUSE button to create ANCHOR that follows your cursor
 - SCROLL UP to increase ball speed, SCROLL DOWN to decrease
 - press the 'w' key to toggle walls on/off
 ~~~~
 SUGGESTED COOL THINGS TO TRY OUT: (delete initial CRAWLINGANCHOR first) 
 *NOTE: increasing ball speed will reveal final pattern quicker*
 - one static ANCHOR in middle of frame
 - speed up to set pattern, then slow all the way down
 - one static ANCHOR in a corner of frame
 - toggle wall on/off
 - two static ANCHORS in diagonal opposite corners
 - two static ANCHORS ~3 inches apart, away from edges
 - three static ANCHORS ~2 inches apart, forming a triangle
 - one static ANCHOR in corner of frame, one CRAWLINGANCHOR
 - two CRAWLINGANCHORS
 - one following ANCHOR (hold down mouse) along edges of frame
 -toggle wall on/off
 - one following ANCHOR in a circular motion
 ~~~~
 Have fun!
 */

var diamBall = 10; // ball diameter
var diamAnch = 20; // anchor diameter
var ballCount = 400; // number of balls
var ball = []; // array of Balls objects
var anchorArray = []; // arraylist of Anchor objects
var crawlArray = [];
var gravMag=1; // magnitude of gravity towards anchors
var wall; // toggleable border that balls can bounce off of
var noiseOffset = 0; // offset for noise so CrawlingAnchor paths will not be the same

function setup() {
  var canvas = createCanvas(900, 700);
  canvas.parent('sketch-holder');

  // create Ball objects
  for (var i=0; i<ballCount; i++) {
    ball.push(new Balls());
  }

  // create one CrawlingAnchor object
  crawlArray.push(new CrawlingAnchor(width/2, height/2));
}

function draw() {
  // fill translucent background, creating blur effect
  fill(255, 20);
  rect(0, 0, width, height);

  // apply motion physics to and display Balls
  for (var i=0; i<ballCount; i++) {
    ball[i].motion();
    ball[i].display();
  }

  // display anchors
  for (var i=0; i<anchorArray.length; i++) {
    anchorArray[i].display();
  }
  for (var i=0; i<crawlArray.length; i++) {
    crawlArray[i].motion();
    crawlArray[i].display();
  }

  // display Anchor at mouse position if mouse is pressed
  if (mouseIsPressed) {
    strokeWeight(2);
    stroke(100, 255, 100);
    fill(30, 120, 60);
    ellipse(mouseX, mouseY, diamAnch, diamAnch);
  }

  // display (or not) a black border
  noStroke();
  if (wall==true) {
    strokeWeight(10);
    stroke(0);
    noFill();
    rect(0, 0, width, height);
  }

  noiseOffset++; // increase noise offset so new CrawlingAnchors have different initial noise values
}

// CLASSES //

// Balls that fly around
function Balls() {
  this.loc = createVector(random(diamBall, width-diamBall), random(diamBall, height-diamBall)); // location of the ball object
  this.vel = createVector(random(-5, 5), random(-5, 5)); // direction of ball
  this.randomVel = random(8, 16); // random ball speed 
  this.velMag = this.randomVel; // copy of randomVel

  this.motion = function() {
    // calculate gravity of each existing anchor on Ball
    for (var i=0; i<anchorArray.length; i++) {
      var grav = createVector(anchorArray[i].xpos-this.loc.x, anchorArray[i].ypos-this.loc.y);

      // adds gravity to velocity, accumulates with each Anchor
      grav.setMag(gravMag);
      this.vel.add(grav);
    }

    for (var i=0; i<crawlArray.length; i++) {
      var grav = createVector(crawlArray[i].xpos-this.loc.x, crawlArray[i].ypos-this.loc.y);

      // adds gravity to velocity, accumulates with each Anchor
      grav.setMag(gravMag);
      this.vel.add(grav);
    }

    // add an extra Anchor to be calculated if mouse pressed
    if (mouseIsPressed) {
      var grav = createVector(mouseX-this.loc.x, mouseY-this.loc.y);
      grav.setMag(gravMag); //2.55
      this.vel.add(grav);
    }

    // implement gravity on Ball and change location
    this.vel.setMag(this.velMag);
    this.loc.add(this.vel);

    // bounce ball on wall if active
    if (wall) {
      if (this.loc.x>width-diamBall || this.loc.x<diamBall) {
        this.vel.x = this.vel.x *-1;
      }
      if (this.loc.y>height-diamBall || this.loc.y<diamBall) {
        this.vel.y = this.vel.y *-1;
      }
      // if wall not active, Ball appears on other side of frame
    } else {
      if (this.loc.x>width) {
        this.loc.x = 0;
      }
      if (this.loc.x<0) {
        this.loc.x = width;
      }
      if (this.loc.y>height) {
        this.loc.y = 0;
      }
      if (this.loc.y<0) {
        this.loc.y = height;
      }
    }
  }

  // displays ball
  this.display = function() {
    noStroke();
    fill((this.randomVel-8)*30, 0, 240-((this.randomVel-8)*30)); // colour of Ball depends on speed (blue=fast, red=slow)
    ellipse(this.loc.x, this.loc.y, diamBall, diamBall);
  }
}

// object that has gravitational effect on Balls
function Anchor() {
  this.xpos = mouseX; // x position of anchor
  this.ypos = mouseY; // y position of anchor

  // displays anchor
  this.display = function() {
    strokeWeight(2);
    stroke(100, 255, 100);
    fill(30, 120, 60);
    ellipse(this.xpos, this.ypos, diamAnch, diamAnch);
  }
}

// Inherits from Anchor, CrawlingAnchor has random movement
// Requires extra fields & calculations because object has to be created at certain position, while still
//   incorporating random noise position values. Without this, object would appear somewhere random instead 
//   of where it was "converted" from a regular anchor
function CrawlingAnchor(xin, yin) {
  this.noiseVal = noiseOffset; // set initial noise value so all CrawlingAnchors do not follow the same path
  this.xpos = width*noise(this.noiseVal); // actual x position of CrawlingAnchor
  this.ypos = height*noise(this.noiseVal+5); // actual y position of CrawlingAnchor
  this._xpos; // underlying x position determined by noise
  this._ypos; // underlying y position determined by noise
  this.xDiff = this.xpos-xin; // difference between xpos and _xpos
  this.yDiff = this.ypos-yin; // difference between ypos and _ypos

  //underlying position defined by noise
  this.motion = function() {
    this.noiseVal+=0.003;
    this._xpos=width*noise(this.noiseVal);
    this._ypos=height*noise(this.noiseVal+5);
  }

  this.display = function() {
    strokeWeight(2);
    stroke(100, 255, 100);
    fill(30, 120, 60);

    // decrease difference between underlying positions and actual positions
    if (abs(this.xDiff)>1) {
      this.xDiff=this.xDiff/abs(this.xDiff)*(abs(this.xDiff)-1);
    }
    if (abs(this.yDiff)>1) {
      this.yDiff=this.yDiff/abs(this.yDiff)*(abs(this.yDiff)-1);
    }

    // display CrawlingAnchor (actual pos) with offset from underlying pos
    this.xpos = this._xpos-this.xDiff;
    this.ypos = this._ypos-this.yDiff;
    ellipse(this.xpos, this.ypos, diamAnch, diamAnch);
  }
}

// INPUTS //

function mouseReleased() {
  if (mouseX>=0 && mouseX<=width && mouseY>=0 && mouseY<=height) {
    for (var i=0; i<anchorArray.length; i++) {
      var anch = anchorArray[i];
      // if mouse clicked over (or near) an existing Anchor
      if (mouseX>anch.xpos-diamAnch/2 && mouseX<anch.xpos+diamAnch/2 && 
        mouseY>anch.ypos-diamAnch/2 && mouseY<anch.ypos+diamAnch/2) {
        if (mouseButton == LEFT) { // creates CrawlingAnchor if left mouse clicked
          crawlArray.push(new CrawlingAnchor(mouseX, mouseY));
        }
        anchorArray.splice(i, 1); // removes Anchor regardless of RIGHT/LEFT
        return;
      }
    }
    // if mouse clicked over (or near) an existing CrawlingAnchor
    for (var i=0; i<crawlArray.length; i++) {
      var cAnch = crawlArray[i];
      if (mouseX>cAnch.xpos-diamAnch*2 && mouseX<cAnch.xpos+diamAnch*2 && 
        mouseY>cAnch.ypos-diamAnch*2 && mouseY<cAnch.ypos+diamAnch*2 && mouseButton == RIGHT) {
        crawlArray.splice(i, 1); // removes CrawlingAnchor if right mouse clicked
        return false;
      }
    }
    // creates new Anchor if left mouse clicked not on an existing Anchor
    if (mouseButton==LEFT) {
      anchorArray.push(new Anchor());
    }
  }
}

function keyTyped() {
  // 'w' key toggles wall
  if (key==='w') {
    wall = (wall ? false : true); // turn wall on if it's off, turn off it's on
  }
}

// changes speed of all Balls
function mouseWheel(event) {
  if (mouseX>=0 && mouseX<=width && mouseY>=0 && mouseY<=height) {
    var e = event.delta;
    // if scroll upwards, increase gravity of Anchors 
    if (e<0 && gravMag<256) {
      gravMag*=2;
      // if scroll downwards, decrease gravity of Anchors
    } else if (e>1) {
      gravMag/=2;
    }
    // set velocity of Balls relative to gravity, so radius of orbit is constant
    for (var i=0; i<ballCount; i++) {
      ball[i].velMag=ball[i].randomVel*sqrt(gravMag); // ball speed is always relative to gravMag, constant radius
    }

    return false;
  }
}

function mouseClicked() {
  return false;
}