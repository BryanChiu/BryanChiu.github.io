/* @pjs preload="FirstScreen.jpg, MenuScreen.jpg, LastScreen.jpg, Toolbar.png, hand.png, rinse.png, rag.png, steamer.png, paint.png, brush.png, vacuum.png, clay.png, conditioner.png, cleaner.png, checkmark.png, mat.jpg, mat2.png, mat3.png, mat4.png, mat3.png, mat2.png, concrete.jpg, Doors1.jpg, Doors4.jpg, Doors6.jpg, Doors5.jpg, Doors7.jpg, Doors2.jpg, Doors3.jpg, Seats1.jpg, Seats3.jpg, Seats4.jpg, Seats5.jpg, Seats6.jpg, Seats7.jpg, Seats2.jpg, Seats8.jpg, Carpet1.jpg, Carpet3.jpg, Carpet4.jpg, Carpet5.jpg, Carpet6.jpg, Carpet7.jpg, Carpet2.jpg, Dash2.jpg, Dash3.jpg, Dash4.jpg, Dash1.jpg, Console2.jpg, Console3.jpg, Console4.jpg, Console1.jpg, VentsC2.jpg, VentsC3.jpg, VentsC1.jpg, VentsS2.jpg, VentsS3.jpg, VentsS4.jpg, VentsS1.jpg, windowsI2.jpg, windowsI3.jpg, windowsI4.jpg, windowsI1.jpg, windowsX2.jpg, windowsX3.jpg, windowsX4.jpg, windowsX5.jpg, windowsX6.jpg, windowsX1.jpg"; */

enum Screen { 
  FIRST, MENU, LEVEL, LAST
};
enum Equip { 
  NONE, RINSE, RAG, STEAM, PAINT, BRUSH, VAC, CLAY, CONDR, CLEAN
};
HashMap<Equip, String> tool2Task = new HashMap<Equip, String>();
Screen display;
Equip tool; 
PImage FirstScreen, MenuScreen, LastScreen, Toolbar;
PImage none, rinse, rag, steam, paint, brush, vac, clay, condr, clean;
PImage[][] lvlImgs;
Equip[][] lvlTools;
Float[] lvlTolerance;
PVector[] paintOffset;
PGraphics painted;
PImage checkmark;

int levelCount;
int taskCount;
int nextTask;
int buffer;
boolean countdownStarted;
boolean inPlay;

int blackCount;
int taskPercent;

void setup() {
  size(900, 600);
  imageMode(CENTER);
  display = Screen.FIRST;
  tool = Equip.NONE;
  levelCount = -1;
  taskCount = 0;
  nextTask = 0;
  countdownStarted = false;
  inPlay = false;

  assignTools2Task();
  loadAssets();
  loadLevels();
}

void draw() {
  background(200);
  switch (display) {
  case FIRST:
    displayFirst();
    break;
  case MENU:
    displayMenu();
    break;
  case LEVEL:
    playLevel();
    break;
  case LAST:
    displayLast();
    break;
  }
}

void playLevel() {
  displayLevel();
  displayTools();
  displayTasks();
}

void displayLevel() {
  displayBackground();
  if (buffer>0) {
    buffer--;
  } else if (taskCount!=lvlTools[levelCount].length) {
    if (countdownStarted) {
      nextTask--;
      if (nextTask<=0) {
        countdownStarted = false;
        painted = createGraphics(lvlImgs[levelCount][taskCount].width, lvlImgs[levelCount][taskCount].height);
        if (levelCount==2 && taskCount==1) { // some really nice hard-coding for vacuuming seats
          lvlImgs[2][9].loadPixels();
          painted.beginDraw();
          painted.endDraw();
          for (int i=0; i<lvlImgs[2][9].pixels.length; i++) {
            painted.set(i%painted.width, i/painted.width, lvlImgs[2][9].pixels[i]);
          }
          lvlImgs[2][9].updatePixels();
        }
        taskPercent = 0;
      }
    } else if (tool==Equip.NONE && lvlTools[levelCount][taskCount]==Equip.NONE && mousePressed && !(mouseY>height-72 && mouseX>104 && mouseX<width-104)) { // if hand is required equipment
      countdownStarted = true;
      nextTask = 70;
      taskCount++;
    } else if (lvlTools[levelCount][taskCount]!=Equip.NONE && tool==lvlTools[levelCount][taskCount] && mousePressed) {
      painted.beginDraw();
      painted.fill(0);
      painted.ellipse(mouseX-width/2-paintOffset[levelCount].x+lvlImgs[levelCount][taskCount].width/2, mouseY-height/2-paintOffset[levelCount].y+lvlImgs[levelCount][taskCount].height/2, 60, 60); // change to accomodate center
      painted.endDraw();
      updateDisplayed();
    }
  }
}

