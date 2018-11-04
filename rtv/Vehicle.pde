class Vehicle {

  int duration, timeLeft;
  float posX, posY, offsetX, offsetY;
  float orientation;
  boolean attended, showTicker, stuck;
  float stepSize;
  float pathLength;

  Vehicle(int duration) {
    this.duration = duration;
    this.timeLeft = duration;
    this.setOrientation(90);
    this.attended = false;
    this.showTicker = true;
    this.stepSize = 2; 
    this.posX = 40; 
    this.posY = 200;
    this.stuck = true;
  }

  void setStepSize(float lineWidth) {
    this.stepSize = lineWidth / this.duration;
  }

  void attend() {
    this.attended = true;
  }

  void decrease() { 
    this.timeLeft--;
  }

  int getDuration() { 
    return this.duration;
  }

  float getPathLenght() { 
    return this.pathLength;
  }

  void setPathLength(float pathLength) {
    this.pathLength = pathLength;
    this.setStepSize(pathLength);
  }

  void setPos(float x, float y) { 
    this.posX = x; 
    this.posY = y;
  }

  void setOffsets(float x, float y) {
    if (x == 0.0) x = width*0.35; // TODO: khe bergüensa
    this.offsetX = x; 
    this.offsetY = y;
  }

  void setOrientation(float orientation) { 
    this.orientation = radians(orientation);
  }

  boolean canGiveStep() { // LookAhead
    int ahead = -30;
    if ( this.pathLength < this.stepSize+ahead ) { // TODO: fix magic number
      this.stuck = true;
      return false;
    }

    boolean can = true;
    loadPixels();
    ahead = (this.attended) ? 100 : 40;
    float x = this.posX+this.offsetX+ahead;
    float y = this.posY+this.offsetY;
    color[] pixs = new color[int(this.stepSize)];
    for (int i = 0; i < pixs.length; i++) {
      int sight = int(y*width + x + i);
      pixs[i] = pixels[sight];
    }
    for (color c : pixs) {
      if ( isVehicle(c) ) {
        can = false;
        break;
      }
    }
    this.stuck = !can;
    return can;
  }

  void giveStep() {
    if ( this.canGiveStep() ) {
      float paso;
      if ( (frameCount % REIT == 0) && this.attended) {
        paso = this.stepSize;
        this.decrease(); /* Si está siendo atendido, disminuya el timer */
      } else {
        paso = this.stepSize*3;
      }
      this.posX += paso;
      this.pathLength -= paso;
    }
  }

  void shape() {
    fill(vehicleBackgrounds[2]);
    beginShape();
    vertex(0, -15);
    vertex(-10, 15);
    vertex(10, 15);
    endShape();
  }

  void draw() {

    pushStyle();
    pushMatrix();
    translate(this.posX, this.posY);
    rotate(this.orientation);
    this.shape();
    if (this.showTicker) {
      rotate(-this.orientation);
      fill(0, 30);
      stroke(0, 0);
      rect(-20, -30, 30, 20);
      fill(255);
      text(this.timeLeft, -10, -15);
    }
    popMatrix();
    popStyle();
  }
}

class MotoVieja extends Vehicle { 
  MotoVieja() { 
    super(30);
  }
  void shape() {
    fill(vehicleBackgrounds[0]);
    ellipse(0, 0, 7, 13);
    ellipse(0, 10, 7, 13);
    ellipse(0, -10, 5, 10);
    rect(-7, -9, 14, 5);
  }
}
class MotoNueva extends Vehicle { 
  MotoNueva() { 
    super(20);
  }
  void shape() {
    fill(vehicleBackgrounds[1]);
    ellipse(0, 0, 7, 13);
    ellipse(0, 10, 7, 13);
    ellipse(0, -10, 5, 10);
    rect(-7, -9, 14, 5);
  }
}
class SedanViejo extends Vehicle { 
  SedanViejo() { 
    super(60);
  }
}
class SedanNuevo extends Vehicle { 
  SedanNuevo() { 
    super(40);
  }
}
class Bus extends Vehicle { 
  Bus() { 
    super(80);
  }
}
class CamionDosEjes extends Vehicle { 
  CamionDosEjes() { 
    super(100);
  }
}
class CamionCincoEjes extends Vehicle { 
  CamionCincoEjes() { 
    super(120);
  }
}
