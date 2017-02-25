int i;
int j;
int k;
float x;
float y;
float M = 0.1;
float m;
Grid[] dot = new Grid[576];

void setup() {
  size(500,500);
  for (i=1;i<25;i++) {
    y = i*20;
    for (j=1;j<25;j++) {
      x = j*20;
      dot[k] = new Grid();
      k++;
    }
  }
}

class Grid {
  float d = 7;
  float xpos;
  float ypos;
  float v;
  
  Grid() {
    xpos = x;
    ypos = y;
  }
  
  void display() {
    v = sqrt(sq(mouseX-xpos)+sq(mouseY-ypos))*m;
    if (abs(v)<1) {
      v = v/abs(v);
    }
    noStroke();
    ellipseMode(CENTER);
    fill(0);
    if (abs(mouseX-xpos)<200 && abs(mouseY-ypos)<200) {
      ellipse(xpos+(mouseX-xpos)/(v*abs(v)),ypos+(mouseY-ypos)/(v*abs(v)),d,d);
    } else {
      ellipse(xpos,ypos,d,d);
    }
  }
}

void draw() {
  background(100,200,120);
  if (mousePressed == true) {
    m = -M;
  } else {
    m = M;
  }
  for (i=0;i<576;i++) {
    dot[i].display();
  }
}