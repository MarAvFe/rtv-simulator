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
    if ( this.queue.size() < 1 ) return null;
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
    float back = 0; //this.isAttention ? 0 : this.queue.size()*20; 
    v.setPos(this.pathStart-back, this.pathHeight);
    v.setOffsets(this.pathStart, this.pathAltitude);
    super.queue(v);
  }

  Vehicle dequeue() {
    Vehicle v = super.dequeue();
    if (v == null) return null;
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
      if ((frameCount % REIT == 0) && (this.running)) 
        v.giveStep();
    }
    return null;
  }

  void draw() {
    fill(backgrounds[(this.isAttention)?0:1]);
    rect(this.pathStart, this.pathHeight-this.pathAltitude/2, this.pathLength, this.pathAltitude);
    if (! this.running) {
      pushStyle();
      stroke(255,0,0);
      strokeWeight(5);
      line(this.pathStart, this.pathHeight-this.pathAltitude/2, this.pathStart, this.pathHeight);
      line(this.pathStart, this.pathHeight, this.pathStart+this.pathAltitude, this.pathHeight-this.pathAltitude/2);
      popStyle();
    }
    for (Vehicle v : this.queue) {
      v.draw();
    }
  }

  String toString() {
    String res = "";
    for ( boolean b : this.types ) res += b + ", ";
    return res;
  }
}

class Deal {
  int lineNum;
  Vehicle vehicle;
  Deal(int n, Vehicle v) {
    this.lineNum = n;
    this.vehicle = v;
  }
}

class RTV {
  int numLines;
  ArrayList<Line> attentionLines;
  ArrayList<Line> waitLines;
  ArrayList<Deal> deals;
  float posX, posY;
  float allHeight, allWidth;
  float lineHeight;
  boolean dealing;

  RTV(int numLines) {
    this.dealing = false;
    this.numLines = numLines;
    this.deals = new ArrayList<Deal>();
    this.attentionLines = new ArrayList<Line>(this.numLines);
    this.waitLines = new ArrayList<Line>(this.numLines);
    this.posX = width*0.35;
    this.posY = height*0.1;
    this.allHeight = height*0.6;
    this.allWidth = width*0.6;
    this.lineHeight = this.allHeight / this.numLines;
    for ( int i = 0; i < numLines; i++ ) {
      boolean[] types = {true, true, true, true, true, true, true};
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
        this.attend(this.waitLines.indexOf(l), v);
      }
    }
    for ( Line l : this.attentionLines ) {
      Vehicle v = l.update();
      if (v != null) {
        l.queue.remove(v);
      }
    }
    if (frameCount % (REIT*2) == 0) {
      boolean[] dealt = new boolean[this.attentionLines.size()];
      ArrayList<Integer> remove = new ArrayList<Integer>();
      for (Deal d : this.deals ) {
        if ( dealt[d.lineNum] ) continue;
        dealt[d.lineNum] = true;
        ctrl.rtv.hold(d.lineNum, d.vehicle);
        remove.add(this.deals.indexOf(d));
      }
      ArrayList<Deal> tmp = new ArrayList(this.deals);
      for (Integer r : remove) {
        Deal d = tmp.get(r);
        this.deals.remove(d);
        street.pending.remove(d.vehicle);
      };
    }
    if (this.deals.size() == 0) this.dealing = false;
  }

  void draw() {    

    pushMatrix();
    pushStyle();
    translate(this.posX, this.posY);

    this.drawHold();
    this.drawAttention();

    strokeCap(SQUARE);
    strokeWeight(5);
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

class Street {
  ArrayList<Vehicle> pending;
  float startX, startY;
  Street() {
    this.pending = new ArrayList<Vehicle>();
    this.startX = width*0.02;
    this.startY = height*0.4;
  }

  void addVehicle(int type) {
    Vehicle v;
    switch (type) {
    case 0:
      v = new MotoNueva();
      break;
    case 1:
      v = new MotoVieja();
      break;
    case 2:
      v = new SedanNuevo();
      break;
    case 3:
      v = new SedanViejo();
      break;
    case 4:
      v = new Bus();
      break;
    case 5:
      v = new CamionDosEjes();
      break;
    default:
      v = new CamionCincoEjes();
      break;
    }
    pending.add(v);
  }

  void draw() {
    pushStyle();
    fill(50);
    strokeWeight(3);
    if (ctrl.rtv.dealing) stroke(255, 0, 0);
    rect(startX, startY, width*0.25, height*0.3);
    popStyle();
    for (Vehicle v : pending) {
      float x = this.startX+40+(50*(int(pending.indexOf(v)/5)));
      float y = this.startY+20+((pending.indexOf(v)%5)*50);
      v.setPos(x, y);
      v.draw();
    }
  }
}
