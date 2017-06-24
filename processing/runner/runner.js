var player;
var obstList;
var newGame;
var ground;
var obstSpeed;
var obstOffset;
var obstCount;
var score;

function setup() {
  var canvas = createCanvas((windowWidth>1600 ? 1600 : windowWidth), (windowHeight>1600 ? 1600 : windowHeight));
  //parent.canvas = "sketch-holder";

  obstList = [];
  for (var i = 0; i<5; i++) {
    obstList.push(new Obstacle());
  }
  player = new Character();
  newGame = true;
  ground = new Ground();
  obstSpeed = width/120;
  score = 0;
}

function draw() {
  background(200);
  displayScore();
  if (newGame) {
    menuScreen();
  } else {
    playGame();
  }
}

function menuScreen() {
  rectMode(CORNER);
  fill(0, 150);
  rect(width/2-200, height/2-50, 400, 100, 10);
  textAlign(CENTER, CENTER);
  textSize(72);
  stroke(0);
  strokeWeight(5);
  fill(255);
  text("New Game", width/2, height/2);

  obstOffset = 0;
  obstCount = 0;
  
  for (var i=0; i<obstList.length; i++) {
    obstList[i].active = false;
    obstList[i].loc.x = width+obstList[i].rad+10;
    obstList[i].loc.y = height*4/5-obstList[i].rad;
  }
}

function playGame() {
  ground.display();
  for (var i=0; i<obstList.length; i++) {
    obstList[i].motion();
    obstList[i].display();
  }
  player.motion();
  player.checkColl();
  player.display();

  if (obstOffset-- == 0) {
    obstOffset = floor(width/16);
    console.log(obstOffset);
    if (obstCount == obstList.length) {
      obstCount = 0;
    }
    obstList[obstCount++].active = true;
  }
}

function displayScore() {
  textAlign(CENTER, CENTER);
  textSize(72);
  stroke(0);
  fill(255);
  //text(score, width/2, height/5);
  text(windowWidth.toString()+","+windowHeight.toString(), width/2, height/5);
}

function Character() {
  this.rad = width/25;
  this.col = color(200, 50, 50);
  this.loc = createVector(width/5, height*4/5-this.rad);
  this.jumping = false;
  this.jumpAcc = -this.rad/80;
  this.jumpVel = 0.0;

  this.motion = function() {
    if (this.jumping) {
      this.loc.y-=this.jumpVel;
      this.jumpVel+=this.jumpAcc;
      if (this.loc.y+this.rad>=ground.y) {
        this.jumping = false;
        this.loc.y = ground.y-this.rad;
      }
    }
  }

  this.display = function() {
    rectMode(RADIUS);
    fill(this.col);
    rect(this.loc.x, this.loc.y, this.rad, this.rad);
  }

  this.checkColl = function() {
    for (var i=0; i<obstList.length; i++) {
      if (dist(this.loc.x, this.loc.y, obstList[i].loc.x, obstList[i].loc.y) < this.rad+obstList[i].rad) {
        newGame = true;
      }
    }
  }
}

function Obstacle() {
  this.rad = width/25;
  this.col = color(0);
  this.loc = createVector(width+this.rad+10, height*4/5-this.rad);
  this.active = false;
  this.scored = false;

  this.motion = function() {
    if (this.active) {
      this.loc.x -= obstSpeed;
      if (this.loc.x+this.rad<0) {
        this.active = false;
        this.scored = false;
        this.loc.x = width+this.rad+10;
      }
    }
    if (!(this.scored) && this.loc.x+this.rad<player.loc.x-player.rad) {
      score++;
      this.scored = true;
    }      
  }

  this.display = function() {
    rectMode(RADIUS);
    fill(this.col);
    rect(this.loc.x, this.loc.y, this.rad, this.rad);
  }
}

function Ground() {
  this.y = height*4/5;

  this.display = function() {
    strokeWeight(5);
    stroke(0);
    fill(150);
    rectMode(CORNER);
    rect(-10, this.y, width+10, height+10);
  }
}  

function keyPressed() {
  if (key==' ' && !(player.jumping)) {
    player.jumping = true;
    player.jumpVel = player.rad/3;
  }
}

function mousePressed() {
  if (newGame && mouseX>width/2-200 && mouseY>height/2-50 && mouseX<width/2+200 && mouseY<height/2+50) {
    newGame = false;
    score = 0;
  }
}

function touchStarted() {
  if (newGame && mouseX>width/2-200 && mouseY>height/2-50 && mouseX<width/2+200 && mouseY<height/2+50) {
    newGame = false;
    score = 0;
  } else if (!(newGame) && !(player.jumping)) {
    player.jumping = true;
    player.jumpAcc = width/20;
  }
  return false;
}