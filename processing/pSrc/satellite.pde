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

float diamBall = 10; // ball diameter
float diamAnch = 20; // anchor diameter
int ballCount = 400; // number of balls
Balls[] ball = new Balls[ballCount]; // array of Balls objects
ArrayList<Anchor> anchorArray = new ArrayList<Anchor>(); // arraylist of Anchor objects
float gravMag=1; // magnitude of gravity towards anchors
boolean wall; // toggleable border that balls can bounce off of
int noiseOffset; // offset for noise so CrawlingAnchor paths will not be the same

void setup() {
  size(600, 600);
  
  // create Ball objects
  for (int i=0; i<ballCount; i++) {
    ball[i] = new Balls();
  }
  
  // create one CrawlingAnchor object
  anchorArray.add(new CrawlingAnchor(width/2,height/2));
}

void draw() {
  // fill translucent background, creating blur effect
  fill(255,20);
  rect(0, 0, width, height);
  
  // apply motion physics to and display Balls
  for (int i=0; i<ballCount; i++) {
    ball[i].motion();
    ball[i].display();
  }

  // display anchors
  for (Anchor anch : anchorArray) {
    anch.display();
    if (anch instanceof CrawlingAnchor) {
      CrawlingAnchor cAnch = (CrawlingAnchor) anch;
      cAnch.motion();
    }
  }
  
  // display Anchor at mouse position if mouse is pressed
  if (mousePressed) {
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
class Balls {
  PVector loc = new PVector(random(diamBall, width-diamBall), random(diamBall, height-diamBall)); // location of the ball object
  PVector vel = new PVector(random(-5, 5), random(-5, 5)); // direction of ball
  float randomVel = random(8, 16); // random ball speed 
  float velMag = randomVel; // copy of randomVel

  void motion() {
    // calculate gravity of each existing anchor on Ball
    for (Anchor anch : anchorArray) {
      PVector grav = new PVector(anch.xpos-loc.x, anch.ypos-loc.y);
      if (anch instanceof CrawlingAnchor) {
        CrawlingAnchor cAnch = (CrawlingAnchor) anch;
        grav = new PVector(cAnch.xpos-loc.x, cAnch.ypos-loc.y);
      }

      // adds gravity to velocity, accumulates with each Anchor
      grav.setMag(gravMag);
      vel.add(grav);
    }
    
    // add an extra Anchor to be calculated if mouse pressed
    if (mousePressed) {
      PVector grav = new PVector(mouseX-loc.x, mouseY-loc.y);
      grav.setMag(gravMag); //2.55
      vel.add(grav);
    }

    // implement gravity on Ball and change location
    vel.setMag(velMag);
    loc.add(vel);

    // bounce ball on wall if active
    if (wall==true) {
      if (loc.x>width-diamBall || loc.x<diamBall) {
        vel.x = vel.x *-1;
      }
      if (loc.y>height-diamBall || loc.y<diamBall) {
        vel.y = vel.y *-1;
      }
    // if wall not active, Ball appears on other side of frame
    } else {
      if (loc.x>width) {
        loc.x = 0;
      }
      if (loc.x<0) {
        loc.x = width;
      }
      if (loc.y>height) {
        loc.y = 0;
      }
      if (loc.y<0) {
        loc.y = height;
      }
    }
  }

  // displays ball
  void display() {
    noStroke();
    fill((randomVel-8)*30, 0, 240-((randomVel-8)*30)); // colour of Ball depends on speed (blue=fast, red=slow)
    ellipse(loc.x, loc.y, diamBall, diamBall);
  }
}

// object that has gravitational effect on Balls
class Anchor {
  float xpos = mouseX; // x position of anchor
  float ypos = mouseY; // y position of anchor

  // displays anchor
  void display() {
    strokeWeight(2);
    stroke(100, 255, 100);
    fill(30, 120, 60);
    ellipse(xpos, ypos, diamAnch, diamAnch);
  }
}

// Inherits from Anchor, CrawlingAnchor has random movement
// Requires extra fields & calculations because object has to be created at certain position, while still
//   incorporating random noise position values. Without this, object would appear somewhere random instead 
//   of where it was "converted" from a regular anchor
class CrawlingAnchor extends Anchor {
  float xpos; // actual x position of CrawlingAnchor
  float ypos; // actual y position of CrawlingAnchor
  float _xpos; // underlying x position determined by noise
  float _ypos; // underlying y position determined by noise
  float xDiff; // difference between xpos and _xpos
  float yDiff; // difference between ypos and _ypos
  float noiseVal = noiseOffset; // set initial noise value so all CrawlingAnchors do not follow the same path
  
  // constructor, takes initial positions as arguments
  CrawlingAnchor(int xin, int yin) {
    xpos=width*noise(noiseVal); // initial underlying position
    ypos=height*noise(noiseVal+5);
    xDiff = xpos-xin; // initial difference between actual pos and underlying pos
    yDiff = ypos-yin;
  }
  
  //underlying position defined by noise
  void motion() {
    noiseVal+=0.003;
    _xpos=width*noise(noiseVal);
    _ypos=height*noise(noiseVal+5);
  }
  
  void display() {
    strokeWeight(2);
    stroke(100, 255, 100);
    fill(30, 120, 60);
    
    // decrease difference between underlying positions and actual positions
    if (abs(xDiff)>1) {
      xDiff=xDiff/abs(xDiff)*(abs(xDiff)-1);        
    }
    if (abs(yDiff)>1) {
      yDiff=yDiff/abs(yDiff)*(abs(yDiff)-1);        
    }
    
    // display CrawlingAnchor (actual pos) with offset from underlying pos
    xpos = _xpos-xDiff;
    ypos = _ypos-yDiff;
    ellipse(xpos, ypos, diamAnch, diamAnch);
  }
}

// INPUTS //

void mouseReleased() {
  for (int i=0; i<anchorArray.size(); i++) {
    Anchor anch = anchorArray.get(i);
    // if mouse clicked over (or near) an existing Anchor
    if (mouseX>anch.xpos-diamAnch/2 && mouseX<anch.xpos+diamAnch/2 && 
        mouseY>anch.ypos-diamAnch/2 && mouseY<anch.ypos+diamAnch/2 && !(anch instanceof CrawlingAnchor)) {
      if (mouseButton == LEFT) { // creates CrawlingAnchor if left mouse clicked
        anchorArray.add(new CrawlingAnchor(mouseX, mouseY));          
      }
      anchorArray.remove(i); // removes Anchor regardless of RIGHT/LEFT
      return;
    }
    // if mouse clicked over (or near) an existing CrawlingAnchor
    if (anch instanceof CrawlingAnchor) {
      CrawlingAnchor cAnch = (CrawlingAnchor) anch;
      if (mouseX>cAnch.xpos-diamAnch*2 && mouseX<cAnch.xpos+diamAnch*2 && 
          mouseY>cAnch.ypos-diamAnch*2 && mouseY<cAnch.ypos+diamAnch*2 && mouseButton==RIGHT) {
        anchorArray.remove(i); // removes CrawlingAnchor if right mouse clicked
        return;
      }
    }
  }
  // creates new Anchor if left mouse clicked not on an existing Anchor
  if (mouseButton==LEFT) {
    anchorArray.add(new Anchor());
  }
}

void keyPressed() {
  // 'w' key toggles wall
  if (key=='w') {
    wall = wall==true ? false : true; // turn wall on if it's off, turn off it's on
  }
}

// changes speed of all Balls
void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  // if scroll upwards, increase gravity of Anchors 
  if (e==-1 && gravMag<256) {
    gravMag*=2;
  // if scroll downwards, decrease gravity of Anchors
  } else if (e==1) {
    gravMag/=2;
  }
  // set velocity of Balls relative to gravity, so radius of orbit is constant
  for (int i=0; i<ballCount; i++) {
    ball[i].velMag=ball[i].randomVel*sqrt(gravMag); // ball speed is always relative to gravMag, constant radius
  }
}