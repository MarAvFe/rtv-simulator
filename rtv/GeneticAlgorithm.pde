import java.util.Collections;
import java.util.Comparator;
import java.util.Arrays;

class GeneticAlgorithm {
  static final int carTypePenalty = 7;
  static final int timePenalty = 3;
  static final int pausedLinePenalty = 11;
  static final int lazyLinePenalty = 2;
  static final int cromosomesPerGeneration = 100;
  static final int maxGenerations = 1000;
  
  ArrayList<boolean[]> linesTypes;
  ArrayList<Integer> linesCapacity;
  ArrayList<Boolean> linesRunning;
  ArrayList<Vehicle> vehicles;
  
  ArrayList<Cromosome> generation = new ArrayList<Cromosome>();
  
  GeneticAlgorithm(ArrayList<Line> lines, ArrayList<Vehicle> vehicles){
    this.linesTypes = new ArrayList<boolean[]>();
    this.linesCapacity = new ArrayList<Integer>();
    this.linesRunning = new ArrayList<Boolean>();
    for(Line line:lines){
        this.linesTypes.add(line.types);
        this.linesCapacity.add(line.capacity);
        this.linesRunning.add(line.running);
        String tipos = "";
        for (boolean b : this.linesTypes.get(this.linesTypes.indexOf(line.types))) tipos += (b)?"true, ":"false, ";
        //println(lines.indexOf(line)+"("+line.capacity+"):"+tipos);
    }
    this.vehicles = vehicles;
    //for(Vehicle vehicle : vehicles){
    //  println(vehicle.getClass().getSimpleName());
    //}
    //println(vehicles.size());
  } 
  
  void initGeneration() {
    for(int i=0; i<cromosomesPerGeneration; i++){
       int[] representation = new int[this.vehicles.size()]; 
       for(int k=0; k<this.vehicles.size(); k++){
         representation[k] = int(random(this.linesCapacity.size()));
       }
       this.generation.add(new Cromosome(representation, calculateFitness(representation)));
    }
  }
  
  int[] solve(){
    initGeneration();
    int currentGeneration = 0;
    while(currentGeneration< maxGenerations && this.generation.get(0).fitness!= 0){
      //println(currentGeneration);
      produceGeneration();
      currentGeneration++;
    }
    println("Best fitness found -> " + this.generation.get(0).toString() + " on generation " + currentGeneration);
    return this.generation.get(0).representation;
  }
  ArrayList<Cromosome> randomizeGeneration(int quantity) {
    ArrayList<Cromosome> randomCromosomes = new ArrayList<Cromosome>();
     for(int i=0; i<quantity; i++){
       int[] representation = new int[this.vehicles.size()]; 
       for(int k=0; k<this.vehicles.size(); k++){
         representation[k] = int(random(this.linesCapacity.size()));
       }
       randomCromosomes.add(new Cromosome(representation, calculateFitness(representation)));
    }
    return randomCromosomes;
  }
  
  void produceGeneration(){
    Collections.sort(this.generation, new Comparator<Cromosome>(){
      public int compare(Cromosome a, Cromosome b){
        return a.fitness-b.fitness;
      }
    });
    ArrayList<Cromosome> newGeneration = new ArrayList<Cromosome>();
    for(int i=0; i<20; i++){
      newGeneration.add(this.generation.get(i));
    }
    Cromosome firstParent;
    Cromosome secondParent;
    for(int i=0; i<(cromosomesPerGeneration-30); i++){
      firstParent = this.generation.get(getRandomParent());
      secondParent = this.generation.get(getRandomParent());
      newGeneration.add(mate(firstParent, secondParent));
    }
    newGeneration.addAll(randomizeGeneration(10));
    //for(Cromosome cromosome: newGeneration){
    //     println(cromosome.toString());
    //}
    //println(newGeneration.get(0).toString());
    //println("------------------------------------------------------------------");
    this.generation = newGeneration;
  }
  
  Cromosome mate(Cromosome female, Cromosome male){
    int distribution = int(random(1, this.vehicles.size()));
    int[] femaleDNA = Arrays.copyOfRange(female.representation, 0, distribution);
    int[] maleDNA = Arrays.copyOfRange(male.representation, distribution, this.vehicles.size());
    int femaleLen = femaleDNA.length;
    int maleLen = maleDNA.length;
    int[] crossDNA = new int[femaleLen + maleLen];
    System.arraycopy(femaleDNA, 0, crossDNA, 0, femaleLen);
    System.arraycopy(maleDNA, 0, crossDNA, femaleLen, maleLen);    
    return new Cromosome(crossDNA, calculateFitness(crossDNA));
  }
  
  int getRandomParent(){
     if(random(1)>0.60){
       return int(random(10));
     }
     return int(random(10,100));
  }
  
  int calculateFitness(int[] representation){
    int fitness = 0;
    int[] costPerLine = calculateLineCost(representation);
    
    for(int i= 0; i<this.linesCapacity.size(); i++){
      //Add timePenalty per line that is overloaded
      if(costPerLine[i] > this.linesCapacity.get(i)){
        fitness+=timePenalty;
      }
      //add penalty whenever a line is below 50% capacity
      if(costPerLine[i] < Math.round(this.linesCapacity.get(i) * 0.5)){
        //println("lazy line capacity " + this.linesCapacity.get(i) + " actual load " + costPerLine[i]);
        fitness+=lazyLinePenalty;
      }
    }
    
    
    for(int k=0; k<this.vehicles.size(); k++){
      //add typePenalty per invalid vehicle in each line
      if(!validVehicle(this.vehicles.get(k), representation[k])){
        fitness+=carTypePenalty;
      }
      
      //add pena;ty if car was added to inactive line
      if(!this.linesRunning.get(representation[k])){
        fitness+= pausedLinePenalty;
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
  class Cromosome{
    int[] representation; // cromosoma = [idLine, idLine, idLine....lenVehicle]
    int fitness;
    
    Cromosome(int[] representation, int fitness){
      this.representation = representation;
      this.fitness = fitness;
    }
    
    String toString(){
      String chain = "";
      for(int line:this.representation){
        chain+=line;
      }
      return "Representation: " + chain + " \\n fitness: " + String.valueOf(this.fitness) + "\\n"; 
    }
    
  }
}
