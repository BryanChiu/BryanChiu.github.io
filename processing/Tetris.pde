import java.util.Arrays;
ArrayList<Integer[]> board;
ArrayList<Integer>[] randomCounter;
int dropClock;
Tile tile;
Tile nextTile;
Tile swapTile;
int tempTile;
color[] colourLib = new color[]{color(50, 200, 200), color(230, 230, 0), color(150, 0, 150), 
  color(0, 0, 250), color(250, 130, 0), color(250, 0, 0), color(50, 250, 50)};
int score=0;
boolean gameOver;
boolean showSwap;
boolean allowSwap;

void setup() {
  size(550, 700);
  gameOver=true;
}

void realSetup() {
  dropClock = 30;
  score = 0;
  gameOver=false;
  board = new ArrayList<Integer[]>();
  for (int i=0; i<21; i++) {
    board.add(new Integer[]{7, 7, 7, 7, 7, 7, 7, 7, 7, 7});
  }
  randomCounter = (ArrayList<Integer>[]) new ArrayList[7];
  for (int i=0; i<7; i++) {
    randomCounter[i] = new ArrayList<Integer>(Arrays.asList(i, i, i, i, i, i, i, i, i, i, i, i, i, i, i, i, i, i));
  }
  tile = new Tile();
  nextTile = new Tile();
  swapTile = new Tile();
  showSwap=false;
  allowSwap=true;
}

void draw() {
  background(200);
  if (!gameOver) {
    drawTiles();
    drawBoard();
    dropLine();
  }

  fill(0);
  textAlign(CENTER, CENTER);
  textSize(24);
  text("Swap", 450, 200);
  text("Next", 450, 400);
  text("Score", 450, 600);
  textSize(60);
  text(score, 450, 540);
  noFill();
  stroke(0);
  rect(375, 75, 150, 150);
  rect(375, 275, 150, 150);

  stroke(150);
  for (int i=50; i<351; i+=30) { //grid
    line(i, 50, i, 650);
    line(50, i, 350, i);
    line(50, i+300, 350, i+300);
  }

  noStroke();
  fill(200);
  rect(0, 0, width, 50);

  if (gameOver) {
    fill(0, 100);
    rect(25, 200, 350, 150);
    textSize(44);
    fill(0);
    text("Press SPACE to", 200, 225);
    text("start new game", 200, 300);
    if (keyPressed==true && key==' ') {
      realSetup();
    }
  }
}

void drawBoard() {
  for (int i=0; i<20; i++) {
    for (int j=0; j<10; j++) {
      if (board.get(i)[j]!=7) {
        fill(colourLib[board.get(i)[j]]);
        rect(50+(j*30), 620-(i*30), 30, 30);
      }
    }
  }
}

void drawTiles() {
  fill(tile.colour); // current tile
  for (int[] tyl : tile.tiles) {
    rect(50+(tyl[0]*30), 620-(tyl[1]*30), 30, 30);
  }

  fill(nextTile.colour); // next tile
  for (int[] tyl : nextTile.tiles) {
    rect(300+(tyl[0]*30), 900-(tyl[1]*30), 30, 30);
  }

  if (showSwap) {
    fill(swapTile.colour); // swapped tile
    for (int[] tyl : swapTile.tiles) {
      rect(300+(tyl[0]*30), 700-(tyl[1]*30), 30, 30);
    }
  }
}

void dropLine() {
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
    score+=(rowsInARow*2-1+int(int(rowsInARow/2)/2))*10;
  }
}

int chooseRandom() {
  int returnVar=-1;
  while (true) {
    int rando = int(random(126));
    for (int i=0; i<7; i++) {
      if (rando - randomCounter[i].size()<0 && randomCounter[i].size()>5 && rando>0) {
        returnVar = randomCounter[i].get(rando);
        for (int j=0; j<6; j++) {
          randomCounter[i].remove(0);
        }
        for (int j=0; j<7; j++) {
          if (j!=i) {
            randomCounter[j].add(j);
          }
        }
        break;
      } else {
        rando-=18;
      }
    }
    if (returnVar!=-1) {
      break;
    }
  }
  return returnVar;
}

class Tile {
  // 0=line, 1=sqr, 2=T, 3=L, 4=L, 5=S, 6=Z
  // rotation is clockwise
  int[][] tiles = new int[4][];
  int variant;
  boolean goodDrop=true;
  int rotation=0;
  int stickRotate=0;
  color colour;

