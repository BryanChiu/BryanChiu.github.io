boolean displayMenu;
boolean drawingTrack;
ArrayList<PVector> checkpoints = new ArrayList<PVector>();

ArrayList<Ball> balz = new ArrayList<Ball>();

boolean genRunning;
int generationCount = 0;
int firstSuccess = 9999;
int totalQuickest = 9999;
int updateTimer = 0;
int genQuickest;
int genFurthestCP;
float genClosest;

void setup() {
  size(900, 600);
  background(150, 150, 250);
  loadPixels();
  displayMenu = true;
  drawingTrack = false;
  genRunning = false;
}

void draw() {
  background(150, 150, 250);
  if (displayMenu) {
    menuScreen();
  } else if (drawingTrack) {
    drawTrack();
  } else {
    background(150, 150, 250);
    if (genRunning && updateTimer<totalQuickest*2) {
      runGeneration();
    } else {
      resetGeneration();
    }

    fill(0);
    textAlign(RIGHT);
    textSize(20);
    text("Generation: "+str(generationCount), width-10, height-10);
    textAlign(LEFT);
    textSize(14);
    text("Generation timer: "+str(updateTimer), 10, height-50);
    if (totalQuickest!=9999) {
      text("Quickest success: "+str(totalQuickest), 10, height-30);
    } else {
      text("Quickest success: -", 10, height-30);
    }
    if (firstSuccess!=9999) {
      text("First successful generation: "+str(firstSuccess), 10, height-10);
    } else {
      text("First successful generation: -", 10, height-10);
    }
  }
}

void menuScreen() {
  textAlign(CENTER, CENTER);
  fill(0);
  textSize(72);
  text("SUPER COMPUTER RACE!", width/2, height/2-30);
  textSize(32);
  text("Draw track with mouse", width/2, height/2+30);
}

void drawTrack() {
  updatePixels();
  stroke(0);
  strokeWeight(60);
  line(pmouseX, pmouseY, mouseX, mouseY);
  loadPixels();
  if (checkpoints.size()==0 || dist(checkpoints.get(checkpoints.size()-1).x, checkpoints.get(checkpoints.size()-1).y, mouseX, mouseY)>150) {
    PVector chkpnt = new PVector(mouseX, mouseY);
    checkpoints.add(chkpnt);
  }
}

void runGeneration() {
  updatePixels();
  genRunning = false;
  for (Ball bawl : balz) {
    bawl.motion();
    if (updateTimer%15==0 && !(bawl.reached) && !(bawl.crashed)) {
      bawl.control(updateTimer/15);
    }
    bawl.display();
  }

  updateTimer++;
}

void resetGeneration() {
  ArrayList<Integer> topDNA = new ArrayList<Integer>();
  float initVelX = 0;
  float initVelY = 0;
  for (int i=0; i<balz.size(); i++) {
    if (balz.get(i).reached && balz.get(i).life==genQuickest) {
      if (firstSuccess==9999) {
        firstSuccess = generationCount;
      }
      topDNA = balz.get(i).DNA;
      initVelX = balz.get(i).initVel.x;
      initVelY = balz.get(i).initVel.y;
      break;
    }
  }
  if (topDNA.size()==0 && balz.size()!=0) {
    for (Ball bawl : balz) {
      if (bawl.cpPassed==genFurthestCP && bawl.distance==genClosest) {
        topDNA = bawl.DNA;
        initVelX = bawl.initVel.x;
        initVelY = bawl.initVel.y;
        break;
      }
    }
  } 
  for (int i=0; i<balz.size(); i++) {
    print(i+": ");
    for (int gene : balz.get(i).DNA) {
      print(gene);
    }
    println(' ');
  }

  balz.clear();

  for (int i=0; i<150; i++) {
    if (generationCount==0) {
      balz.add(new Ball());
    } else {
      balz.add(new Ball(initVelX, initVelY));
    }
    for (int gene : topDNA) {
      //if ((balz.get(i).DNA.size()>=topDNA.size()*0.80 && i>24)) { // || (balz.get(i).DNA.size()>=topDNA.size()*0.80 && i>23 && i<27)) {
      //  break;
      //}
      balz.get(i).DNA.add(gene);
    }
    balz.get(i).id = i;
  }

  topDNA.clear();
  updateTimer = 0;
  genQuickest = MAX_INT;
  genFurthestCP = 0;
  genClosest = MAX_INT;
  generationCount++;
  genRunning = true;
}

