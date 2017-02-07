// Further apart = red, faster
// Closer together = green, slower
ArrayList<Dot> dotArray;

void setup() {
  size(1200, 500);
  dotArray = new ArrayList<Dot>();
  for (int i=0; i<25; i++) {
    dotArray.add(new Dot(random(width), random(height)));
  }
}

void draw() {
  background(0, 0, 40);
  for (int i=0; i<dotArray.size(); i++) {
    dotArray.get(i).display();
    dotArray.get(i).move();
    for (int j=i+1; j<dotArray.size(); j++) {
      if (sqrt(sq(dotArray.get(i).loc.x-dotArray.get(j).loc.x) + 
        sq(dotArray.get(i).loc.x-dotArray.get(j).loc.x)) < 300) {
        strokeWeight(1);
        stroke(255);
        line(dotArray.get(i).loc.x, dotArray.get(i).loc.y, 
          dotArray.get(j).loc.x, dotArray.get(j).loc.y);
      }
    }
  }
}

//void colourBack() {
//  float distance = 0;
//  int connections = 0;
//  for (int i=0; i<dotArray.size(); i++) {
//    for (int j=i+1; j<dotArray.size(); j++) {
//      connections++;
//      distance+=sqrt(sq(dotArray.get(i).loc.x - dotArray.get(j).loc.x) +
//        sq(dotArray.get(i).loc.y - dotArray.get(j).loc.y));
//    }
//  }
//  if (connections != 0) {
//    distance/=connections;
//    for (Dot dot : dotArray) {
//      dot.mag = distance/90;
//    }
//  }
//  background(distance/2+50, 300-distance/2, 0);
//}

class Dot {
  PVector loc;
  PVector vel;
  float mag = 3;

  Dot(float x, float y) {
    loc = new PVector(x, y);
    vel = new PVector(random(-5, 5), random(-5, 5));
    vel.setMag(mag);
  }

  void display() {
    strokeWeight(5);
    stroke(255);
    point(loc.x, loc.y);
  }

  void move() {
    vel.setMag(mag);
    loc.x+=vel.x;
    loc.y+=vel.y;
    if (loc.x<0 || loc.x>width) {
      vel.x*=-1;
    }
    if (loc.y<0 || loc.y>height) {
      vel.y*=-1;
    }
  }
}
