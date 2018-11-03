class Queue {

  int front;
  int size;
  ArrayList<Vehicle> queue;

  Queue() {
    this.front = 0;
    this.size = 0;
    this.queue = new ArrayList<Vehicle>(10);
  }

  void queue(Vehicle v) {
    this.queue.add(v);
    this.size++;
  }

  Vehicle dequeue() {
    Vehicle res = this.queue.get(0);
    this.queue.remove(res);
    return res;
  }
}

class Line extends Queue {
  boolean[] types; // Cada posición dice si atiende o no un tipo de vehículo
  boolean running; // running or paused
  boolean isAttention;
  int capacity;    // segundos
  int load;        // Suma de vehículos encolados
  float pathHeight, pathStart, pathEnd, pathLength, pathAltitude;

  Line(int capacity, boolean isAttention, boolean[] types, float x, float y, float w, float h) {
    super();
    this.capacity = capacity;
    this.isAttention = isAttention;
    this.load = 0;
    this.types = types;
    this.running = true;
    this.pathHeight = y;
    this.pathStart = x;
    this.pathLength = w;
    this.pathAltitude = h;
  }

  void queue(Vehicle v) {
    this.load += v.getDuration();
    v.setPathLength(this.pathLength);
    v.setPos(this.pathStart, this.pathHeight);
    v.setOffsets(this.pathStart, this.pathAltitude);
    super.queue(v);
  }

  Vehicle dequeue() {
    Vehicle v = super.dequeue();
    this.load -= v.getDuration();
    return v;
  }

  void setCapacity(int capacity) {
    if ( capacity > this.capacity ) {
      this.capacity = capacity;
    } else if ( capacity >= this.load ) {
      this.capacity = capacity;
    }
  }

  void setTypes(boolean[] types) {
    this.types = types;
  }

  int getAvailableSpace() {
    return this.capacity - this.load;
  }

  boolean isRunning() {
    return this.running;
  }
  
  Vehicle update() {
    for (Vehicle v : this.queue ) {
      if (v.getPathLenght() < 0) {
        if ( this.isAttention ) {
          return v;
        } else {
          return v;
        }
      }
    }
    return null;
  }

  void draw() {
    fill(backgrounds[(this.isAttention)?0:1]);
    rect(this.pathStart, this.pathHeight-this.pathAltitude/2, this.pathLength, this.pathAltitude);
    for (Vehicle v : this.queue) {
      if (frameCount%REIT == 0) v.giveStep();
      v.draw();
    }
  }
}

class RTV {
  int numLines;
  ArrayList<Line> attentionLines;
  ArrayList<Line> waitLines;
  float posX, posY;
  float allHeight, allWidth;
  float lineHeight;

  RTV(int numLines) {
    this.numLines = numLines;
    this.attentionLines = new ArrayList<Line>(this.numLines);
    this.waitLines = new ArrayList<Line>(this.numLines);
    boolean[] types = {true, true, true, true, true, true, true};
    this.posX = width*0.35;
    this.posY = height*0.1;
    this.allHeight = height*0.6;
    this.allWidth = width*0.6;
    this.lineHeight = this.allHeight / this.numLines;
    for ( int i = 0; i < numLines; i++ ) {
      float h = this.posY + (i*this.lineHeight - this.lineHeight/2);
      this.attentionLines.add(new Line(20, true, types, this.allWidth/2, h, this.allWidth/2, this.lineHeight));
      this.waitLines.add(new Line(20, false, types, 0, h, this.allWidth/2, this.lineHeight));
    }
  }

  void setLineCapacity(int lineNumber, int capacity) {
    this.attentionLines.get(lineNumber).setCapacity(capacity);
  }

  void setLineTypes(int lineNumber, boolean[] types) {
    this.attentionLines.get(lineNumber).setTypes(types);
  }

  void attend(int line, Vehicle v) {
    v.attend();
    this.attentionLines.get(line).queue(v);
  }

  void hold(int line, Vehicle v) {
    this.waitLines.get(line).queue(v);
  }

  void drawAttention() {
    float start = this.allWidth*0.5;
    fill(color(224, 200, 36));
    text("Attending zone", start, -20);
    for ( Line l : this.attentionLines ) {
      l.draw();
    }
  }

  void drawHold() {
    fill(color(224, 224, 136));
    text("Wait zone", 0, -20);
    for ( Line l : this.waitLines ) {
      l.draw();
    }
  }
  
  void update() {
    for ( Line l : this.waitLines ) {
      Vehicle v = l.update();
      if (v != null) {
        l.queue.remove(v);
        this.attend(this.waitLines.indexOf(l),v);
      }
    }
    for ( Line l : this.attentionLines ) {
      Vehicle v = l.update();
      if (v != null) {
        l.queue.remove(v);
      }
    }
  }

  void draw() {    

    pushMatrix();
    pushStyle();
    translate(this.posX, this.posY);

    this.drawHold();
    this.drawAttention();

    strokeCap(SQUARE);
    strokeWeight(10);
    for (int i = 0; i < this.numLines+1; i++) {
      float linePos = this.lineHeight * i;
      if ( (i==0) || (i==this.numLines) ) {
        stroke(0);
        line(0, linePos, this.allWidth, linePos);
      } else {   
        stroke(color(255, 255, 0));
        for ( int k = 0; k < this.allWidth+1; k+=100 ) {
          line(k, linePos, k+50, linePos);
        }
      }
    }
    popStyle();
    popMatrix();
  }
}
