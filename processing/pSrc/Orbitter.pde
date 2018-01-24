float gravity = 1;
ArrayList<Dot> doots;
int popSize = 1000;
PVector planetPos;
int planetRad = 60;

boolean watchGen;
boolean genRunning;
boolean genTesting;
int genCount;
int genOldest;
float genOptimal;
float speciesMaxWeight;
int updateTimer;

float randFuelProb;
float mutationProb;
float crossoverProb;
int maxFuel;
int crossCount = 0;

void setup() {
  size(600, 600);
  resetup();
}

void resetup() {  
  maxFuel = 150;  
  randFuelProb = 0.5;
  mutationProb = 0.04;
  crossoverProb = 0.04;
  planetPos = new PVector(width/2, height/2);
  
  updateTimer = 0;
  genCount = 0;
  speciesMaxWeight = 0;
  genOptimal= -1;
  
  if (doots!=null) {
    doots.clear();
  }
  doots = new ArrayList<Dot>();
  for (int i=0; i<popSize; i++) {
    doots.add(new Dot(i));
  }
  
  asexualBreed();
  genRunning = true;
  genTesting = true;
  
  watchGen = false;
}

void draw() {
  pushMatrix();
  scale(0.5, 0.5);
  translate(width/2, height/2);
  if (!mousePressed) {
    background(200);
  }
  
  fill(100, 100, 255);
  ellipse(planetPos.x, planetPos.y, planetRad*2, planetRad*2);
  
  if (genRunning && (updateTimer<=maxFuel+11 || genTesting || watchGen)) {
    runGeneration();
  } else {
    resetGeneration();
  }
  popMatrix();
  
  noFill();
  ellipse(width/2, height/2, width, height);
  
  fill(0);
  textAlign(RIGHT, BOTTOM);
  textSize(20);
  text("Generation: "+Integer.toString(genCount), width-5, height-5);
  textAlign(LEFT, BOTTOM);
  textSize(14);
  text("LifeTimer: "+Integer.toString(updateTimer), 5, height-30);
  text("Highest weight: "+Float.toString(speciesMaxWeight), 5, height-5);
  
  textAlign(LEFT, TOP);
  textSize(10);
  text("Mutation prblty: "+str(mutationProb), 5, 5);
  text("Crossover prblty: "+str(crossoverProb), 5, 16);
  text("Random fuel prblty: "+str(randFuelProb), 5, 27);
  text("Max fuel: "+str(maxFuel), 5, 38);
  textAlign(RIGHT, TOP);
  text("Run gen for 30 secs: "+str(watchGen), width-5, 5);
}

void runGeneration() {
  genRunning = false;
  genTesting = false;
  for (Dot dot : doots) {
    if (!dot.dead) {
      if (dot.fuel>0) {
        dot.control(updateTimer);
      }
      dot.move();
      dot.display();
      
      if (updateTimer>maxFuel+10 && !dot.testComplete) {
        dot.testOrbit();
      } else if (updateTimer == maxFuel+10) {
        dot.beginOrbit = new PVector(dot.pos.x-planetPos.x, dot.pos.y-planetPos.y).normalize();
        dot.beginDist = dist(dot.pos.x, dot.pos.y, planetPos.x, planetPos.y);
        dot.maxDist = dot.beginDist;
        dot.minDist = dot.beginDist;
      }
    }
  }
  
  updateTimer++;
}

void resetGeneration() {
  //asexualBreed();
  Breed();
  
  updateTimer = 0;
  genOldest = 0;
  genOptimal = -1;
  genCount++;
  genRunning = true;
  crossCount = 0;
}

