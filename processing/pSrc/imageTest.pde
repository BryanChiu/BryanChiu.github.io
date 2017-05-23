/* @pjs preload="data/one.jpg"; */
/* @pjs preload="data/two.jpg"; */
/* @pjs preload="data/steamer.png"; */

PImage one;
PImage two;
PImage steam;

PGraphics painted;

void setup() {
  size(800, 600);
  frameRate(120);

  one = loadImage("data/one.jpg");
  two = loadImage("data/two.jpg");
  steam = loadImage("data/steamer.png");

  painted = createGraphics(two.width, two.height);  

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
  }
}

void updateDisplayed() {
  int blackCount=0;
  for (int i=0; i<painted.pixels.length; i++) {
    if (painted.pixels[i]==color(0)) {
      one.set(i%one.width, i/one.width, two.pixels[i]);
      blackCount++;
    }
  }
  if (blackCount>painted.pixels.length*0.98) {
    println("COMPLETED");
  }
}