int xPos;                        
int timer = 0;
color[] backgrounds = { color(100, 70, 70), color(104, 135, 36) };
color[] vehicleBackgrounds = {color(118, 70, 25), color(46, 206, 219), color(255) };
int[] win = {1440, 800};
float[] sizeRTV = { width * 0.2, height * 0.6 };
RTV rtv;
Street street;
int REIT = 10;
GeneticAlgorithm solver;

void setup()                   
{
  size (1440, 800);
  smooth(4);
  xPos = width / 2;                
  fill(0, 255, 0);               
  textSize(15);       
  street = new Street();
  rtv = new RTV(6);
  rtv.attend(2, new MotoNueva());
  rtv.attend(2, new MotoVieja());
  rtv.hold(5, new MotoVieja());
  rtv.hold(4, new MotoVieja());
  rtv.hold(4, new MotoNueva());
  rtv.attend(4, new Bus());
  rtv.hold(4, new SedanNuevo());
  Vehicle s = new SedanNuevo();
  rtv.hold(1, s);
  frameRate(REIT);
}

void draw() {
  background (100,70,25);
  text("Leyenda: "+timer, 10, 20);

  Vehicle[] muestrario = {
    new Vehicle(30), 
    new MotoVieja(), 
    new MotoNueva(), 
    new SedanViejo(), 
    new SedanNuevo(), 
    new Bus(), 
    new CamionDosEjes(), 
    new CamionCincoEjes()
  };
  for ( int i = 0; i < muestrario.length; i++ ) {
    float altura = 50+(i*25);
    muestrario[i].setPos(30, altura);
    muestrario[i].showTicker = false;
    text(muestrario[i].getClass().getName()+": "+muestrario[i].duration, 60, altura+5);
    muestrario[i].draw();
  }

  rtv.draw();
  street.draw();
  
  if (frameCount % REIT == 0) {
    timer+=1;
  }
  rtv.update();
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      println("up arrow");
    }
  } else if (key == 's') {
    println(solver);
    solver = new GeneticAlgorithm(randomLines(), randomVehicles());
  } else if ((key == '1') || (key == '2') || (key == '3') || (key == '4') || (key == '5') || (key == '6') || (key == '7')) {
    println(key);
    String[] splitted = split(key+"", "\n");
    street.addVehicle(int(splitted[0])-1);
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
