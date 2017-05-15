void setup() {
  size(1000, 650);
  loadPixels();
}

void draw() {
  background(200);
  updatePixels();
  if (mousePressed && mouseButton==RIGHT) {
    fill(0);
    noStroke();
    ellipse(mouseX, mouseY, 50, 50);
    loadPixels();
  }
  if (mousePressed && mouseButton==LEFT) {
    if (pixels[width*mouseY+mouseX] == color(0)) {
      println("BEEP!");
    } else {
      println("BOOP");
    }
  }
  menuScreen();
}

void menuScreen() {
  textAlign(CENTER, CENTER);
  fill(0);
  textSize(100);
  text("RACE SUPERIOR COMPUTER!", width/2, height/2);
}