void updateDisplayed() {
  blackCount = 0;

  lvlImgs[levelCount][taskCount].loadPixels();
  lvlImgs[levelCount][taskCount+1].loadPixels();
  painted.loadPixels();

  for (int i=0; i<painted.pixels.length; i++) {
    if (painted.pixels[i]==color(0)) {
      lvlImgs[levelCount][taskCount].set(i%painted.width, i/painted.width, lvlImgs[levelCount][taskCount+1].pixels[i]);
      blackCount++;
    }
  }

  taskPercent = ceil(blackCount*100/(painted.pixels.length*lvlTolerance[levelCount]));
  if (levelCount==2 && taskCount==1) {
    taskPercent = ceil((blackCount-329063)*100/((painted.pixels.length-329063)*lvlTolerance[levelCount]));
  }

  lvlImgs[levelCount][taskCount].updatePixels();
  lvlImgs[levelCount][taskCount+1].updatePixels();

  if (taskPercent>99) {
    taskCount++;
    taskPercent = 0;
    painted = createGraphics(lvlImgs[levelCount][taskCount].width, lvlImgs[levelCount][taskCount].height);
  }
}

void displayBackground() {
  switch (levelCount) {
  case 0: 
    if (taskCount==0) {
      image(lvlImgs[0][0], width/2, height/2);
    } else if (taskCount==1 && countdownStarted) {
      image(lvlImgs[0][0], width/2, height/2);
      image(lvlImgs[0][1], width/2, height/2-25);
    } else {
      image(lvlImgs[0][6], width/2, height/2);
      image(lvlImgs[0][taskCount], width/2, height/2-25);
    }
    break;
  case 1:
    if (taskCount==0) {
      image(lvlImgs[1][0], width/2, height/2);
    } else if (taskCount==1 && countdownStarted) {
      image(lvlImgs[1][7], width/2, height/2);
    } else {
      image(lvlImgs[1][8], width/2, height/2);
      image(lvlImgs[1][taskCount], width/2+24, height/2+27);
    }
    break;
  case 2:
    if (taskCount==0) {
      image(lvlImgs[2][0], width/2, height/2);
    } else {
      image(lvlImgs[2][8], width/2, height/2);
      image(lvlImgs[2][taskCount], width/2-1, height/2-31);
    }
    break;
  case 3:
    if (taskCount==0) {
      image(lvlImgs[3][0], width/2, height/2);
    } else {
      image(lvlImgs[3][6], width/2, height/2);
      image(lvlImgs[3][taskCount], width/2-6, height/2+38);
    }
    break;
  case 4:
    image(lvlImgs[4][4], width/2, height/2);
    image(lvlImgs[4][taskCount], width/2+12, height/2+22);
    break;
  case 5:
    image(lvlImgs[5][4], width/2, height/2);
    image(lvlImgs[5][taskCount], width/2-20, height/2);
    break;
  case 6:
    image(lvlImgs[6][2], width/2, height/2);
    image(lvlImgs[6][taskCount], width/2+10, height/2+7);
    break;
  case 7:
    image(lvlImgs[7][4], width/2, height/2);
    image(lvlImgs[7][taskCount], width/2+17, height/2-8);
    break;
  case 8:
    image(lvlImgs[8][3], width/2, height/2);
    image(lvlImgs[8][taskCount], width/2+30, height/2+33);
    break;
  case 9:
    image(lvlImgs[9][5], width/2, height/2);
    image(lvlImgs[9][taskCount], width/2-35, height/2+12);
    break;
  }
}

void displayFirst() {
  image(FirstScreen, width/2, height/2);
  if (mousePressed) {
    display = Screen.MENU;
  }
}

void displayMenu() {
  image(MenuScreen, width/2, height/2);
  for (int i=0; i<levelCount+1; i++) {
    if (i<5) {
      image(checkmark, 335, i*61+153);
    } else if (i==7) {
      image(checkmark, 335, 5*61+153);
    }
  }
  if (mousePressed && mouseX>440 && mouseX<800 && mouseY>435 && mouseY<550) {
    display = Screen.LEVEL;
    levelCount++;
    taskCount = 0;
    buffer = 30;
    painted = createGraphics(lvlImgs[levelCount][taskCount].width, lvlImgs[levelCount][taskCount].height);
  }
}

