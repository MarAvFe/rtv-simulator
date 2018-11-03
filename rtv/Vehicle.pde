class Vehicle {

  int duration, timeLeft;
  float posX, posY;
  float orientation;
  boolean attended, showTicker;
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
  
  void setOrientation(float orientation) { 
    this.orientation = radians(orientation);
  }

  boolean canGiveStep() { // LookAhead
    if ( this.pathLength < this.stepSize ){
      this.attended = false;
      return false;
    }
    return true;
  }

  void giveStep() {
    if ( this.canGiveStep() )
      this.posX += this.stepSize;
      this.pathLength -= this.stepSize;
  }

  void shape() {
    beginShape();
    vertex(0, -15);
    vertex(-10, 15);
    vertex(10, 15);
    endShape();
  }

  void draw() {
    if ((frameCount%REIT == 0) && this.attended) this.decrease(); /* Si está siendo atendido, disminuya el timer */
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
    super(20);
  }
  void shape() {
    fill(color(118, 70, 25));
    ellipse(0, 0, 7, 13);
    ellipse(0, 10, 7, 13);
    ellipse(0, -10, 5, 10);
    rect(-7, -9, 14, 5);
  }
}
class MotoNueva extends Vehicle { 
  MotoNueva() { 
    super(30);
  }
  void shape() {
    fill(color(46, 206, 219));
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
