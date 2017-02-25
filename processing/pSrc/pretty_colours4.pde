int r=200;
int g=0;
int b=0;
int p=0;
float _p=0.0;
int maxDrops = 20;
int maxWakes = 300;
Drop[] drop = new Drop[maxDrops];
Wake[] wake = new Wake[maxWakes];
int dropNum = 0;
int wakeNum = 0;
int[] posPrev = new int[2];
int[] posCurr = new int[2];

void setup() {
  size(500,500);
  for (int i=0; i<maxDrops; i++) {
    drop[i] = new Drop();
  }
  for (int i=0; i<maxWakes; i++) {
    wake[i] = new Wake();
  }
  posPrev = new int[]{mouseX, mouseY};
  posCurr = new int[]{mouseX, mouseY};
}

class Drop {
  int xpos;
  int ypos;
  int ripple=0;
  int life;
  
  void display() {
    fill(b,r,g,life/9);
    stroke(0,0,0,100);
    strokeWeight(10);
    ellipse(xpos, ypos, ripple, ripple);
    ripple+=8;
    life-=8;
    if (ripple>1414) {
      ripple=0;
      life=0;
    }
  }
}

class Wake {
  PVector vector1;
  PVector vector2;
  PVector loc1;
  PVector loc2;
  boolean visible=false;
  int life = 0;
  
  Wake () {}
  
  Wake (int x, int y, PVector perp) {
    this.visible=true;
    this.loc1 = new PVector(x,y);
    this.loc2 = new PVector(x,y);
    this.vector1 = new PVector(perp.y, perp.x*-1);
    this.vector2 = new PVector(perp.y*-1, perp.x);
    vector1.setMag(perp.mag()/5);
    vector2.setMag(perp.mag()/5);
    this.life = int(perp.mag()*8);
  }
  
  void wakeOut() {
    loc1.add(vector1);
    loc2.add(vector2);
    if (life>0) { 
      life-=4;
    }
  }
  
  void display() {
    fill(0,0,0,life);
    noStroke();
    ellipse(loc1.x, loc1.y, 10, 10);
    ellipse(loc2.x, loc2.y, 10, 10);
  }
}

void draw() {
  if (p<=50) {
    r=200; g=0; b=200-p*4;
  } else if (p>50 && p<=100) {
    r=200; g=(p-50)*4; b=0;
  } else if (p>100 && p<=150) {
    r=200-(p-100)*4; g=200; b=0;
  } else if (p>150 && p<=200) {
    r=0; g=200; b=(p-150)*4;
  } else if (p>200 && p<=250) {
    r=0; g=200-(p-200)*4; b=200;
  } else if (p>250 && p<=300) {
    r=(p-250)*4; g=0; b=200;
  }
  p++;
  if (p>300) {
    p=0;
  }
  /*p=int(noise(_p)*300);
  _p+=0.004;*/
  //background(r, g, b, 100);
  fill(r, g, b, 50);
  rect(0, 0, width, height);
  
  for (Drop drip : drop) {
    if (drip.life > 0) {
      drip.display();      
    }
  }
  
  PVector vectorCurr = new PVector(posCurr[0]-posPrev[0], posCurr[1]-posPrev[1]);
  if (vectorCurr.mag() > 2 && mousePressed==true) {
    wake[wakeNum] = new Wake(mouseX, mouseY, vectorCurr);
  }
  for (Wake woke : wake) {
    if (woke.life > 0) {
      woke.display();
      woke.wakeOut();
    }
  }
  wakeNum++;
  if (wakeNum>=maxWakes) {
    wakeNum=0;
  }
  
  noStroke();
  fill(0);
  ellipse(mouseX, mouseY, 6, 6);
  
  posPrev = new int[]{posCurr[0], posCurr[1]};
  posCurr = new int[]{mouseX, mouseY};
}

void mouseReleased() {
  drop[dropNum].xpos=mouseX;
  drop[dropNum].ypos=mouseY;
  drop[dropNum].life=1414;
  dropNum++;
  if (dropNum>=maxDrops) {
    dropNum=0;
  }
}