void displayLast() {
  image(LastScreen, width/2, height/2);
  if (mousePressed && mouseX>440 && mouseX<800 && mouseY>435 && mouseY<550) {
    setup();
  }
}

void loadAssets() {
  FirstScreen = loadImage("FirstScreen.jpg");
  MenuScreen = loadImage("MenuScreen.jpg");
  LastScreen = loadImage("LastScreen.jpg");
  Toolbar = loadImage("Toolbar.png");
  none = loadImage("hand.png");
  rinse = loadImage("rinse.png");
  rag = loadImage("rag.png");
  steam = loadImage("steamer.png");
  paint = loadImage("paint.png");
  brush = loadImage("brush.png");
  vac = loadImage("vacuum.png");
  clay = loadImage("clay.png");
  condr = loadImage("conditioner.png");
  clean = loadImage("cleaner.png");
  checkmark = loadImage("checkmark.png");
}

void loadLevels() {
  lvlImgs = new PImage[10][];
  lvlImgs[0] = new PImage[]{loadImage("mat.jpg"), loadImage("mat2.png"), loadImage("mat3.png"), loadImage("mat4.png"), 
    loadImage("mat3.png"), loadImage("mat2.png"), loadImage("concrete.jpg")};
  lvlImgs[1] = new PImage[]{loadImage("Doors1.jpg"), loadImage("Doors4.jpg"), loadImage("Doors6.jpg"), loadImage("Doors5.jpg"), 
    loadImage("Doors6.jpg"), loadImage("Doors4.jpg"), loadImage("Doors7.jpg"), loadImage("Doors2.jpg"), loadImage("Doors3.jpg")};
  lvlImgs[2] = new PImage[]{loadImage("Seats1.jpg"), loadImage("Seats3.jpg"), loadImage("Seats4.jpg"), loadImage("Seats5.jpg"), 
    loadImage("Seats6.jpg"), loadImage("Seats5.jpg"), loadImage("Seats4.jpg"), loadImage("Seats7.jpg"), loadImage("Seats2.jpg"), loadImage("Seats8.jpg")}; 
  lvlImgs[3] = new PImage[]{loadImage("Carpet1.jpg"), loadImage("Carpet3.jpg"), loadImage("Carpet4.jpg"), 
    loadImage("Carpet5.jpg"), loadImage("Carpet6.jpg"), loadImage("Carpet7.jpg"), loadImage("Carpet2.jpg")}; 
  lvlImgs[4] = new PImage[]{loadImage("Dash2.jpg"), loadImage("Dash3.jpg"), loadImage("Dash2.jpg"), loadImage("Dash4.jpg"), loadImage("Dash1.jpg")};
  lvlImgs[5] = new PImage[]{loadImage("Console2.jpg"), loadImage("Console3.jpg"), loadImage("Console2.jpg"), loadImage("Console4.jpg"), loadImage("Console1.jpg")};
  lvlImgs[6] = new PImage[]{loadImage("VentsC2.jpg"), loadImage("VentsC3.jpg"), loadImage("VentsC1.jpg")};
  lvlImgs[7] = new PImage[]{loadImage("VentsS2.jpg"), loadImage("VentsS3.jpg"), loadImage("VentsS4.jpg"), loadImage("VentsS3.jpg"), loadImage("VentsS1.jpg")};
  lvlImgs[8] = new PImage[]{loadImage("windowsI2.jpg"), loadImage("windowsI3.jpg"), loadImage("windowsI4.jpg"), loadImage("windowsI1.jpg")};
  lvlImgs[9] = new PImage[]{loadImage("windowsX2.jpg"), loadImage("windowsX3.jpg"), loadImage("windowsX4.jpg"), loadImage("windowsX5.jpg"), 
    loadImage("windowsX6.jpg"), loadImage("windowsX1.jpg")};
  lvlTools = new Equip[10][];
  lvlTools[0] = new Equip[]{Equip.NONE, Equip.RINSE, Equip.PAINT, Equip.STEAM, Equip.RAG}; //mats
  lvlTools[1] = new Equip[]{Equip.NONE, Equip.RINSE, Equip.PAINT, Equip.STEAM, Equip.RAG, Equip.CONDR}; //doors
  lvlTools[2] = new Equip[]{Equip.NONE, Equip.VAC, Equip.CLEAN, Equip.PAINT, Equip.STEAM, Equip.RAG, Equip.CONDR}; //seats
  lvlTools[3] = new Equip[]{Equip.NONE, Equip.VAC, Equip.CLEAN, Equip.STEAM, Equip.BRUSH}; //carpet
  lvlTools[4] = new Equip[]{Equip.STEAM, Equip.RAG, Equip.CONDR}; //dash
  lvlTools[5] = new Equip[]{Equip.STEAM, Equip.RAG, Equip.CONDR}; //console
  lvlTools[6] = new Equip[]{Equip.PAINT}; //central vents
  lvlTools[7] = new Equip[]{Equip.PAINT, Equip.STEAM, Equip.RAG}; //lateral vents
  lvlTools[8] = new Equip[]{Equip.STEAM, Equip.RAG}; //windows
  lvlTools[9] = new Equip[]{Equip.RINSE, Equip.CLAY, Equip.RINSE, Equip.RAG}; //windows
  lvlTolerance = new Float[]{.91, .88, .84, .92, .86, .95, .97, .76, .84, .84};
  paintOffset = new PVector[]{new PVector(0, -25), new PVector(24, 27), new PVector(-1, -31), new PVector(-6, 38), 
    new PVector(12, 22), new PVector(-20, 0), new PVector(10, 7), new PVector(17, -8), new PVector(30, 33), new PVector(-35, 12)};
}

