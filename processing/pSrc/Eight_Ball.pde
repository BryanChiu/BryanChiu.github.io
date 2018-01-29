ArrayList<Ball> balls = new ArrayList<Ball>();
float friction = 0.99;
float bounceFric = 0.95;
//board dimensions
int x1 = 100;
int x2 = 1100;
int y1 = 100; 
int y2 = 600;
//
float d = 28.3; //ball diameter
PVector rackInit = new PVector((x2-x1)*0.25+x1, (y2-y1)/2+y1); //initial position of first ball in rack
PVector cueInit = new PVector((x2-x1)*0.75+x1, (y2-y1)/2+y1); //initial position of cue ball
//initial positions of cue ball and rack, two arrays corresponding to x and y
float[] xInit = new float[]{cueInit.x, rackInit.x, rackInit.x-d*sqrt(3)/2, rackInit.x-d*3*sqrt(3)/2, 
  rackInit.x-d*3*sqrt(3)/2, rackInit.x-d*2*sqrt(3)/2, rackInit.x-d*4*sqrt(3)/2, rackInit.x-d*4*sqrt(3)/2, 
  rackInit.x-d*2*sqrt(3)/2, rackInit.x-d*3*sqrt(3)/2, rackInit.x-d*3*sqrt(3)/2, rackInit.x-d*4*sqrt(3)/2, 
  rackInit.x-d*4*sqrt(3)/2, rackInit.x-d*sqrt(3)/2, rackInit.x-d*2*sqrt(3)/2, rackInit.x-d*4*sqrt(3)/2};
float[] yInit = new float[]{cueInit.y, rackInit.y, rackInit.y+d/2, rackInit.y-d/2-d, rackInit.y+d/2, 
  rackInit.y+d, rackInit.y, rackInit.y+d*2, rackInit.y, rackInit.y-d/2, rackInit.y+d/2+d, rackInit.y+d, 
  rackInit.y-d, rackInit.y-d/2, rackInit.y-d, rackInit.y-d*2};
//
PVector[] holes = new PVector[]{new PVector(100, 100), new PVector(600, 90), new PVector(1100, 100), 
  new PVector(1100, 600), new PVector(600, 610), new PVector(100, 600)};
int holeD = 75;
color[] cols = new color[]{color(10), color(200, 200, 0), color(0, 50, 200), color(200, 0, 0), 
  color(80, 0, 80), color(200, 140, 0), color(0, 180, 0), color(120, 0, 0)};
enum Pattern {
  SOLID, STRIPE, NONE
};
boolean cueReady; //cue ball can be hit (no balls moving)
boolean cueActivated; //cue ball has been clicked on, not shot yet
PVector cueVel; //velocity of cuestick to be transferred to cue ball
int solidScore;
int stripeScore;
boolean solidIn;
boolean stripeIn;
Pattern turn;
Pattern firstContact;
boolean turnDetermined;
boolean scratch;
boolean gameOver;

void setup() {
  size(1200, 700);
  newGame();
}

void newGame() {
  if (balls!=null) {
    balls.clear();
  }
  for (int i=0; i<16; i++) {
    balls.add(new Ball());
    balls.get(i).cen = new PVector(xInit[i], yInit[i]); //rack initial pos
    balls.get(i).id = i; //give balls number id
    balls.get(i).col = cols[i%8]; //give balls colour
    if (i%8==0) { //give balls pattern
      balls.get(i).patt = Pattern.NONE;
    } else if (i/8==0) {
      balls.get(i).patt = Pattern.SOLID;
    } else {
      balls.get(i).patt = Pattern.STRIPE;
    }
  }
  balls.get(0).col = color(255);
  cueActivated = false;
  cueReady = true;
  solidScore = 0;
  stripeScore = 0;
  solidIn = false;
  stripeIn = false;
  turn = Pattern.NONE;
  firstContact = Pattern.NONE;
  turnDetermined = false;
  scratch = false;
  gameOver = false;
}

