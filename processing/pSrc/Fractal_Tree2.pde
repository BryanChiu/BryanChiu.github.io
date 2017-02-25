float rotation;

void setup() {
  size(500, 500);
}

void draw() {
  background(200, 230, 250);
  rotation=(mouseY*1.0)/(height*1.0)*PI;
  branchOffRec(new PVector(0, 1), 100, new PVector(250, 450));
}

void branchOffRec(PVector bLength, float magn, PVector base) {
  bLength.setMag(magn);
  strokeWeight(magn/8);
  stroke(100-magn/2, magn, 0);
  line(base.x, base.y, base.x+bLength.x, base.y-bLength.y);

  if (magn>5) {
    PVector childBranch = new PVector(bLength.x, bLength.y);
    childBranch.rotate(rotation);
    branchOffRec(childBranch, magn*0.75, new PVector(base.x+bLength.x, base.y-bLength.y));
    childBranch = new PVector(bLength.x, bLength.y);
    childBranch.rotate(rotation*-1);
    branchOffRec(childBranch, magn*0.75, new PVector(base.x+bLength.x, base.y-bLength.y));
  }
}