void assignTools2Task() {
  tool2Task.put(Equip.RINSE, "Spray rinse");
  tool2Task.put(Equip.RAG, "Wipe dry");
  tool2Task.put(Equip.STEAM, "Steam blow");
  tool2Task.put(Equip.PAINT, "Paint brush");
  tool2Task.put(Equip.BRUSH, "Utility brush");
  tool2Task.put(Equip.VAC, "Vacuum");
  tool2Task.put(Equip.CLAY, "Apply clay");
  tool2Task.put(Equip.CONDR, "Apply conditioner");
  tool2Task.put(Equip.CLEAN, "Apply cleaner");
}

void displayTasks() {
  textAlign(RIGHT, TOP);
  textSize(18);
  rectMode(CORNERS);
  noStroke();
  fill(0, 0, 0, 180);
  rect(width, 35, width-215, lvlTools[levelCount].length*30+40);
  for (int i=0; i<lvlTools[levelCount].length; i++) {
    fill(255);
    if (lvlTools[levelCount][i]==Equip.NONE) {
      switch (levelCount) {
      case 0:
        text("Remove mats", width-40, i*30+39);
        break;
      case 1:
        text("Open doors", width-40, i*30+39);
        break;
      case 2:
        text("Recline seats", width-40, i*30+39);
        break;
      case 3:
        text("Fold down seats", width-40, i*30+39);
        break;
      }
    } else {
      text(tool2Task.get(lvlTools[levelCount][i]), width-40, i*30+39);
    }

    // show completion status with circle beside task
    if (i==taskCount) {
      fill(230, 230, 0);
    } else if (i<taskCount) {
      fill(0, 230, 0);
    } else {
      fill(230, 0, 0);
    }
    stroke(255);
    strokeWeight(2);
    ellipse(width-20, i*30+50, 22, 22);
  }

  // show completion percentage inside circle
  textAlign(CENTER, CENTER);
  textSize(9);
  fill(0);
  text(Integer.toString(taskPercent)+"%", width-20, taskCount*30+50);

  // what happens after level completed
  if (taskCount==lvlTools[levelCount].length) {
    fill(50);
    stroke(0);
    strokeWeight(6);
    rect(width-3, taskCount*30+50, width-140, taskCount*30+110, 10, 10, 10, 10);
    textSize(40);
    fill(255);
    text("NEXT", width-70, taskCount*30+75);
    if (mousePressed && mouseX>width-140 && mouseX<width && mouseY>taskCount*30+50 && mouseY<taskCount*30+110) {
      if (levelCount==4 || levelCount==6 || levelCount==8) {
        levelCount++;
        taskCount = 0;
        taskPercent = 0;
        painted = createGraphics(lvlImgs[levelCount][taskCount].width, lvlImgs[levelCount][taskCount].height);
      } else if (levelCount==9) {
        display = Screen.LAST;
      } else {
        display = Screen.MENU;
      }
    }
  }
}