void draw() {
  drawBoard();
  ballsInMotion();
  if (cueReady && !(turnDetermined)) {
    determineTurn();
  }
  if (scratch && cueReady) {
    resetCueBall();
  }
  if (mousePressed && !(cueActivated) && cueReady && balls.get(0).id==0 && 
    sqrt(sq(mouseX-balls.get(0).cen.x)+sq(mouseY-balls.get(0).cen.y))<=d/2) { //cue ball clicked
    cueActivated = true;
  }
  if (mousePressed && cueActivated) { //cue ball activated, aiming
    cueStickAim();
  }
  if (gameOver) {
    gameOverTitle();
  }
}

void drawBoard() {
  background(25, 125, 25);
  noStroke();
  fill(0, 50, 0);
  for (PVector hole : holes) {
    ellipse(hole.x, hole.y, holeD, holeD);
  }
  fill(200);
  rect(0, 0, width, y1);
  rect(0, 0, x1, height);
  rect(100, y2, x2, y1);
  rect(x2, y1, x1, y2);
  stroke(255);
  line(cueInit.x, y1, cueInit.x, y2); //line is 1/5 from edge
  noStroke();
  fill(0);
  ellipse(cueInit.x, cueInit.y, 10, 10);
  fill(255);
  ellipse(rackInit.x, rackInit.y, 5, 5);
  fill(0);
  textAlign(LEFT, CENTER);
  textSize(20);
  text("Solids: "+Integer.toString(solidScore), width-120, height-70);
  text("Stripes: "+Integer.toString(stripeScore), width-120, height-40);
  textSize(10);
  if (turn==Pattern.SOLID) {
    text("TURN", width-160, height-70);
  } else if (turn==Pattern.STRIPE) {
    text("TURN", width-160, height-40);
  }
}

void ballsInMotion() {
  cueReady=true;
  for (int i=0; i<balls.size(); i++) {
    balls.get(i).motion();
    balls.get(i).display();
    if (balls.get(i).vel.mag()!=0.000) { //make sure all balls are still
      cueReady=false;
      turnDetermined=false;
    }
    if (balls.get(i).inHole()) { //remove ball if it gets sunk
      ballSunk(balls.get(i).id);
      balls.remove(i);
      i++;
    }
  }
}

void determineTurn() { //determine whose turn it is
  if (turn==Pattern.NONE && solidIn && !(stripeIn)) {
    turn = Pattern.SOLID;
  } else if (turn==Pattern.NONE && stripeIn && !(solidIn)) {
    turn = Pattern.STRIPE;
  } else if (turn==Pattern.STRIPE && (!(stripeIn) || !(firstContact==Pattern.STRIPE))) {
    if (!(firstContact==Pattern.STRIPE)) {
      scratch=true;
      if (balls.get(0).id==0) {
        balls.remove(0);
      }
    }
    turn = Pattern.SOLID;
  } else if (turn==Pattern.SOLID && (!(solidIn) || !(firstContact==Pattern.SOLID))) {
    if (!(firstContact==Pattern.SOLID)) {
      scratch=true;
      if (balls.get(0).id==0) {
        balls.remove(0);
      }
    }
    turn = Pattern.STRIPE;
  }
  solidIn = false;
  stripeIn = false;
  firstContact = Pattern.NONE;
  turnDetermined = true;
}

void cueStickAim() { //display aiming line
  cueVel = new PVector(balls.get(0).cen.x-mouseX, balls.get(0).cen.y-mouseY);
  if (cueVel.mag()>125) {
    cueVel.setMag(125);
  }
  stroke(0);
  line(balls.get(0).cen.x, balls.get(0).cen.y, balls.get(0).cen.x-cueVel.x, balls.get(0).cen.y-cueVel.y);
  stroke(200, 0, 0);
  line(balls.get(0).cen.x, balls.get(0).cen.y, balls.get(0).cen.x+(cueVel.x*100), balls.get(0).cen.y+(cueVel.y*100));
}

void resetCueBall() { //reset cue ball after cue ball sunk
  fill(255, 50);
  ellipse(mouseX, mouseY, d, d);
  if (mousePressed && validCuePlacement(mouseX, mouseY)) {
    scratch = false;
    balls.add(0, new Ball());
    balls.get(0).id = 0;
    balls.get(0).patt = Pattern.NONE;
    balls.get(0).cen = new PVector(mouseX, mouseY);
    balls.get(0).col = color(255);
  }
}

