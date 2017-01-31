ArrayList<Integer[]> board;
int dropClock;
Tile tile;
Tile nextTile;
Tile swapTile;
int tempTile;
color[] colourLib = new color[]{color(50, 200, 200), color(230, 230, 0), color(150, 0, 150), color(0, 0, 250), 
  color(250, 130, 0), color(250, 0, 0), color(50, 250, 50)};
int score;
boolean gameOver;
boolean showSwap;
boolean allowSwap;

void setup() {
  size(550, 700);
  dropClock = 30;
  score = 0;
  gameOver=false;
  board = new ArrayList<Integer[]>();
  for (int i=0; i<21; i++) {
    board.add(new Integer[]{7, 7, 7, 7, 7, 7, 7, 7, 7, 7});
  }
  tile = new Tile();
  nextTile = new Tile();
  showSwap=false;
  allowSwap=true;
}

void draw() {
  background(200);
  for (int i=0; i<20; i++) {
    for (int j=0; j<10; j++) {
      if (board.get(i)[j]!=7) {
        fill(colourLib[board.get(i)[j]]);
        rect(50+(j*30), 620-(i*30), 30, 30);
      }
    }
  }

  fill(tile.colour); // current tile
  for (int[] tile : tile.tiles) {
    rect(50+(tile[0]*30), 620-(tile[1]*30), 30, 30);
  }

  fill(nextTile.colour); // next tile
  for (int[] tile : nextTile.tiles) {
    rect(300+(tile[0]*30), 900-(tile[1]*30), 30, 30);
  }

  if (showSwap) {
    fill(swapTile.colour); // swapped tile
    for (int[] tile : swapTile.tiles) {
      rect(300+(tile[0]*30), 700-(tile[1]*30), 30, 30);
    }
  }
  
  noFill();
  stroke(0);
  rect(375, 75, 150, 150);
  rect(375, 275, 150, 150);

  fill(0);
  textAlign(CENTER, CENTER);
  textSize(24);
  text("Swap", 450, 200);
  text("Next", 450, 400);
  text("Score", 450, 600);
  textSize(60);
  text(score, 450, 540);

  stroke(150);
  for (int i=50; i<351; i+=30) { //grid
    line(i, 50, i, 650);
    line(50, i, 350, i);
    line(50, i+300, 350, i+300);
  }

  if (dropClock-- == 0) {
    tile.drop();
    if (tile.goodDrop==false) {
      tile = nextTile;
      nextTile = new Tile();
      allowSwap=true;
    }
    clearRow();
    dropClock = 30;
  }

  noStroke();
  fill(200);
  rect(0, 0, width, 50);

  if (gameOver) {
    textSize(96);
    fill(0);
    text("GAME", 200, 225);
    text("OVER", 200, 325);
    if (mousePressed==true) {
      setup();
    }
  }
}

void clearRow() {
  int rowsInARow=0;
  for (int i=0; i<20; i++) {
    boolean noSevens = true;
    for (int j=0; j<10; j++) {
      if (board.get(i)[j]==7) {
        noSevens = false;
      }
    }
    if (noSevens) {
      board.remove(i);
      board.add(new Integer[]{7, 7, 7, 7, 7, 7, 7, 7, 7, 7});
      rowsInARow++;
      i--;
    }
  }
  if (rowsInARow!=0) {
    score+=(rowsInARow*2-1+(rowsInARow/2/2))*10;
    println(score);
  }
}

class Tile {
  // 0=line, 1=sqr, 2=T, 3=L, 4=L, 5=S, 6=Z
  // rotation is clockwise
  int[][] tiles = new int[4][];
  int variant = int(random(7));
  boolean goodDrop=true;
  int rotation=0;
  int stickRotate=0;
  color colour;

  Tile() {
    pickShape();
  }

  Tile(int v) {
    variant=v;
    pickShape();
  }

  void pickShape() {
    switch (variant) {
    case 0:
      tiles[0] = new int[]{3, 19};
      tiles[1] = new int[]{4, 19};
      tiles[2] = new int[]{5, 19};
      tiles[3] = new int[]{6, 19};
      break;
    case 1:  
      tiles[0] = new int[]{4, 20};
      tiles[1] = new int[]{5, 20};
      tiles[2] = new int[]{4, 19};
      tiles[3] = new int[]{5, 19};
      break;
    case 2:  
      tiles[0] = new int[]{4, 20};
      tiles[1] = new int[]{3, 19};
      tiles[2] = new int[]{4, 19};
      tiles[3] = new int[]{5, 19};
      break;
    case 3:  
      tiles[0] = new int[]{3, 20};
      tiles[1] = new int[]{3, 19};
      tiles[2] = new int[]{4, 19};
      tiles[3] = new int[]{5, 19};
      break;
    case 4:  
      tiles[0] = new int[]{5, 20};
      tiles[1] = new int[]{3, 19};
      tiles[2] = new int[]{4, 19};
      tiles[3] = new int[]{5, 19};
      break;
    case 5:  
      tiles[0] = new int[]{5, 20};
      tiles[1] = new int[]{4, 20};
      tiles[2] = new int[]{4, 19};
      tiles[3] = new int[]{3, 19};
      break;
    case 6:  
      tiles[0] = new int[]{3, 20};
      tiles[1] = new int[]{4, 20};
      tiles[2] = new int[]{4, 19};
      tiles[3] = new int[]{5, 19};
      break;
    }
    colour = colourLib[variant];
  }