ArrayList<Integer> getTopDNA() {
  ArrayList<Integer> topDNA = new ArrayList<Integer>();
  for (int i=0; i<doots.size(); i++) {
    if ((doots.get(i).life==genOldest && doots.get(i).dead) || (doots.get(i).weight==genOptimal)) {
      print(str(genCount)+": ");
      for (int gene : doots.get(i).DNA) {
        topDNA.add(gene);
        print(gene);
        if (topDNA.size()>=doots.get(i).life) {
          break;
        }
      }
      println(" ");
      
      if (doots.get(i).testComplete) {
        print(str(genCount)+": ");
        print("Distance to planet: mean: "+str(doots.get(i).avgDist));
        print(", range: "+str(doots.get(i).orbDist.get(doots.get(i).orbDist.size()-1) - doots.get(i).orbDist.get(0)));
        println(", weight: "+str(doots.get(i).weight));
      }
      
      if (doots.get(i).weight>speciesMaxWeight) {
        speciesMaxWeight = doots.get(i).weight;
      }
      
      doots.remove(i);
  
      break;
    }
  }
    
  return topDNA;
}
  

void asexualBreed() {
  ArrayList<Integer> topDNA = getTopDNA();
    
  doots.clear();

  for (int i=0; i<popSize; i++) {
    doots.add(new Dot(i));
    for (int gene : topDNA) {
      doots.get(i).DNA.add(gene);
    }
  }
  topDNA.clear();
}

void Breed() {
  ArrayList< ArrayList<Integer> > parentDNA = new ArrayList< ArrayList<Integer> >();
  int iter = 0;
  
  parentDNA.add(getTopDNA());
  
  while (parentDNA.size()<5 && iter<doots.size()) {
    if (!doots.get(iter).dead && !(parentDNA.get(0).equals(doots.get(iter).DNA))) {
      ArrayList<Integer> DNA = new ArrayList<Integer>();
      for (int gene : doots.get(iter).DNA) {
        DNA.add(gene);
      }
      parentDNA.add(DNA);
    }
    iter++;
  }
  
  doots.clear();
  
  if (parentDNA.size()==1) {
    for (int i=0; i<popSize; i++) {
      doots.add(new Dot(i));
      for (int gene : parentDNA.get(0)) {
        doots.get(i).DNA.add(gene);
      }
      doots.get(i).setFuel();
    }
    parentDNA.get(0).clear();
  } else {
    for (int i=0; i<popSize; i++) {
      doots.add(new Dot(i));
    }
    for (int i=0; i<popSize; i++) {
      if (i==0) {
        for (int gene : parentDNA.get(0)) {
          doots.get(0).DNA.add(gene);
        }
      } else {
        for (int gene : Crossover(parentDNA.get(0), parentDNA.get(i%(parentDNA.size()-1)+1))) {
          doots.get(i).DNA.add(gene);
        }
      }
      doots.get(i).setFuel();
    }
  }
  parentDNA.clear();
}

ArrayList<Integer> Crossover(ArrayList<Integer> dad, ArrayList<Integer> mom) {
  ArrayList<Integer> childDNA = new ArrayList<Integer>();
  boolean cross = false;
  int iter = 0;
  
  while (iter<max(dad.size(), mom.size())) {
    if (iter>=dad.size()) {
      cross = true;
    } else if (iter>=mom.size()) {
      cross = false;
    }
    
    if (!cross) {
      childDNA.add(dad.get(iter));
    } else {
      childDNA.add(mom.get(iter));
    }
    
    iter++;
    if (random(1)<crossoverProb) {
      cross = !cross;
      crossCount++;
    }
  }
  return childDNA;
}
  
class Dot {
  int id;
  int rad = 5;
  PVector pos;
  PVector vel;
  boolean dead;
  int life;
  int fuel;
  ArrayList<Integer> DNA = new ArrayList<Integer>();
  
  ArrayList<Float> orbDist = new ArrayList<Float>();
  PVector beginOrbit;
  float beginDist;
  float avgDist;
  float minDist;
  float maxDist;
  float weight;
  boolean halfOrbit = false;
  boolean testComplete = false;
  
  Dot(int id) {
    this.id = id;
    this.pos = new PVector(random(-10,10), random(-10,10));
    this.vel = new PVector(this.pos.x, this.pos.y).setMag(0.001);
    this.pos.setMag(this.rad+planetRad);
    this.pos.add(width/2, height/2);
    this.dead = false;
    this.life = 0;
    this.avgDist = 0;
  }
  
  void setFuel() {
    if (random(1)<randFuelProb && this.id!=0) {
      this.fuel = int(random(15, maxFuel));
    } else {
      this.fuel = this.DNA.size();
    }
  }
  
