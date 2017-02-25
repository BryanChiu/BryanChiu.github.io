ArrayList<Branch> tree = new ArrayList<Branch>();
float rotation;

void setup() {
  size(500,500);
}

void draw() {
  background(200,230,250);
  rotation=(mouseY*1.0)/(height*1.0)*PI;
  tree.add(new Branch(new PVector(0,1), 100, new PVector(250, 450)));
  for (Branch stick : tree) {
    stick.display();
  }
  tree.clear();
}

class Branch {
  PVector bLength = new PVector(0,1);
  float magn = 100;
  PVector base = new PVector(250,450);
  
  Branch(PVector bLength, float magn, PVector base) {
    this.magn = magn;
    this.bLength = bLength.setMag(magn);
    this.base = base;
    //if (magn>5) {
      //this.branchOff();
    //}
  }
  
  void display() {
    strokeWeight(magn/8);
    stroke(100-magn/2,magn,0);
    line(base.x, base.y, base.x+bLength.x, base.y-bLength.y);
  }
  
  
}
