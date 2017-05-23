/* @pjs preload="one.jpg,two.jpg,steamer.png"; */

PImage one;
PImage two;
PImage steam;

PGraphics painted;

int blackCount=0;

void setup() {
  size(800, 600, P2D);
  frameRate(30);

  one = loadImage("one.jpg");
  two = loadImage("two.jpg");
  steam = loadImage("steamer.png");

  painted = createGraphics(two.width, two.height, P2D);

  imageMode(CENTER);
  image(one, width/2, height/2);
}

void draw() {
  background(200);
  image(one, width/2, height/2);
  if (mousePressed) {
    image(steam, mouseX+30, mouseY+70);
    painted.beginDraw();
    painted.fill(0);
    painted.ellipse(mouseX-two.width/2, mouseY, 60, 60);
    painted.endDraw();
    updateDisplayed();
    image(painted, width/2, height/2);
  }
}

void updateDisplayed() {
  one.loadPixels();
  two.loadPixels();
  painted.loadPixels();

  blackCount=0;
  for (int i=0; i<painted.pixels.length; i++) {
    if (painted.pixels[i]==color(0)) {
      one.pixels[i] = two.pixels[i];
      blackCount++;
    }
  }
  if (blackCount>painted.pixels.length*0.98) {
    println("COMPLETED");
  }

  one.updatePixels();
  two.updatePixels();
  painted.updatePixels();
}