  void drop() {
    goodDrop = true;
    for (int[] tile : tiles) {
      if (tile[1]==0 || board.get(tile[1]-1)[tile[0]]!=7) {
        goodDrop = false;
      }
    }
    for (int[] tile : tiles) {
      if (goodDrop) {
        tile[1]--;
      } else {
        if (tile[1]==19) {
          gameOver=true;
        } else {
          board.get(tile[1])[tile[0]] = variant;
        }
      }
    }
  }

  void rotation() {
    switch (variant) {
    case 0:
      switch (stickRotate) {
      case 0:
        tiles[0][0]+=2; 
        tiles[0][1]+=1;
        tiles[1][0]+=1; 
        tiles[1][1]+=0;
        tiles[2][0]+=0; 
        tiles[2][1]+=-1;
        tiles[3][0]+=-1; 
        tiles[3][1]+=-2;
        break;
      case 1:  
        tiles[0][0]+=1; 
        tiles[0][1]+=-2;
        tiles[1][0]+=0; 
        tiles[1][1]+=-1;
        tiles[2][0]+=-1; 
        tiles[2][1]+=0;
        tiles[3][0]+=-2; 
        tiles[3][1]+=1;
        break;
      case 2:  
        tiles[0][0]+=-2; 
        tiles[0][1]+=-1;
        tiles[1][0]+=-1; 
        tiles[1][1]+=0;
        tiles[2][0]+=0; 
        tiles[2][1]+=1;
        tiles[3][0]+=1; 
        tiles[3][1]+=2;
        break;
      case 3:  
        tiles[0][0]+=-1; 
        tiles[0][1]+=2;
        tiles[1][0]+=0; 
        tiles[1][1]+=1;
        tiles[2][0]+=1; 
        tiles[2][1]+=0;
        tiles[3][0]+=2; 
        tiles[3][1]+=-1;
        break;
      }
      stickRotate++;
      if (stickRotate==4) {
        stickRotate=0;
      }
      break;
    case 1:  
      break;
    case 2:  
    case 3:
    case 4:
    case 5:
    case 6:  
      for (int[] tile : tiles) {
        if (tiles[2][1]-tile[1]==-1) { //top row
          if (tiles[2][0]-tile[0]==1) { //topleft
            tile[0]+=2;
          } else if (tiles[2][0]-tile[0]==0) { //topmid
            tile[0]++;
            tile[1]--;
          } else if (tiles[2][0]-tile[0]==-1) { //topright
            tile[1]+=-2;
          }
        } else if (tiles[2][1]-tile[1]==1) { //bottom row
          if (tiles[2][0]-tile[0]==1) { //botleft
            tile[1]+=2;
          } else if (tiles[2][0]-tile[0]==0) { //botmid
            tile[0]--;
            tile[1]++;
          } else if (tiles[2][0]-tile[0]==-1) { //botright
            tile[0]+=-2;
          }
        } else if (tiles[2][0]-tile[0]==1) { //midleft
          tile[0]++;
          tile[1]++;
        } else if (tiles[2][0]-tile[0]==-1) { //midright
          tile[0]--;
          tile[1]--;
        }
      }
    }
    int xcorrection=0;
    for (int[] tile : tiles) {
      if (tile[0]<0) {
        xcorrection-=tile[0];
      } else if (tile[0]>9) {
        xcorrection = 9-tile[0];
      }
    }
    if (xcorrection!=0) {
      for (int[] tile : tiles) {
        tile[0]+=xcorrection;
      }
    }
    boolean ycorrection=true;
    while (ycorrection) {
      ycorrection=false;
      for (int[] tile : tiles) {
        if (tile[1]<0 || board.get(tile[1])[tile[0]]==1) {
          ycorrection=true;
        }
      }
      if (ycorrection) {
        for (int[] tile : tiles) {
          tile[1]++;
        }
      }
    }
  }
}

void keyPressed() {
  boolean goodTranslate=true;
  if (keyCode==LEFT) {
    for (int[] tile : tile.tiles) {
      if (tile[0]==0 || board.get(tile[1])[tile[0]-1]!=7) {
        goodTranslate=false;
      }
    }
    if (goodTranslate) {
      for (int[] tile : tile.tiles) {
        tile[0]--;
      }
    }
  }
  if (keyCode==RIGHT) {
    for (int[] tile : tile.tiles) {
      if (tile[0]==9 || board.get(tile[1])[tile[0]+1]!=7) {
        goodTranslate=false;
      }
    }
    if (goodTranslate) {
      for (int[] tile : tile.tiles) {
        tile[0]++;
      }
    }
  }
  if (keyCode==UP) {
    tile.rotation();
  }
  if (keyCode==DOWN) {
    tile.drop();
  }
  if (keyCode==SHIFT && allowSwap) {
    if (!showSwap) {
      swapTile = new Tile(tile.variant);
      tile = nextTile;
      nextTile = new Tile();
    } else {
      tempTile = tile.variant;
      tile = new Tile(swapTile.variant);
      swapTile = new Tile(tempTile);
    }
    showSwap=true;
    allowSwap=false;
  }
}