boolean validCuePlacement(int x, int y) {
  for (Ball bawl : balls) {
    if (sqrt(sq(bawl.cen.x-x)+sq(bawl.cen.y-y))<=d) {
      return false;
    }
  }
  return x>x1+d/2 && x<x2-d/2 && y>y1+d/2 && y<y2-d/2;
}

void ballSunk(int id) {
  switch (id) {
  case 0: //cue ball sunk
    scratch=true;
    break;
  case 8: //8 ball sunk
    if (turn==Pattern.SOLID) {
      if (solidScore==7) { //solids wins
        solidScore++;
        turn = Pattern.SOLID;
      } else {
        turn = Pattern.STRIPE;
      }
    } else {
      if (stripeScore==7) { //stripes wins
        stripeScore++;
        turn = Pattern.STRIPE;
      } else {
        turn = Pattern.SOLID;
      }
    }
    gameOver=true;
    break;
  default: //regular ball sunk
    if (id<8) {
      solidScore++;
      solidIn = true;
    } else {
      stripeScore++;
      stripeIn = true;
    }
    break;
  }
}

void mouseReleased() {
  if (cueActivated) {
    cueActivated = false;
    balls.get(0).vel = cueVel.copy().mult(0.2);
  }
  if (gameOver) {
    newGame();
  }
}

void gameOverTitle() {
  fill(0);
  textAlign(CENTER, CENTER);
  textSize(120);
  text("GAME OVER", width/2, height/2-100);
  if (turn==Pattern.SOLID) {
    text("Solids Win", width/2, height/2+100);
  } else {
    text("Stripes Win", width/2, height/2+100);
  }
}

class Ball {
  PVector cen;
  float rad = d/2;
  PVector vel = new PVector(0, 0);
  int id;
  Pattern patt;
  color col;
  boolean inPlay = true;

  void motion() {
    cen.x+=vel.x;
    cen.y+=vel.y;
    if (cen.x<x1+rad) {
      cen.x = x1+rad;
      vel.x *= -bounceFric;
    }
    if (cen.x>x2-rad) {
      cen.x = x2-rad;
      vel.x *= -bounceFric;
    }
    if (cen.y<y1+rad) {
      cen.y = y1+rad;
      vel.y *= -bounceFric;
    }
    if (cen.y>y2-rad) {
      cen.y = y2-rad;
      vel.y *= -bounceFric;
    }
    for (Ball bawl : balls) {
      if (!(bawl==this)) {
        if (this.rad+bawl.rad >= PVector.dist(this.cen, bawl.cen)) {
          PVector connect = new PVector(bawl.cen.x-this.cen.x, bawl.cen.y-this.cen.y);
          float angle = atan2(connect.y, connect.x);
          float targetX = this.cen.x + cos(angle) * (this.rad+bawl.rad);
          float targetY = this.cen.y + sin(angle) * (this.rad+bawl.rad);
          float ax = targetX - bawl.cen.x;
          float ay = targetY - bawl.cen.y;
          this.vel.x -= ax;
          this.vel.y -= ay;
          bawl.vel.x += ax;
          bawl.vel.y += ay;
          this.vel.mult(bounceFric);
          bawl.vel.mult(bounceFric);
          if (firstContact==Pattern.NONE && this.id==0) {
            if (bawl.id<8) {
              firstContact = Pattern.SOLID;
            } else if (bawl.id>8) {
              firstContact = Pattern.STRIPE;
            }
          }
        }
      }
    }
    vel.mult(friction);
    if (vel.mag()<0.05) {
      vel.setMag(0);
    }
  }

  boolean inHole() {
    for (PVector hole : holes) {
      if (sqrt(sq(hole.x-cen.x)+sq(hole.y-cen.y))<=holeD/2) {
        return true;
      }
    }
    return false;
  }

  void display() {
    fill(255);
    ellipse(cen.x, cen.y, d, d);
    fill(col);
    if (patt==Pattern.STRIPE) {
      rect(cen.x-rad*0.75, cen.y-rad*0.7, d*.75, d*.7);
    } else {
      ellipse(cen.x, cen.y, d, d);
    }
  }
}