PImage[] lvlImg;
PImage steam;
PGraphics painted;
int imgCount = 0;
int blackCount=0;

void setup() {
  size(900, 600);

  steam = loadImage("steamer.png");
  setFirst();
  painted = createGraphics(lvlImg[imgCount].width, lvlImg[imgCount].height);

  imageMode(CENTER);
}

void setFirst() {
  lvlImg = new PImage[]{loadImage("windowsX2.jpg"), loadImage("windowsX3.jpg"), loadImage("windowsX4.jpg"), loadImage("windowsX5.jpg"), loadImage("windowsX6.jpg")};

  for (PImage img : lvlImg) {
    img.loadPixels();
  }
}


void draw() {
  background(200);

  if (imgCount<lvlImg.length-1) {
    level();
  }
}

void level() {
  image(lvlImg[imgCount], 450, 300);
  if (mousePressed) {
    image(steam, mouseX+30, mouseY+70);
    painted.beginDraw();
    painted.fill(0);
    painted.ellipse(mouseX-450+lvlImg[imgCount].width/2, mouseY-300+lvlImg[imgCount].height/2, 60, 60);
    painted.endDraw();
    updateDisplayed();
  }
}

void updateDisplayed() {
  blackCount = 0;

  //lvlImg[imgCount].loadPixels();
  //lvlImg[imgCount+1].loadPixels();
  //painted.loadPixels();

  for (int i=0; i<painted.pixels.length; i++) {
    if (painted.pixels[i]==color(0)) {
      lvlImg[imgCount].set(i%painted.width, i/painted.width, lvlImg[imgCount+1].pixels[i]);
      blackCount++;
    }
  }

  //lvlImg[imgCount].loadPixels();
  //lvlImg[imgCount+1].loadPixels();
  //painted.loadPixels();

  if (blackCount>painted.pixels.length*0.95) {
    imgCount++;
    painted = createGraphics(lvlImg[imgCount].width, lvlImg[imgCount].height);
  }
}