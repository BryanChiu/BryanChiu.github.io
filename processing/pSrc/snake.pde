Snake snek;
PVector food;
boolean banKeyPress;
int score;
char difficulty = '1';

void setup() {
  size(500,500);
  frameRate(5);
  snek = new Snake();
  snek.isDead = true;
  newFood();
  banKeyPress=false;
  score=0;
}

void pseudoSetup() {
  frameRate(5);
  snek = new Snake();
  newFood();
  banKeyPress=false;
  score=0;
}

void draw() {
  background(200);
  switch (difficulty) {
    case '1': frameRate(5); break;
    case '2': frameRate((snek.snake.size()/10)*2+5); break;
    case '3': frameRate(snek.snake.size());
  }
  
  stroke(150);
  for (int i=0; i<500; i+=20) {
    line(i, 0, i, 500);
    line(0, i, 500, i);
  }
  
  if (snek.isDead) {
    textAlign(CENTER,CENTER);
    textSize(72);
    fill(0);
    text("GAME OVER", 250,200);
    text(score,250,280);
    textSize(24);
    text("Press 1/2/3 to select difficulty",250,320);
    text("and start new game",250,360);
    if (keyPressed==true && (key=='1' || key=='2' || key=='3')) {
      diffculty = key;
      pseudoSetup();
    }
  } else {
    fill(255,0,0);
    rect(food.x*20, food.y*20, 20, 20);
    snek.motion();
    snek.display();
    snek.lifeOver();
  }
  
  banKeyPress=false;
}

class Snake {
  ArrayList<PVector> snake = new ArrayList<PVector>();
  String direction = "north";
  boolean isDead = false;
  
  Snake() {
    snake.add(new PVector(12,16));
    snake.add(new PVector(12,15));
    snake.add(new PVector(12,14));
    snake.add(new PVector(12,13));
    snake.add(new PVector(12,12));
  }
  
  void display() {
    for (int i=0; i<snake.size(); i++) {
      fill(50,150,50);
      rect(snake.get(i).x*20, snake.get(i).y*20, 20, 20);
    }
  }
  
  void motion() {
    if (direction=="north") {
      snake.add(new PVector(snake.get(snake.size()-1).x, snake.get(snake.size()-1).y-1));
    } else if (direction=="east") {
      snake.add(new PVector(snake.get(snake.size()-1).x+1, snake.get(snake.size()-1).y));
    } else if (direction=="south") {
      snake.add(new PVector(snake.get(snake.size()-1).x, snake.get(snake.size()-1).y+1));
    } else if (direction=="west") {
      snake.add(new PVector(snake.get(snake.size()-1).x-1, snake.get(snake.size()-1).y));
    }
    
    if (snake.get(snake.size()-1).x==food.x && snake.get(snake.size()-1).y==food.y) {
      newFood();
      score++;
    } else {
      snake.remove(0);
    }
  }
  
  void lifeOver() {
    if (snake.get(snake.size()-1).x<0 || snake.get(snake.size()-1).x>24 ||
        snake.get(snake.size()-1).y<0 || snake.get(snake.size()-1).y>24) {
      isDead=true;
    }
    for (int i=0; i<snake.size()-1; i++) {
      for (int j=i+1; j<snake.size(); j++) {
        if (snake.get(i).x==snake.get(j).x && snake.get(i).y==snake.get(j).y) {
          isDead=true;
        }
      }
    }
  }
}

void newFood() {
  food = new PVector(int(random(25)), int(random(25)));
  for (int i=0; i<snek.snake.size()-1; i++) {
    if (snek.snake.get(i).x==food.x && snek.snake.get(i).y==food.y) {
      newFood();
    }
  }  
}

void keyPressed() {
  if (banKeyPress==true) {
    return;
  }
  if (keyCode==UP && snek.direction!="north" && snek.direction!="south") {
    snek.direction="north";
  }
  if (keyCode==RIGHT && snek.direction!="east" && snek.direction!="west") {
    snek.direction="east";
  }
  if (keyCode==DOWN && snek.direction!="south" && snek.direction!="north") {
    snek.direction="south";
  }
  if (keyCode==LEFT && snek.direction!="west" && snek.direction!="east") {
    snek.direction="west";
  }
  banKeyPress=true;
}
