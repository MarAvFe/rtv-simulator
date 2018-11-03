int xPos;                        
int timer = 0;
color[] backgrounds = { color(100,70,70), color(104, 135, 36) };
color[] vehicleBackgrounds = {color(118, 70, 25), color(46, 206, 219), color(0) };
int[] win = {1440, 800};
float[] sizeRTV = {win[0]*0.2, win[1]*0.6};
RTV rtv;
int REIT = 50;

void setup()                   
{
  size (1440, 800);
  //smooth(4);
  xPos = width/2;                
  fill(0, 255, 0);               
  textSize(15);                
  rtv = new RTV(6);
  rtv.attend(2, new MotoNueva());
  rtv.attend(2, new MotoVieja());
  rtv.hold(5, new MotoVieja());
  rtv.hold(4, new MotoVieja());
  rtv.hold(4, new MotoNueva());
  Vehicle s = new SedanNuevo();
  rtv.hold(1,s);
  frameRate(REIT);
}

void draw() {
  background (100);
  text("Leyenda: "+timer, 10, 20);
  if(frameCount % REIT == 0) timer+=1;

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

  rtv.update();
  rtv.draw();
}

boolean isVehicle(color c) {
  for(color cl : vehicleBackgrounds) {
    if (c == cl) return true;
  }
  return false;
}
