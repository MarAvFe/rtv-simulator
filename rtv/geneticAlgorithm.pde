class geneticAlgorithm {
  static final int carTypePenalty = 7;
  static final int timePenalty = 3;
  
  ArrayList<boolean[]> linesTypes;
  ArrayList<Integer> linesCapacity;
  ArrayList<Vehicle> vehicles;
  
  ArrayList<cromosome> generation;
  
  geneticAlgorithm(ArrayList<Line> lines, ArrayList<Vehicle> vehicles){
    for(Line line:lines){
        this.linesTypes.add(line.types);
        this.linesCapacity.add(line.capacity);
    }
    this.vehicles = vehicles;
  } 
  
  void randomizeGeneration() {
    for(int i=0; i<100; i++){
       int[] representation = new int[this.vehicles.size()]; 
       for(int k=0; k<this.vehicles.size(); k++){
         representation[k] = int(random(this.linesCapacity.size()));
       }
       this.generation.add(new cromosome(representation, calculateFitness(representation)));
    }
  }
  
  int calculateFitness(int[] representation){
    int fitness = 0;
    int[] costPerLine = calculateLineCost(representation);
    for(int i= 0; i<this.linesCapacity.size(); i++){
      if(costPerLine[i]> this.linesCapacity.get(i)){
        fitness+=timePenalty;
      }
    }
    
    for(int k=0; k<this.vehicles.size(); k++){
      if(!validVehicle(this.vehicles.get(k), representation[k])){
        fitness+=carTypePenalty;
      }
    }
    return fitness;
  }
  
  boolean validVehicle(Vehicle vehicle, int typesIndex){
    if(vehicle instanceof MotoVieja){
      return linesTypes.get(typesIndex)[0];
    }
    if(vehicle instanceof MotoNueva){
      return linesTypes.get(typesIndex)[1];
    }
    if(vehicle instanceof SedanViejo){
      return linesTypes.get(typesIndex)[2];
    }
    if(vehicle instanceof SedanNuevo){
      return linesTypes.get(typesIndex)[3];
    }
    if(vehicle instanceof Bus){
      return linesTypes.get(typesIndex)[4];
    }
    if(vehicle instanceof CamionDosEjes){
      return linesTypes.get(typesIndex)[5];
    }
    if(vehicle instanceof CamionCincoEjes){
      return linesTypes.get(typesIndex)[6];
    }
    return false;
  }
  
  
  int[] calculateLineCost(int[] representation){
      int[] costPerLine = new int[this.linesCapacity.size()];
      for(int i=0; i< this.vehicles.size(); i++){
        int line = representation[i];
        costPerLine[line] += this.vehicles.get(i).timeLeft;
      }
      return costPerLine;
  }
  class cromosome {
    int[] representation; // cromosoma = [idLine, idLine, idLine....lenVehicle]
    int fitness;
    
    cromosome(int[] representation, int fitness){
      this.representation = representation;
      this.fitness = fitness;
    }
    
  }
}
