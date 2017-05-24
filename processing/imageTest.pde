/* @pjs preload="one.jpg,two.jpg,steamer.png"; */

PImage one;
PImage two;
PImage steam;

PGraphics painted;

int blackCount=0;

void setup() {
  size(800, 600);

  steam = loadImage("steamer.png");
  one = loadImage("one.jpg");
  two = loadImage("two.jpg");
  painted = createGraphics(two.width, two.height);

  one.loadPixels();
  two.loadPixels();

  imageMode(CENTER);
}

void draw() {
  background(200);
  if (mousePressed) {
    image(steam, mouseX+30, mouseY+70);
    painted.beginDraw();
    painted.fill(0);
    painted.ellipse(mouseX-two.width/2, mouseY, 60, 60);
    painted.endDraw();
    updateDisplayed();
  }
  image(two, width/2, height/2);
}

void updateDisplayed() {
  blackCount = 0;
  
  one.loadPixels();
  two.loadPixels();
  painted.loadPixels();

  for (int i=0; i<painted.pixels.length; i++) {
    if (painted.pixels[i]==color(0)) {
      two.pixels[i] = one.pixels[i];
      blackCount++;
    }
  }
  
  one.updatePixels();
  two.updatePixels();
  painted.updatePixels();
  
  if (blackCount>painted.pixels.length*0.98) {
    println("COMPLETED");
  }
}