int xPos;                        
int timer = 0;
color[] backgrounds = { color(100), color(104, 135, 36) };
color[] vehicleBackgrounds = {color(118, 70, 25), color(46, 206, 219), color(255), color(35,155,190), color(150,25,190), color(255,255,0), color(255,0,0), color(255,128,0), color(130,65,74), color(200), color(90)};
int[] win = {1440, 800};
float[] sizeRTV = { width * 0.2, height * 0.6 };
RTV rtv;
Street street;
Control ctrl;
int REIT = 10;
GeneticAlgorithm solver;
int numLines;
boolean initialized;
boolean view;

void setup()                   
{
  size (1440, 800);
  smooth(4);
  xPos = width / 2;                
  fill(0, 255, 0);       
  street = new Street();
  view = false;
  numLines = 6;
  initialized = false;
  frameRate(REIT);
}

void draw() {
  textSize(15);
  background (100,70,25);
  text("Leyenda: "+timer, 10, 20);

  if (! initialized){
    pushStyle();
    background(0);
    textSize(width*0.05);
    text("How many lines?", width*0.3, height*0.2);
    textSize(200);
    text(numLines,width*0.45,height*0.60);
    strokeWeight(15);
    stroke(0,255,0);
    line(width*0.3,height/2,width*0.33,height/2-height*0.05);
    line(width*0.3,height/2,width*0.4,height/2);
    line(width*0.3,height/2,width*0.33,height/2+height*0.05);
    
    line(width*0.7,height/2,width*0.67,height/2-height*0.05);
    line(width*0.7,height/2,width*0.6,height/2);
    line(width*0.7,height/2,width*0.67,height/2+height*0.05);
    
    noFill();
    rect(width*0.39,height*0.75,width*0.2,height*0.15);
    textSize(85);
    text("ENTER",width*0.40,height*0.87);
    popStyle();
    return;
  };

  ctrl.rtv.draw();
  street.draw();
  ctrl.draw();
  
  if (frameCount % REIT == 0) {
    timer+=1;
  }
  ctrl.rtv.update();
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      ctrl.selectUp();
    }
    if (keyCode == DOWN) {
      ctrl.selectDown();
    }
    if (keyCode == RIGHT) {
      if (! initialized) {
        numLines++;
        return;
      }
      ctrl.rtv.attentionLines.get(ctrl.selected).increaseCapacity();
    }
    if (keyCode == LEFT) {
      if (! initialized) {
        if (numLines > 1) numLines--;
        return;
      }
      ctrl.rtv.attentionLines.get(ctrl.selected).decreaseCapacity();
    }
  } else if (key == 's') {
    println("random solver");
    solver = new GeneticAlgorithm(randomLines(), randomVehicles());
    solver.solve();
  } else if (key == 'f') {  // delete from queue
    ctrl.rtv.attentionLines.get(ctrl.selected).dequeue();
  } else if (key == 'v') {  // view lookahead
    view = !view;
  } else if (keyCode == 27) {  // ESCAPE key
    exit();
  } else if (keyCode == 10) {  // ENTER key
    if (! initialized) {
      ctrl = new Control(new RTV(numLines));
      initialized = true;
    }
  } else if (key == 'p') {  // pause line
    ctrl.rtv.attentionLines.get(ctrl.selected).running = ! ctrl.rtv.attentionLines.get(ctrl.selected).running;
  } else if (key == 'x') {  // reboot
    initialized = false;
  } else if (keyCode == 127) {  // DEL key
    street.pending.remove(street.pending.get(street.pending.size()-1));
  } else if (key == 'd') {
    if (ctrl.rtv.dealing) return;
    solver = new GeneticAlgorithm(ctrl.rtv.attentionLines, street.pending);
    int[] solution = solver.solve();
    assert solution.length == street.pending.size();
    int idx;
    for (Vehicle v : street.pending){
      idx = street.pending.indexOf(v);
      ctrl.rtv.deals.add(new Deal(solution[idx], v));
    }
    ctrl.rtv.dealing = true;
  } else if ("1234567".indexOf(key) > -1) {
    String[] splitted = split(key+"", "\n");
    street.addVehicle(int(splitted[0])-1);
  } else if (ctrl.typeCtrl.indexOf(key) > -1) {
    int idx = ctrl.typeCtrl.indexOf(key);
    ctrl.rtv.attentionLines.get(ctrl.selected).types[idx] = ! ctrl.rtv.attentionLines.get(ctrl.selected).types[idx];
  } else {
    println("Debug: " + key +", "+keyCode);
  }
}

ArrayList<Vehicle> randomVehicles() {
  ArrayList<Vehicle> queue = new ArrayList<Vehicle>();
  int queueSize = 10;
  for (int i = 0; i < queueSize; i++) {
    Vehicle v;
    int vehicleType = int(random(100)%6);
    switch (vehicleType) {
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
    queue.add(v);
  }
  return queue;
}

ArrayList<Line> randomLines() {
  ArrayList<Line> queue = new ArrayList<Line>();
  int numLines = 3;
  boolean[] types;
  Line l;
  for (int i = 0; i < numLines; i++) {
    types = new boolean[6];
    for (int k = 0; k < types.length; k++) types[k] = (random(100)>50) ? true : false;
    l = new Line(int(random(150, 400)), true, types, 0, 0, 0, 0);
    queue.add(l);
  }
  return queue;
}

boolean isVehicle(color c) {
  for (color cl : vehicleBackgrounds) {
    if (c == cl) return true;
  }
  return false;
}