class Ball {
  PVector cen;
  PVector vel;
  PVector initVel;
  int rad = 15;
  ArrayList<Integer> DNA = new ArrayList<Integer>();
  boolean crashed = false;
  boolean reached = false;
  int cpPassed = 0;
  float distance;
  int life;
  int id;

  Ball() {
    this.cen = new PVector(checkpoints.get(0).x, checkpoints.get(0).y);
    this.vel = new PVector(random(-1, 1), random(-1, 1));
    this.vel.setMag(0.5);
    this.initVel = new PVector(this.vel.x, this.vel.y);
  }

  Ball(float xin, float yin) {
    this.cen = new PVector(checkpoints.get(0).x, checkpoints.get(0).y);
    this.vel = new PVector(xin, yin);
    this.initVel = new PVector(xin, yin);
  }

  void motion() {    
    if (crashed||reached) {
      return;
    }
    cen.x+=vel.x;
    cen.y+=vel.y;
    distance = dist(cen.x, cen.y, checkpoints.get(cpPassed).x, checkpoints.get(cpPassed).y);
    life = updateTimer;
    checkCollision();

    if (cpPassed<checkpoints.size()) {
      noStroke();
      fill(0, 250, 0);
      ellipse(checkpoints.get(cpPassed).x, checkpoints.get(cpPassed).y, 30, 30);
    }

    genRunning=true;
  }

  void checkCollision() {
    if (cen.x<0+rad || cen.x>width-rad || cen.y<0+rad || cen.y>height-rad || vel.mag()<0.49 || pixels[floor(cen.y)*width+floor(cen.x)]!=color(0)) {
      crashed = true;
      if (cpPassed>genFurthestCP) {
        genFurthestCP = cpPassed;
        genClosest = distance;
      } else if (cpPassed==genFurthestCP && distance<genClosest) {
        genClosest = distance;
      }
      cutDNA();
      return;
    }
    if (distance<rad+15) {
      cpPassed++;
    }
    if (distance<rad+15 && cpPassed==checkpoints.size()) {
      reached = true;
      if (life<genQuickest) {
        genQuickest = life;
      }
      if (life<totalQuickest) {
        totalQuickest = life;
      }
      cutDNA();
      return;
    }
  }

  void control(int gene) {
    int dir;
    if (gene>=DNA.size() || (random(1)>0.97 && id>0)) {
      dir = floor(random(6));
      switch (dir) {
      case 0: // substitution
      case 1:
      case 2:
      case 3:
        if (gene<DNA.size()) {
          DNA.remove(gene);
        }
        DNA.add(gene, dir);
        break;
      case 4: // insertion
        dir = floor(random(3));
        DNA.add(gene, dir);
        dir = DNA.get(gene);
        break;
      case 5: // deletion
        if (gene+1<DNA.size()) {
          DNA.remove(gene);
          dir = DNA.get(gene);
        } else {
          dir = floor(random(3));
          DNA.add(gene, dir);
        }
        break;
      }
    } else {
      dir = DNA.get(gene);
    }
    force(dir);
  }

  void force(int dir) {
    if (dir==0) { // accel
      PVector accel = new PVector(vel.x, vel.y);
      accel.setMag(0.5);
      vel.add(accel);
    } else if (dir==1) { // right
      vel.rotate(PI/8);
    } else if (dir==2) { // brake
      vel.mult(0.80);
    } else if (dir==3) { // left
      vel.rotate(-PI/8);
    }
  }

  void cutDNA() {
    while (updateTimer/10+1<DNA.size()) {
      this.DNA.remove(DNA.size()-1);
    }
  } 

  void display() {
    noStroke();
    fill(200, id/2, 75-id/2);
    ellipse(cen.x, cen.y, rad*2, rad*2);
  }
}

void mousePressed() {
  if (displayMenu) {
    displayMenu = false;
    drawingTrack = true;
  }
}

void mouseReleased() {
  if (drawingTrack) {
    drawingTrack = false;
    PVector last = new PVector(mouseX, mouseY);
    checkpoints.add(last);
    resetGeneration();
  }
}