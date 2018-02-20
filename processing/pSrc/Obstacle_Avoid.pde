ArrayList<Ball> balz = new ArrayList<Ball>();
ArrayList<Square> rex = new ArrayList<Square>();
int tempX;
int tempY;
boolean tempSquare = false;
PVector target;

boolean genRunning;
int genQuickest;
float genClosest;
int updateTimer = 0;
int generationCount = 0;
int totalQuickest = 9999;

void setup() {
  size(600, 600);
  target = new PVector(width/2, height-45);
  rectMode(CORNERS);
  resetGeneration();
}

void draw() {
  background(200);
  displayRex();
  displayTarget();
  fill(120, 180, 250);
  if (tempSquare) {
    rect(tempX, tempY, mouseX, mouseY);
  }

  if (genRunning && updateTimer<totalQuickest*2) {
    runGeneration();
  } else {
    resetGeneration();
  } //fix

  fill(0);
  textAlign(CENTER, CENTER);
  textSize(20);
  text("Generation: "+Integer.toString(generationCount), width-80, height-30);
  textSize(14);
  text("LifeTimer: "+Integer.toString(updateTimer), 60, height-35);
  text("Quickest: "+Integer.toString(totalQuickest), 60, height-15);
}

void displayRex() {
  for (Square rekt : rex) {
    rekt.display();
  }
}

void displayTarget() {
  fill(50, 50, 250);
  ellipse(target.x, target.y, 30, 30);
}

void runGeneration() {
  genRunning = false;
  for (Ball bawl : balz) {
    bawl.display();
    bawl.motion();
    if (updateTimer%10==0 && !(bawl.reached) && !(bawl.crashed)) {
      bawl.control(updateTimer/10);
    }
  }

  updateTimer++;
}

void resetGeneration() {
  ArrayList<Integer> topDNA = new ArrayList<Integer>();
  for (int i=0; i<balz.size(); i++) {
    if (balz.get(i).reached && balz.get(i).life==genQuickest) {
      for (int gene : balz.get(i).DNA) {
        topDNA.add(gene);
        if (topDNA.size()>=balz.get(i).life/10) {
          break;
        }
      }
      break;
    }
  }
  if (topDNA.size()==0 && balz.size()!=0) {
    for (Ball bawl : balz) {
      if (bawl.dist==genClosest) {
        topDNA = bawl.DNA;
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

  for (int i=0; i<30; i++) {
    balz.add(new Ball());
    if (i<25) {
      for (int gene : topDNA) {
        if (balz.get(i).DNA.size()>=topDNA.size()*0.90 && i>19) {
          break;
        }
        balz.get(i).DNA.add(gene);
      }
    }
    balz.get(i).id = i;
  }

  topDNA.clear();
  updateTimer = 0;
  genQuickest = MAX_INT;
  genClosest = MAX_INT;
  generationCount++;
  genRunning = true;
}

class Ball {
  PVector cen;
  PVector vel;
  int rad = 15;
  ArrayList<Integer> DNA = new ArrayList<Integer>();
  boolean crashed = false;
  boolean reached = false;
  float dist;
  int life;
  int id;

  Ball() {
    this.cen = new PVector(width/2, 45);
    this.vel = new PVector(0, 0.5);
  }

  Ball(ArrayList<Integer> DNA) {
    this.DNA = DNA;
  }

  void motion() {    
    if (crashed||reached) {
      return;
    }
    cen.x+=vel.x;
    cen.y+=vel.y;
    dist = dist(cen.x, cen.y, target.x, target.y);
    life = updateTimer;
    checkCollision();

    genRunning=true;
  }

  void checkCollision() {
    if (cen.x<0+rad || cen.x>width-rad || cen.y<0+rad || cen.y>height-rad || vel.mag()<0.01) {
      crashed = true;
      if (dist<genClosest) {
        genClosest = dist;
      }
      cutDNA();
      return;
    }
    for (Square scware : rex) { // bounce circle against squares
      if (this.cen.x+this.rad > scware.x1 && this.cen.x-this.rad < scware.x2 && this.cen.y+this.rad > scware.y1 && this.cen.y-this.rad < scware.y2) {
        crashed = true;
        if (dist<genClosest) {
          genClosest = dist;
        }
        cutDNA();
        return;
      }
    }
    if (dist<rad+15) {
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
    if (gene<DNA.size() && (random(1)<0.96 || id>18)) {
      dir = DNA.get(gene);
    } else {
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
        DNA.add(gene, dir);
        DNA.add(gene, dir);
        dir = DNA.get(gene);
        break;
      case 5: // deletion
        if (gene+3<DNA.size()) {
          DNA.remove(gene);
          DNA.remove(gene);
          DNA.remove(gene);
          dir = DNA.get(gene);
        } else {
          dir = floor(random(3));
          DNA.add(gene, dir);
        }
        break;
      }
    }
    force(dir);
  }

  void force(int dir) {
    float ogMag = vel.mag();
    if (dir==1) { // left
      PVector left = new PVector(vel.y, -vel.x);
      left.mult(0.5);
      vel.add(left);
      vel.setMag(ogMag);
    } else if (dir==2) { // brake
      vel.mult(0.60);
    } else if (dir==3) { // right
      PVector right = new PVector(-vel.y, vel.x);
      right.mult(0.5);
      vel.add(right);
      vel.setMag(ogMag);
    }       
    vel.add(new PVector(vel.x, vel.y).setMag(0.2));
  }

  void cutDNA() {
    while (updateTimer/10+1<DNA.size()) {
      this.DNA.remove(DNA.size()-1);
    }
  } 

  void display() {
    fill(200, 50, 50);
    ellipse(cen.x, cen.y, rad*2, rad*2);
  }
}

class Square { // Square class
  int x1; //left
  int y1; //top
  int x2; //right
  int y2; //down
  float wid;
  float hyt;

  Square(int xOne, int yOne, int xTwo, int yTwo) { // constructor
    this.x1 = min(xOne, xTwo);
    this.y1 = min(yOne, yTwo);
    this.x2 = max(xOne, xTwo);
    this.y2 = max(yOne, yTwo);
    this.wid = x2-x1;
    this.hyt = y2-y1;
  }

  void display() { // displays Square object as square with its colour
    fill(120, 180, 250);
    rect(x1, y1, x2, y2);
  }
}

void mousePressed() {
  tempX = mouseX;
  tempY = mouseY;
  tempSquare = true;
}

void mouseReleased() {
  rex.add(new Square(tempX, tempY, mouseX, mouseY));
  tempSquare = false;
  totalQuickest = 9999;
  generationCount=0;
  resetGeneration();
}