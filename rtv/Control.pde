class Control {
  String typeCtrl = "qwertyu";
  float[] lineHeights;
  int selected;
  RTV rtv;
  Vehicle[] muestrario = {
    //new Vehicle(30), 
    new MotoVieja(), 
    new MotoNueva(), 
    new SedanViejo(), 
    new SedanNuevo(), 
    new Bus(), 
    new CamionDosEjes(), 
    new CamionCincoEjes()
  };

  Control(RTV rtv) {
    this.rtv = rtv;
    this.selected = 0;
    this.lineHeights = new float[rtv.attentionLines.size()];
    for ( Line l : rtv.attentionLines ) this.lineHeights[rtv.attentionLines.indexOf(l)] = l.pathHeight + rtv.posY;

    for ( int i = 0; i < muestrario.length; i++ ) {
      float altura = 50+(i*25);
      muestrario[i].setPos(50, altura);
      muestrario[i].showTicker = false;
      //text(muestrario[i].getClass().getName()+": "+muestrario[i].duration, 60, altura+5);
    }
  }

  void selectUp() {
    if (this.selected == 0 ) {
      this.selected = this.lineHeights.length-1;
    } else {
      this.selected = (selected-1) % this.lineHeights.length;
    };
  }

  void selectDown() {
    this.selected = (selected+1) % this.lineHeights.length;
  }

  void draw() {
    // Arrow
    pushStyle();
    float center = lineHeights[selected];
    stroke(255, 255, 1);
    strokeWeight(5);
    line(width*0.96, center, width*0.97, center-10);
    line(width*0.96, center, width*0.99, center);
    line(width*0.96, center, width*0.97, center+10);
    popStyle();

    // ShowCase
    pushStyle();
    for ( int i = 0; i < this.muestrario.length; i++ ) {
      float altura = 50+(i*25);
      text(this.muestrario[i].duration, 80, altura+5);
      this.muestrario[i].draw();
      pushStyle();
      if ( this.rtv.attentionLines.get(this.selected).types[i] ) {
        noStroke();
        fill(255, 0, 0);
        ellipse(120, altura, 5, 5);
      }
      noFill();
      stroke(0);
      rect(110, altura-10, 20, 20);
      fill(0);
      text(typeCtrl.split("")[i], 140, altura+5);
      popStyle();
    }
    popStyle();
  }
}
