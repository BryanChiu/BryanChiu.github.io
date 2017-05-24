/* @pjs preload="one.jpg,two.jpg,steamer.png"; */

PImage org;
PImage vec;
PImage steam;

PGraphics painted;

int blackCount=0;

void setup() {
  size(800, 600);

  steam = loadImage("steamer.png");
  org = loadImage("one.jpg");
  vec = loadImage("two.jpg");
  painted = createGraphics(vec.width, vec.height);

  org.loadPixels();
  vec.loadPixels();

  imageMode(CENTER);
}

void draw() {
  background(200);
  image(org, width/2, height/2);
  if (mousePressed) {
    image(steam, mouseX+30, mouseY+70);
    painted.beginDraw();
    painted.fill(0);
    painted.ellipse(mouseX-vec.width/2, mouseY, 60, 60);
    painted.endDraw();
  }
}