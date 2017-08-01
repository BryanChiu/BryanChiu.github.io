var tool2Task = {};
var display;
var tool; 
var FirstScreen, MenuScreen, LastScreen, Toolbar;
var none, rinse, rag, steam, paint, brush, vac, clay, condr, clean;
var lvlImgs;
var lvlTools;
var lvlTolerance;
var paintOffset;
var painted;
var checkmark;

var levelCount;
var taskCount;
var nextTask;
var buffer;
var countdownStarted;
var inPlay;

var blackCount;
var taskPercent;

function preload() {
  loadAssets();
  loadLevels();
}

function setup() {
  var canvas = createCanvas(900, 600);
  //canvas.parent('sketch-holder');
  imageMode(CENTER);
  textFont("Trebuchet MS");
  display = "FIRST";
  tool = "NONE";
  levelCount = -1;
  taskCount = 0;
  taskPercent = 0;
  nextTask = 0;
  countdownStarted = false;
  inPlay = false;

  assignTools2Task();
}

function draw() {
  background(200);
  switch (display) {
  case "FIRST":
    displayFirst();
    break;
  case "MENU":
    displayMenu();
    break;
  case "LEVEL":
    playLevel();
    break;
  case "LAST":
    displayLast();
    break;
  }
}

function playLevel() {
  displayLevel();
  displayTools();
  displayTasks();
}

function displayLevel() {
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
          painted.loadPixels();
          for (var i=0; i<lvlImgs[2][9].pixels.length; i++) {
            painted.pixels[i] = lvlImgs[2][9].pixels[i];
          }
          painted.updatePixels();
          lvlImgs[2][9].updatePixels();
        }
        taskPercent = 0;
      }
    } else if (tool=="NONE" && lvlTools[levelCount][taskCount]=="NONE" && mouseIsPressed && !(mouseY>height-72 && mouseX>104 && mouseX<width-104)) { // if hand is required equipment
      countdownStarted = true;
      nextTask = 70;
      taskCount++;
    } else if (lvlTools[levelCount][taskCount]!="NONE" && tool==lvlTools[levelCount][taskCount] && mouseIsPressed) {
      painted.fill(0);
      painted.ellipse(mouseX-width/2-paintOffset[levelCount].x+lvlImgs[levelCount][taskCount].width/2, mouseY-height/2-paintOffset[levelCount].y+lvlImgs[levelCount][taskCount].height/2, 60, 60); // change to accomodate center
      updateDisplayed();
    }
  }
}

function updateDisplayed() {
  blackCount = 0;

  lvlImgs[levelCount][taskCount].loadPixels();
  lvlImgs[levelCount][taskCount+1].loadPixels();
  painted.loadPixels();

  for (var i=0; i<painted.pixels.length; i+=4) {
    if (painted.pixels[i+3]>180) {
      lvlImgs[levelCount][taskCount].pixels[i] = lvlImgs[levelCount][taskCount+1].pixels[i];
      lvlImgs[levelCount][taskCount].pixels[i+1] = lvlImgs[levelCount][taskCount+1].pixels[i+1];
      lvlImgs[levelCount][taskCount].pixels[i+2] = lvlImgs[levelCount][taskCount+1].pixels[i+2];
      lvlImgs[levelCount][taskCount].pixels[i+3] = lvlImgs[levelCount][taskCount+1].pixels[i+3];
      blackCount+=4;
    }
  }

  lvlImgs[levelCount][taskCount].updatePixels();
  lvlImgs[levelCount][taskCount+1].updatePixels();
  painted.updatePixels();

  taskPercent = ceil(blackCount*100/(painted.pixels.length*lvlTolerance[levelCount]));
  if (levelCount==2 && taskCount==1) { // some more really nice hard-coding for vacuuming seats
    taskPercent = ceil((blackCount/4-331757)*100/((painted.pixels.length/4-331757)*lvlTolerance[levelCount]));
  }

  if (taskPercent>99) {
    taskCount++;
    taskPercent = 0;
    painted = createGraphics(lvlImgs[levelCount][taskCount].width, lvlImgs[levelCount][taskCount].height);
  }
}