void mousePressed() {
  if (!(mouseY>height-72 && mouseX>104 && mouseX<width-104)) {
    inPlay = true;
  }
}

void mouseReleased() {
  if (inPlay) {
    inPlay = false;
  }
}

void displayTools() {
  image(Toolbar, width/2, height-36);
  if (mouseY>height-72 && mouseX>104 && mouseX<width-104 && !(inPlay)) {
    textAlign(BOTTOM);
    textSize(20);
    rectMode(CORNERS);
    noStroke();
    fill(0,0,0,180);
    if (mouseX>104 && mouseX<173) {
      rect(mouseX, mouseY, mouseX+69, mouseY-25, 4, 4, 4, 4);
      fill(255);
      text("HAND", mouseX+5, mouseY-5);
      if (mousePressed) {
        tool = Equip.NONE;
      }
    } else if (mouseX>173 && mouseX<242) {
      rect(mouseX, mouseY, mouseX+70, mouseY-25, 4, 4, 4, 4);
      fill(255);
      text("SPRAY", mouseX+5, mouseY-5);
      if (mousePressed) {
        tool = Equip.RINSE;
      }
    } else if (mouseX>242 && mouseX<311) {
      rect(mouseX, mouseY, mouseX+78, mouseY-25, 4, 4, 4, 4);
      fill(255);
      text("TOWEL", mouseX+5, mouseY-5);
      if (mousePressed) {
        tool = Equip.RAG;
      }
    } else if (mouseX>311 && mouseX<380) {
      rect(mouseX, mouseY, mouseX+100, mouseY-25, 4, 4, 4, 4);
      fill(255);
      text("STEAMER", mouseX+5, mouseY-5);
      if (mousePressed) {
        tool = Equip.STEAM;
      }
    } else if (mouseX>380 && mouseX<449) {
      rect(mouseX, mouseY, mouseX+138, mouseY-25, 4, 4, 4, 4);
      fill(255);
      text("PAINT BRUSH", mouseX+5, mouseY-5);
      if (mousePressed) {
        tool = Equip.PAINT;
      }
    } else if (mouseX>449 && mouseX<518) {
      rect(mouseX, mouseY, mouseX+74, mouseY-25, 4, 4, 4, 4);
      fill(255);
      text("BRUSH", mouseX+5, mouseY-5);
      if (mousePressed) {
        tool = Equip.BRUSH;
      }
    } else if (mouseX>518 && mouseX<587) {
      rect(mouseX, mouseY, mouseX+96, mouseY-25, 4, 4, 4, 4);
      fill(255);
      text("VACUUM", mouseX+5, mouseY-5);
      if (mousePressed) {
        tool = Equip.VAC;
      }
    } else if (mouseX>587 && mouseX<656) {
      rect(mouseX, mouseY, mouseX+62, mouseY-25, 4, 4, 4, 4);
      fill(255);
      text("CLAY", mouseX+5, mouseY-5);
      if (mousePressed) {
        tool = Equip.CLAY;
      }
    } else if (mouseX>656 && mouseX<725) {
      rect(mouseX, mouseY, mouseX+148, mouseY-25, 4, 4, 4, 4);
      fill(255);
      text("CONDITIONER", mouseX+5, mouseY-5);
      if (mousePressed) {
        tool = Equip.CONDR;
      }
    } else {
      rect(mouseX, mouseY, mouseX+98, mouseY-25, 4, 4, 4, 4);
      fill(255);
      text("CLEANER", mouseX+5, mouseY-5);
      if (mousePressed) {
        tool = Equip.CLEAN;
      }
    }
  } else {
    switch (tool) {
    case NONE:
      image(none, mouseX+10, mouseY);
      break;
    case RINSE:
      image(rinse, mouseX+10, mouseY+40);
      break;
    case RAG:
      image(rag, mouseX-10, mouseY+30);
      break;
    case STEAM:
      image(steam, mouseX+30, mouseY+70);
      break;
    case PAINT:
      image(paint, mouseX+35, mouseY+35);
      break;
    case BRUSH:
      image(brush, mouseX+20, mouseY+10);
      break;
    case VAC:
      image(vac, mouseX+20, mouseY+40);
      break;
    case CLAY:
      image(clay, mouseX, mouseY);
      break;
    case CONDR:
      image(condr, mouseX-10, mouseY+40);
      break;
    case CLEAN:
      image(clean, mouseX-10, mouseY+40);
      break;
    }
  }
}