  Tile() {
    variant = chooseRandom();
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
    for (int[] tyl : tiles) {
      if (tyl[1]==0 || board.get(tyl[1]-1)[tyl[0]]!=7) {
        goodDrop = false;
      }
    }
    for (int[] tyl : tiles) {
      if (goodDrop) {
        tyl[1]--;
      } else {
        if (tyl[1]==20) {
          gameOver=true;
        } else {
          board.get(tyl[1])[tyl[0]] = variant;
        }
      }
    }
  }

  void rotation() {
    int[][] backup = new int[4][2];
    backup[0][0] = tiles[0][0];
    backup[1][0] = tiles[1][0];
    backup[2][0] = tiles[2][0];
    backup[3][0] = tiles[3][0];
    backup[0][1] = tiles[0][1];
    backup[1][1] = tiles[1][1];
    backup[2][1] = tiles[2][1];
    backup[3][1] = tiles[3][1];
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
      for (int[] tyl : tiles) {
        if (tiles[2][1]-tyl[1]==-1) { //top row
          if (tiles[2][0]-tyl[0]==1) { //topleft
            tyl[0]+=2;
          } else if (tiles[2][0]-tyl[0]==0) { //topmid
            tyl[0]++;
            tyl[1]--;
          } else if (tiles[2][0]-tyl[0]==-1) { //topright
            tyl[1]+=-2;
          }
        } else if (tiles[2][1]-tyl[1]==1) { //bottom row
          if (tiles[2][0]-tyl[0]==1) { //botleft
            tyl[1]+=2;
          } else if (tiles[2][0]-tyl[0]==0) { //botmid
            tyl[0]--;
            tyl[1]++;
          } else if (tiles[2][0]-tyl[0]==-1) { //botright
            tyl[0]+=-2;
          }
        } else if (tiles[2][0]-tyl[0]==1) { //midleft
          tyl[0]++;
          tyl[1]++;
        } else if (tiles[2][0]-tyl[0]==-1) { //midright
          tyl[0]--;
          tyl[1]--;
        }
      }
    }
    int xcorrection=0;
    for (int[] tyl : tiles) {
      if (tyl[0]<0) {
        xcorrection-=tyl[0];
      } else if (tyl[0]>9) {
        xcorrection = 9-tyl[0];
      }
    }
    if (xcorrection!=0) {
      for (int[] tyl : tiles) {
        tyl[0]+=xcorrection;
      }
    }
    for (int i=0; i<2; i++) {
      boolean ycorrection=false;
      for (int[] tyl : tiles) {
        if (tyl[1]<0 || board.get(tyl[1])[tyl[0]]!=7) {
          ycorrection=true;
        }
      }
      if (ycorrection) {
        for (int[] tyl : tiles) {
          tyl[1]++;
        }
      }
      if (variant!=0) {
        break;
      }
    }
    for (int i=1; i<6; i++) {
      boolean xcorrectionB = false;
      for (int[] tyl : tiles) {
        if (tyl[0]<0 || tyl[0]>9 || board.get(tyl[1])[tyl[0]]!=7) {
          xcorrectionB = true;
        }
      }
      if (xcorrectionB == true) {
        if (i==5) {
          tiles = backup;
          stickRotate--;
          if (stickRotate==-1) {
            stickRotate=3;
          }
          return;
        }
        for (int[] tyl : tiles) {
          tyl[0]+=pow(-1, i)*i;
        }
      } else {
        return;
      }
    }
  }
}

void keyPressed() {
  boolean goodTranslate=true;
  if (keyCode==LEFT) {
    for (int[] tyl : tile.tiles) {
      if (tyl[0]==0 || board.get(tyl[1])[tyl[0]-1]!=7) {
        goodTranslate=false;
      }
    }
    if (goodTranslate) {
      for (int[] tyl : tile.tiles) {
        tyl[0]--;
      }
    }
  }
  if (keyCode==RIGHT) {
    for (int[] tyl : tile.tiles) {
      if (tyl[0]==9 || board.get(tyl[1])[tyl[0]+1]!=7) {
        goodTranslate=false;
      }
    }
    if (goodTranslate) {
      for (int[] tyl : tile.tiles) {
        tyl[0]++;
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