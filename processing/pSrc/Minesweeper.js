var field;
var lose;
var misPress;
var win;
var time;
var timing;
var playing;
var startTime;

var leftButton;
var rightButton;
var middleButton;

function setup() {
  var canvas = createCanvas(500, 500);
  canvas.parent('sketch-holder');
  reset();
}

function draw() {
  background(189);
  field.displayField();
  noStroke();
  fill(0);
  textSize(50);
  textAlign(CENTER, CENTER);
  if (win) {
    text("WIN!", 212, 100);
  } else if (lose) {
    text("LOSE :(", 212, 100);
  }
  fill(0);
  textSize(16);
  textAlign(LEFT, BOTTOM);
  text("Flags: "+str(field.flags), 100, 190);
  text("Time: "+str(time), 225, 190);
  if (timing) {
    time = floor((frameCount-startTime)/60);
  }
  textSize(12);
  text("Press 'r' to reset game", 100, 450);
}

function reset() {
  field = null;
  field = new Field(9, 9);
  lose = false;
  misPress = [-1, -1];
  win = false;
  time = 0;
  timing = false;
  playing = false;
}

function Field(rowIn, colIn) {
  this.row = rowIn;
  this.col = colIn;
  this.flags = 10;

  //initiate empty mine field
  this.grid = [];
  for (var i=0; i<colIn; i++) {
    var temp = [];
    for (var j=0; j<rowIn; j++) {
      temp.push(0);
    }
    this.grid.push(temp);
  }

  //place mines
  var iter = 0;
  while (iter<10) {
    randRow = floor(random(this.row));
    randCol = floor(random(this.col));
    if (this.grid[randCol][randRow] != -1) {
      this.grid[randCol][randRow] = -1;
      for (var i=max(0, randCol-1); i<min(this.col, randCol+2); i++) {
        for (var j=max(0, randRow-1); j<min(this.row, randRow+2); j++) {
          if (this.grid[i][j] != -1) {
            this.grid[i][j]++;
          }
        }
      }
      iter++;
    }
  }

  //initiate "show" array
  this.show = [];
  for (var i=0; i<colIn; i++) {
    var temp = [];
    for (var j=0; j<rowIn; j++) {
      temp.push(0);
    }
    this.show.push(temp);
  }

  this.displayField = function() {
    stroke(123);
    line(100, 200, 100+this.row*25, 200);
    line(100, 200, 100, 200+this.col*25);
    for (var i=1; i<this.row+1; i++) {
      line(100+i*25, 200, 100+i*25, 200+this.col*25);
    }
    for (var i=1; i<this.col+1; i++) {
      line(100, 200+i*25, 100+this.row*25, 200+i*25);
    }

    var showNum = 0;
    for (var i=0; i<this.col; i++) {
      for (var j=0; j<this.row; j++) {
        if (lose && this.grid[i][j]==-1) { //reveal remaining bombs on lose
          this.show[i][j] = 1;
        }
        if (this.show[i][j] == 1) {
          if (!lose) {
            showNum++;
          }
          if (this.grid[i][j] > 0) { //number
            stroke(0);
            fill(0);
            textSize(16);
            textAlign(CENTER, CENTER);
            text(this.grid[i][j], 112.5+j*25, 212.5+i*25);
          } else if (this.grid[i][j] == -1) { //bomb
            if (misPress[0] == i && misPress[1] == j) { //red square
              noStroke();
              fill(255, 0, 0);
              rect(100+j*25, 200+i*25, 25, 25);
            }
            fill(0);
            stroke(0);
            ellipse(113+j*25, 213+i*25, 15, 15);
            line(113+j*25, 203+i*25, 113+j*25, 222+i*25);
            line(103+j*25, 213+i*25, 122+j*25, 213+i*25);
            line(105+j*25, 205+i*25, 120+j*25, 220+i*25);
            line(105+j*25, 220+i*25, 120+j*25, 205+i*25);
            fill(255);
            ellipse(111+j*25, 211+i*25, 6, 6);
          }
        } else {
          //hidden square
          noStroke();
          fill(123);
          rect(100+j*25, 200+i*25, 25, 25);
          fill(255);
          triangle(100+j*25, 200+i*25, 100+j*25, 225+i*25, 125+j*25, 200+i*25);
          fill(189);
          rect(103+j*25, 203+i*25, 19, 19);
          if (this.show[i][j] == 2) { // flag
            stroke(0);
            fill(0);
            rect(107+j*25, 217+i*25, 11, 2);
            rect(110+j*25, 215+i*25, 5, 2);
            rect(113+j*25, 210+i*25, 1, 4);
            noStroke();
            fill(255, 0, 0);
            triangle(115+j*25, 213+i*25, 115+j*25, 205+i*25, 107+j*25, 209+i*25);
          }
        }
      }
    }
    if (showNum == this.row*this.col-10) {
      win = true;
      timing = false;
    }
  }

  this.reveal = function(x, y) {
    if (this.show[y][x] == 0) {
      this.show[y][x] = 1;
      if (this.grid[y][x] == 0) {
        this.recursiveReveal(x, y);
      } else if (this.grid[y][x] == -1) { //bomb
        lose = true;
        misPress = [y, x];
        timing = false;
      }
    }
  }

  this.recursiveReveal = function(x, y) {
    for (var i=max(0, y-1); i<min(this.col, y+2); i++) {
      for (var j=max(0, x-1); j<min(this.row, x+2); j++) {
        if (this.show[i][j] == 0) {
          this.show[i][j] = 1;
          if (this.grid[i][j]==0 && (i!=y || j!=x)) { //keep revealing empty cells
            this.recursiveReveal(j, i);
          } else if (this.grid[i][j] == -1) { //bomb (incorrect flagging)
            lose = true;
            misPress = [i, j];
            timing = false;
          }
        }
      }
    }
  }

  this.autoReveal = function(x, y) {
    if (this.show[y][x] == 1) {
      var adjacentFlags = 0;
      for (var i=max(0, y-1); i<min(this.col, y+2); i++) { //add up near flags
        for (var j=max(0, x-1); j<min(this.row, x+2); j++) {
          adjacentFlags += floor(this.show[i][j]/2);
        }
      }
      if (adjacentFlags == this.grid[y][x]) { //reveal square
        this.recursiveReveal(x, y);
      }
    }
  }

  this.flag = function(x, y) {
    if (this.show[y][x] == 0) {
      this.show[y][x] = 2;
      this.flags--;
    } else if (this.show[y][x] == 2) {
      this.show[y][x] = 0;
      this.flags++;
    }
  }
}

function mousePressed() {
  if (mouseButton==LEFT) {
    leftButton = true;
  } else if (mouseButton==RIGHT) {
    rightButton = true;
  } else if (mouseButton==CENTER) {
  	middleButton = true;
  }
}

function mouseReleased() {
  if (!lose && !win) {
    var x = floor((mouseX-100)/25);
    var y = floor((mouseY-200)/25);
    if (x>=0 && x<field.row && y>=0 && y<field.col) {
      if (leftButton && !rightButton) { //left click
        field.reveal(x, y);
        if (!playing) { //restart game if first click is mine
          while (lose) {
            reset();
            field.reveal(x, y);
          }
          playing = true;
          timing = true;
          startTime = frameCount;
        }
      } else if (!leftButton && rightButton) { //right click
        field.flag(x, y);
      } else if ((leftButton && rightButton) || middleButton) { //left & right click OR middle click
        field.autoReveal(x, y);
      }
    }
  }
  
  leftButton = false;
  rightButton = false;
  middleButton = false;
}

function keyTyped() {
  if (key=='r') {
    reset();
  }
}