function displayBackground() {
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

function displayFirst() {
  image(FirstScreen, width/2, height/2);
  if (mouseIsPressed) {
    display = "MENU";
  }
}

function displayMenu() {
  image(MenuScreen, width/2, height/2);
  for (var i=0; i<levelCount+1; i++) {
    if (i<5) {
      image(checkmark, 335, i*61+153);
    } else if (i==7) {
      image(checkmark, 335, 5*61+153);
    }
  }
  if (mouseIsPressed && mouseX>440 && mouseX<800 && mouseY>435 && mouseY<550) {
    display = "LEVEL";
    levelCount++;
    taskCount = 0;
    buffer = 30;
    painted = createGraphics(lvlImgs[levelCount][taskCount].width, lvlImgs[levelCount][taskCount].height);
  }
}

function displayLast() {
  image(LastScreen, width/2, height/2);
  if (mouseIsPressed && mouseX>440 && mouseX<800 && mouseY>435 && mouseY<550) {
    setup();
  }
}

function loadAssets() {
  FirstScreen = loadImage("assets/FirstScreen.jpg");
  MenuScreen = loadImage("assets/MenuScreen.jpg");
  LastScreen = loadImage("assets/LastScreen.jpg");
  Toolbar = loadImage("assets/Toolbar.png");
  none = loadImage("assets/hand.png");
  rinse = loadImage("assets/rinse.png");
  rag = loadImage("assets/rag.png");
  steam = loadImage("assets/steamer.png");
  paint = loadImage("assets/paint.png");
  brush = loadImage("assets/brush.png");
  vac = loadImage("assets/vacuum.png");
  clay = loadImage("assets/clay.png");
  condr = loadImage("assets/conditioner.png");
  clean = loadImage("assets/cleaner.png");
  checkmark = loadImage("assets/checkmark.png");
}

function loadLevels() {
  lvlImgs = [
    [loadImage("assets/mat1.jpg"), loadImage("assets/mat2.png"), loadImage("assets/mat3.png"), loadImage("assets/mat4.png"), 
    loadImage("assets/mat3.png"), loadImage("assets/mat2.png"), loadImage("assets/concrete.jpg")], 
    [loadImage("assets/Doors1.jpg"), loadImage("assets/Doors4.jpg"), loadImage("assets/Doors6.jpg"), loadImage("assets/Doors5.jpg"), 
    loadImage("assets/Doors6.jpg"), loadImage("assets/Doors4.jpg"), loadImage("assets/Doors7.jpg"), loadImage("assets/Doors2.jpg"), loadImage("assets/Doors3.jpg")], 
    [loadImage("assets/Seats1.jpg"), loadImage("assets/Seats3.jpg"), loadImage("assets/Seats4.jpg"), loadImage("assets/Seats5.jpg"), 
    loadImage("assets/Seats6.jpg"), loadImage("assets/Seats5.jpg"), loadImage("assets/Seats4.jpg"), loadImage("assets/Seats7.jpg"), loadImage("assets/Seats2.jpg"), loadImage("assets/Seats8.png")], 
    [loadImage("assets/Carpet1.jpg"), loadImage("assets/Carpet3.jpg"), loadImage("assets/Carpet4.jpg"), 
    loadImage("assets/Carpet5.jpg"), loadImage("assets/Carpet6.jpg"), loadImage("assets/Carpet7.jpg"), loadImage("assets/Carpet2.jpg")], 
    [loadImage("assets/Dash2.jpg"), loadImage("assets/Dash3.jpg"), loadImage("assets/Dash2.jpg"), loadImage("assets/Dash4.jpg"), loadImage("assets/Dash1.jpg")], 
    [loadImage("assets/Console2.jpg"), loadImage("assets/Console3.jpg"), loadImage("assets/Console2.jpg"), loadImage("assets/Console4.jpg"), loadImage("assets/Console1.jpg")], 
    [loadImage("assets/VentsC2.jpg"), loadImage("assets/VentsC3.jpg"), loadImage("assets/VentsC1.jpg")], 
    [loadImage("assets/VentsS2.jpg"), loadImage("assets/VentsS3.jpg"), loadImage("assets/VentsS4.jpg"), loadImage("assets/VentsS3.jpg"), loadImage("assets/VentsS1.jpg")], 
    [loadImage("assets/windowsI2.jpg"), loadImage("assets/windowsI3.jpg"), loadImage("assets/windowsI4.jpg"), loadImage("assets/windowsI1.jpg")], 
    [loadImage("assets/windowsX2.jpg"), loadImage("assets/windowsX3.jpg"), loadImage("assets/windowsX4.jpg"), loadImage("assets/windowsX5.jpg"), 
    loadImage("assets/windowsX6.jpg"), loadImage("assets/windowsX1.jpg")]];
  lvlTools = [
    ["NONE", "RINSE", "PAINT", "STEAM", "RAG"], //mats
    ["NONE", "RINSE", "PAINT", "STEAM", "RAG", "CONDR"], //doors
    ["NONE", "VAC", "CLEAN", "PAINT", "STEAM", "RAG", "CONDR"], //seats
    ["NONE", "VAC", "CLEAN", "STEAM", "BRUSH"], //carpet
    ["STEAM", "RAG", "CONDR"], //dash
    ["STEAM", "RAG", "CONDR"], //console
    ["PAINT"], //central vents
    ["PAINT", "STEAM", "RAG"], //lateral vents
    ["STEAM", "RAG"], //windows
    ["RINSE", "CLAY", "RINSE", "RAG"]]; //windows
  lvlTolerance = [.91, .88, .84, .92, .86, .95, .97, .76, .84, .84];
  paintOffset = [createVector(0, -25), createVector(24, 27), createVector(-1, -31), createVector(-6, 38), 
    createVector(12, 22), createVector(-20, 0), createVector(10, 7), createVector(17, -8), createVector(30, 33), createVector(-35, 12)];
}

function assignTools2Task() {
  tool2Task["RINSE"] = "Spray rinse";
  tool2Task["RAG"] = "Wipe dry";
  tool2Task["STEAM"] = "Steam blow";
  tool2Task["PAINT"] = "Paint brush";
  tool2Task["BRUSH"] = "Utility brush";
  tool2Task["VAC"] = "Vacuum";
  tool2Task["CLAY"] = "Apply clay";
  tool2Task["CONDR"] = "Apply conditioner";
  tool2Task["CLEAN"] = "Apply cleaner";
}

function displayTasks() {
  textAlign(RIGHT, TOP);
  textSize(18);
  rectMode(CORNER);
  noStroke();
  fill(0, 0, 0, 180);
  rect(width-215, 32, 215, lvlTools[levelCount].length*30+6, 10);
  for (var i=0; i<lvlTools[levelCount].length; i++) {
    fill(255);
    if (lvlTools[levelCount][i]=="NONE") {
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
      noStroke();
      text(tool2Task[lvlTools[levelCount][i]], width-40, i*30+39);
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
  noStroke();
  fill(0);
  text(taskPercent.toString()+"%", width-20, taskCount*30+50);

  // what happens after level completed
  if (taskCount==lvlTools[levelCount].length) {
    fill(50);
    stroke(0);
    strokeWeight(6);
    rect(width-140, taskCount*30+50, 137, 60, 10);
    textSize(45);
    noStroke();
    fill(255);
    text("NEXT", width-70, taskCount*30+80);
    if (mouseIsPressed && mouseX>width-140 && mouseX<width && mouseY>taskCount*30+50 && mouseY<taskCount*30+110) {
      if (levelCount==4 || levelCount==6 || levelCount==8) {
        levelCount++;
        taskCount = 0;
        taskPercent = 0;
        painted = createGraphics(lvlImgs[levelCount][taskCount].width, lvlImgs[levelCount][taskCount].height);
      } else if (levelCount==9) {
        display = "LAST";
      } else {
        display = "MENU";
      }
    }
  }
}

function mousePressed() {
  if (!(mouseY>height-72 && mouseX>104 && mouseX<width-104)) {
    inPlay = true;
  }
}

function mouseReleased() {
  if (inPlay) {
    inPlay = false;
  }
}

function displayTools() {
  image(Toolbar, width/2, height-36);
  if (mouseY>height-72 && mouseX>104 && mouseX<width-104 && !(inPlay)) {
    textAlign(LEFT, BOTTOM);
    textSize(20);
    rectMode(CORNER);
    noStroke();
    fill(0, 0, 0, 180);
    if (mouseX>104 && mouseX<173) {
      rect(mouseX, mouseY-29, 61, 25, 4);
      fill(255);
      text("HAND", mouseX+5, mouseY-5);
      if (mouseIsPressed) {
        tool = "NONE";
      }
    } else if (mouseX>173 && mouseX<242) {
      rect(mouseX, mouseY-29, 64, 25, 4);
      fill(255);
      text("SPRAY", mouseX+5, mouseY-5);
      if (mouseIsPressed) {
        tool = "RINSE";
      }
    } else if (mouseX>242 && mouseX<311) {
      rect(mouseX, mouseY-29, 74, 25, 4);
      fill(255);
      text("TOWEL", mouseX+5, mouseY-5);
      if (mouseIsPressed) {
        tool = "RAG";
      }
    } else if (mouseX>311 && mouseX<380) {
      rect(mouseX, mouseY-29, 93, 25, 4);
      fill(255);
      text("STEAMER", mouseX+5, mouseY-5);
      if (mouseIsPressed) {
        tool = "STEAM";
      }
    } else if (mouseX>380 && mouseX<449) {
      rect(mouseX, mouseY-29, 125, 25, 4);
      fill(255);
      text("PAINT BRUSH", mouseX+5, mouseY-5);
      if (mouseIsPressed) {
        tool = "PAINT";
      }
    } else if (mouseX>449 && mouseX<518) {
      rect(mouseX, mouseY-29, 69, 25, 4);
      fill(255);
      text("BRUSH", mouseX+5, mouseY-5);
      if (mouseIsPressed) {
        tool = "BRUSH";
      }
    } else if (mouseX>518 && mouseX<587) {
      rect(mouseX, mouseY-29, 86, 25, 4);
      fill(255);
      text("VACUUM", mouseX+5, mouseY-5);
      if (mouseIsPressed) {
        tool = "VAC";
      }
    } else if (mouseX>587 && mouseX<656) {
      rect(mouseX, mouseY-29, 55, 25, 4);
      fill(255);
      text("CLAY", mouseX+5, mouseY-5);
      if (mouseIsPressed) {
        tool = "CLAY";
      }
    } else if (mouseX>656 && mouseX<725) {
      rect(mouseX, mouseY-29, 133, 25, 4);
      fill(255);
      text("CONDITIONER", mouseX+5, mouseY-5);
      if (mouseIsPressed) {
        tool = "CONDR";
      }
    } else {
      rect(mouseX, mouseY-29, 92, 25, 4);
      fill(255);
      text("CLEANER", mouseX+5, mouseY-5);
      if (mouseIsPressed) {
        tool = "CLEAN";
      }
    }
  } else {
    switch (tool) {
    case "NONE":
      image(none, mouseX+10, mouseY);
      break;
    case "RINSE":
      image(rinse, mouseX+10, mouseY+40);
      break;
    case "RAG":
      image(rag, mouseX-10, mouseY+30);
      break;
    case "STEAM":
      image(steam, mouseX+30, mouseY+70);
      break;
    case "PAINT":
      image(paint, mouseX+35, mouseY+35);
      break;
    case "BRUSH":
      image(brush, mouseX+20, mouseY+10);
      break;
    case "VAC":
      image(vac, mouseX+20, mouseY+40);
      break;
    case "CLAY":
      image(clay, mouseX, mouseY);
      break;
    case "CONDR":
      image(condr, mouseX-10, mouseY+40);
      break;
    case "CLEAN":
      image(clean, mouseX-10, mouseY+40);
      break;
    }
  }
}