  void move() {    
    PVector toPlanet = new PVector(planetPos.x-this.pos.x, planetPos.y-this.pos.y);
    toPlanet.normalize();
    this.vel.add(toPlanet.mult(gravAltitude(PVector.dist(this.pos, planetPos))));
    this.pos.add(this.vel);
    
    this.fuel--;
    if (this.fuel==0) {
      cutDNA();
    }
    this.life++;
    genOldest = this.life;

    genRunning=true;
    
    collisionTest();
    
  }
  
  void collisionTest() {
    if (updateTimer>0 && (PVector.dist(this.pos, planetPos)<=this.rad+planetRad || 
    dist(this.pos.x, this.pos.y, width/2, height/2)>width)) {
      this.dead = true;
      cutDNA();
    }
  }

  void control(int gene) {
    int engines;
    if (gene<this.DNA.size() && (random(1)>mutationProb || this.id==0)) {
    //if (gene<this.DNA.size()) {
      engines = this.DNA.get(gene);
    } else {
      engines = floor(random(6));
      switch (engines) {
      case 0: // substitution
      case 1:
      case 2:
      case 3:
        if (gene<this.DNA.size()) {
          this.DNA.remove(gene);
        }
        this.DNA.add(gene, engines);
        break;
      case 4: // insertion
        engines = floor(random(3));
        this.DNA.add(gene, engines);
        this.DNA.add(gene, engines);
        this.DNA.add(gene, engines);
        engines = this.DNA.get(gene);
        break;
      case 5: // deletion
        if (gene+3<this.DNA.size()) {
          this.DNA.remove(gene);
          this.DNA.remove(gene);
          this.DNA.remove(gene);
          engines = this.DNA.get(gene);
        } else {
          engines = floor(random(3));
          this.DNA.add(gene, engines);
        }
        break;
      }
    }
    force(engines);
  }

  void force(int engines) {
    float boost = 1;
    if (engines==1) { // left
      this.vel.add(new PVector(this.vel.y, -this.vel.x).setMag(boost));
    } else if (engines==2) { // up
      this.vel.add(new PVector(this.vel.x, this.vel.y).setMag(boost));
    } else if (engines==3) { // right
      this.vel.add(new PVector(-this.vel.y, this.vel.x).setMag(boost));
    }       
  }
  
  void testOrbit() {
    PVector currentOrbit = new PVector(this.pos.x-planetPos.x, this.pos.y-planetPos.y).normalize();
    
    float distToPlanet = dist(this.pos.x, this.pos.y, planetPos.x, planetPos.y);
    orbDist.add(distToPlanet);
    this.avgDist+=distToPlanet;
    
    if (distToPlanet>maxDist) {
      maxDist = distToPlanet;
    } else if (distToPlanet<minDist) {
      minDist = distToPlanet;
    }
    
    if (PVector.angleBetween(this.beginOrbit, currentOrbit) > 2) {
      this.halfOrbit = true;
    } else if (this.halfOrbit && beginDist-distToPlanet<5) {
      this.avgDist /= this.orbDist.size();
      
      float range = maxDist - minDist;
      weight = 0.5*avgDist + 0.5*(470.0-range);
      
      this.testComplete = true;
      if (this.weight>genOptimal) {
        genOptimal = this.weight;
      }
    }
    
    genTesting = true;
  }

  void cutDNA() {
    if (updateTimer+1<DNA.size()) {
      this.DNA.subList(updateTimer+1, this.DNA.size()).clear();
    }
  } 
  
  void display() {
    fill(255, 255-this.id/4, this.id/4);
    ellipse(this.pos.x, this.pos.y, this.rad*2, this.rad*2);
    if (this.dead) {
      fill(255);
      ellipse(this.pos.x, this.pos.y, this.rad*4, this.rad*4);
    }
  }
}

float gravAltitude(float dist) {
  return (gravity*sq(planetRad/(planetRad+dist)));
}

void keyPressed() {
  if (key=='r') {
    resetup();
  } else if (key=='w') {
    watchGen = !watchGen;
  }
}