Pong[] pong = new Pong[1];
PaddleN[] paddleN = new PaddleN[1];
PaddleE[] paddleE = new PaddleE[1];
PaddleS[] paddleS = new PaddleS[1];
PaddleW[] paddleW = new PaddleW[1];
boolean gameOver;
int velocity = 4;
int i;

void setup() {
  size (640,480);
  paddleN[0] = new PaddleN();
  paddleE[0] = new PaddleE();
  paddleS[0] = new PaddleS();
  paddleW[0] = new PaddleW();
  pong[0] = new Pong();
  gameOver = false;
  i=0;
}

class PaddleN {
  float xpos = width/2;
  float ypos = height/2;
    
  void display() {
    xpos = mouseX;
    ypos = mouseY;
    fill(255,0,0);
    rectMode(CENTER);
    rect(xpos,15,75,10);
  }
}

class PaddleE {
  float xpos = width/2;
  float ypos = height/2;
    
  void display() {
    xpos = mouseX;
    ypos = mouseY;
    fill(255,0,0);
    rectMode(CENTER);
    rect(width-15,ypos,10,75);
  }
}

class PaddleS {
  float xpos = width/2;
  float ypos = height/2;
    
  void display() {
    xpos = mouseX;
    ypos = mouseY;
    fill(255,0,0);
    rectMode(CENTER);
    rect(xpos,height-15,75,10);
  }
}

class PaddleW {
  float xpos = width/2;
  float ypos = height/2;
    
  void display() {
    xpos = mouseX;
    ypos = mouseY;
    fill(255,0,0);
    rectMode(CENTER);
    rect(15,ypos,10,75);
  }
}

class Pong {
  PVector loc = new PVector(width/2,height/2);
  PVector vel = new PVector(random(-5,5),random(-5,5));
    
  void motion() {
    vel.setMag(velocity);
    
    if (loc.y<30 && loc.y>20 && loc.x>mouseX-37 && loc.x<mouseX+37) {
      vel.y *= -1;
      vel.x = (loc.x-mouseX)/11;
      vel.setMag(velocity);
    }
    if (loc.x>width-30 && loc.y<height-20 && loc.y>mouseY-37 && loc.y<mouseY+37) {
      vel.x *= -1;
      vel.y = (loc.y-mouseY)/11;
      vel.setMag(velocity);
    }
    if (loc.y>height-30 && loc.y<height-20 && loc.x>mouseX-37 && loc.x<mouseX+37) {
      vel.y *= -1;
      vel.x = (loc.x-mouseX)/11;
      vel.setMag(velocity);
    }
    if (loc.x<30 && loc.y>20 && loc.y>mouseY-37 && loc.y<mouseY+37) {
      vel.x *= -1;
      vel.y = (loc.y-mouseY)/11;
      vel.setMag(velocity);
    }
    
    if (loc.x<20 || loc.x>width-20 || loc.y<20 || loc.y>height-20) {
      gameOver = true;
    }
    
    loc.add(vel);
  }
  
  void display() {
    fill(230);
    if (gameOver == true) {
      noFill();
      noStroke();
    }
    ellipse(loc.x,loc.y,20,20);
  }
}

void draw() {
  background(175);
  
  stroke(0);
  
  paddleN[0].display();
  paddleE[0].display();
  paddleS[0].display();
  paddleW[0].display();
  
  pong[0].motion();
  pong[0].display();
  
  if (gameOver == true) {
    noStroke();
    fill(100,150);
    rectMode(CENTER);
    rect(width/2,height/2,450,85);
    textAlign(CENTER,CENTER);
    textSize(72);
    fill(0);
    text("GAME OVER",width/2,height/2-10);
    i++;
    if (i>150) {
      setup();
    }
  }
}