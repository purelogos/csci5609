/* CSci-5609 Assignment 2: Visualization of Paafu Kinship Ties for the Islands of Micronesia
*/

// === GLOBAL DATA VARIABLES ===

// Raw data tables & objects
Table locationTable;
Table populationTable;
PaafuDirections paafuDirections;

// Derived data: kinships based on Paafu directions
KinshipTies kinshipTies;

// Derived data: mins and maxes for each data variable
float minLatitude, maxLatitude;
float minLongitude, maxLongitude;
float minPop1980, maxPop1980;
float minPop1994, maxPop1994;
float minPop2000, maxPop2000;
float minPop2010, maxPop2010;
float minArea, maxArea;

// Graphics and UI variables
PanZoomMap panZoomMap;
PFont labelFont;
String highlightedMunicipality = "";
String selectedMunicipality = "Romanum";



// === PROCESSING BUILT-IN FUNCTIONS ===

void setup() {
  // size of the graphics window
  size(1600,900);

  String dataDir = sketchPath("");

  // Print the data directory to the console
  println("Sketch data directory: " + dataDir);
  
  GraphImporter importer = new GraphImporter();
  int[][] inputGraphArray = new int[64][64];
  int[][] solution_qubo     = new int[10][64];
  int[][] solution_cobi     = new int[10][64];
  
  // parameters for data sweeping      
  int node = 11;
  float density = 0.3;
  int run_num = 3; 
  String graph_folder = dataDir + "data/" + "N_" + Integer.toString(node) + "__D_"+ Float.toString(density) + "__" + Integer.toString(run_num) + "/";
  println("Data Folder: " + graph_folder);
  
  inputGraphArray = importer.importGraphWithViz(inputGraphArray, graph_folder + "dummy.txt");   // Problem
  solution_qubo   = importer.parse_qubo(solution_qubo, graph_folder + "1_solution_qubo.txt");   // Solution #1, has n solutions
  solution_cobi   = importer.parse_qubo(solution_cobi, graph_folder + "2_solution_cobi.txt");   // Solution #2, has 1 solution 

  
  /* 
  // load data in from disk
  loadRawDataTables();
  paafuDirections = new PaafuDirections();
  
 

  // compute derived data
  // combine the location and direction data to identify Paafu-style kinship ties
  kinshipTies = new KinshipTies(paafuDirections, locationTable);

  // do any other data processing, e.g., finding mins and maxes for data variables
  computeDerivedData();
  
  // these coordinates define a rectangular region for the map that happens to be
  // centered around Micronesia
  panZoomMap = new PanZoomMap(5.2, 138, 10.0, 163.1);
  
  // these initial values provide a good view of Chuuk Lagoon, but you can
  // comment these out to start with all of the data on the screen
  panZoomMap.scale = 87430.2;
  panZoomMap.translateX = -47255.832;
  panZoomMap.translateY = -43944.914;
  
  labelFont = loadFont("Futura-Medium-18.vlw");
  */
  

}


void draw() {
  // clear the screen
  background(230);
  
  /*
  // Municipalities should highlight (i.e., change appearance in some way) whenever the mouse is hovering
  // over them so the user knows something will happen if they click.  If they do click while a municipality
  // is highlighted, then that municipality becomes the selectedMunicipality and the visualization should
  // update to show kinship relationships for it.
  highlightedMunicipality = getMunicipalityUnderMouse();
  
  // draw the bounds of the map
  fill(250);
  stroke(111, 87, 0);
  rectMode(CORNERS);
  float mapX1 = panZoomMap.longitudeToScreenX(138.0);
  float mapY1 = panZoomMap.latitudeToScreenY(5.2);
  float mapX2 = panZoomMap.longitudeToScreenX(163.1);
  float mapY2 = panZoomMap.latitudeToScreenY(10.0);
  rect(mapX1, mapY1, mapX2, mapY2);
  
     
  // Example Solution to Assignment 1
     
  // defined in screen space, so the circles will be the same size regardless of zoom level
  float minRadius = 3;
  float maxRadius = 28;
  
  color lowestPopulationColor = color(255, 224, 121);
  color highestPopulationColor = color(232, 81, 21);
  
  for (int i=0; i<locationTable.getRowCount(); i++) {
    TableRow rowData = locationTable.getRow(i);
    String municipalityName = rowData.getString("Municipality");
    float latitude = rowData.getFloat("Latitude");
    float longitude = rowData.getFloat("Longitude");
    float screenX = panZoomMap.longitudeToScreenX(longitude);
    float screenY = panZoomMap.latitudeToScreenY(latitude);
    
    // lat,long code above is the same as part A.  if we also get the municipality name
    // for this row in the location table, then we can look up population data for the
    // municipality in the population table
    TableRow popRow = populationTable.findRow(municipalityName, "Municipality");
    int pop2010 = popRow.getInt("Population 2010 Census");
    int area = popRow.getInt("Area");

    // normalize data values to a 0..1 range
    float pop2010_01 = (pop2010 - minPop2010) / (maxPop2010 - minPop2010);
    float area_01 = (area - minArea) / (maxArea - minArea);
    
    // two examples using lerp*() to map the data values to changes in visual attributes
    
    // 1. adjust the radius of the island in proportion to its area
    float radius = lerp(minRadius, maxRadius, area_01);

    // Part A: Add Highlight
    if(highlightedMunicipality == municipalityName){
      radius = radius * 2.0;
    }
    // 2. adjust the fill color in proportion to the population
    color c = lerpColorLab(lowestPopulationColor, highestPopulationColor, pop2010_01);
    fill(c);
    
    noStroke();
    ellipseMode(RADIUS);
    circle(screenX, screenY, radius);
    
    textAlign(LEFT, CENTER);
    float xTextOffset = radius + 4; // move the text to the right of the circle
    if(highlightedMunicipality == municipalityName){
      fill(215,48,31);
    }
    else {
      fill(111,87,0);
    }
    text(municipalityName, screenX + xTextOffset, screenY);
  }
  
	// Part B : Draw Kinship Ties as Lines Connecting Municipalities
		fill(250);
		stroke(111, 87, 0);


    if (selectedMunicipality != "") {
      // PART B : Draw Kinship Ties as Lines Connecting Municipalities
      HashMap<String, ArrayList<String>> kinshipTiesByDirection = kinshipTies.getKinshipTies(selectedMunicipality);
      for (String paafuDirection : kinshipTiesByDirection.keySet()) {
        ArrayList<String> municipalityList = kinshipTiesByDirection.get(paafuDirection);
        if (municipalityList.size() > 0) {
						//println("From " + selectedMunicipality + " in direction " + paafuDirection + ":");
      
          for (String municipality2 : municipalityList) {
							//println("  " + municipality2);
      
            TableRow srcRow = locationTable.findRow(selectedMunicipality, "Municipality");
            TableRow desRow = locationTable.findRow(municipality2,        "Municipality");
      
            float latitude_src = srcRow.getFloat("Latitude");
            float latitude_des = desRow.getFloat("Latitude");
      
            float longitude_src = srcRow.getFloat("Longitude");
            float longitude_des = desRow.getFloat("Longitude");
      
            float screenX_src = panZoomMap.longitudeToScreenX(longitude_src);
            float screenX_des = panZoomMap.longitudeToScreenX(longitude_des);
            
            float screenY_src = panZoomMap.latitudeToScreenY(latitude_src);
            float screenY_des = panZoomMap.latitudeToScreenY(latitude_des);         

						float minStroke = 0.1;
						float maxStroke = 16;
						float kinship_size_01 = float((municipalityList.size())) / float(locationTable.getRowCount());
						
						float lerp_Stroke = lerp(minStroke, maxStroke, kinship_size_01);

						//println("municipalityList" + municipalityList.size() + " locationTable" + locationTable.getRowCount() + "kinship_size_01" + kinship_size_01 + "lerp_Stroke" + lerp_Stroke );
						
						strokeWeight(lerp_Stroke);
						line(screenX_src, screenY_src, screenX_des, screenY_des);
          }
      
        }
      }
    }
    
	
  // DRAW THE LEGEND
  
  // block off the right side of the screen with a big rect
  fill(250);
  stroke(111, 87, 0);
  rect(1400, -10, 1610, 910);

  // colormap legend
  fill(111, 87, 0);
  textAlign(CENTER, CENTER);
  text("2010 Population", 1500, 50);

  strokeWeight(1);
  textAlign(RIGHT, CENTER);
  int gradientHeight = 200;
  int gradientWidth = 40;
  int labelStep = gradientHeight / 5;
  for (int y=0; y<gradientHeight; y++) {
    float amt = 1.0 - (float)y/(gradientHeight-1);
    color c = lerpColorLab(lowestPopulationColor, highestPopulationColor, amt);
    stroke(c);
    line(1500, 70 + y, 1500+gradientWidth, 70 + y);
    if ((y % labelStep == 0) || (y == gradientHeight-1)) {
      int labelValue = (int)(minPop2010 + amt*(maxPop2010 - minPop2010));
      text(labelValue, 1490, 70 + y);
    }
  }
             //<>//
  // circle size legend
  fill(111, 87, 0);
  textAlign(CENTER, CENTER);
  text("Municipality Area", 1500, 300);

  noStroke();
  textAlign(RIGHT, CENTER);
  int nExamples = 6;
  float y = 340;
  for (int i=0; i<nExamples; i++) {
    float amt = 1.0 - (float)i/(nExamples - 1);
    float radius = lerp(minRadius, maxRadius, amt);
    
    ellipseMode(RADIUS);
    circle(1500 + radius, y, radius);
    int labelValue = (int)(minArea + amt*(maxArea - minArea));
    text(labelValue, 1490, y);
    y += 2 * radius;//maxIslandRadius;
  }
  
  */
}




/*
void keyPressed() {
  if (key == ' ') {
    println("current scale: ", panZoomMap.scale, " current translation: ", panZoomMap.translateX, "x", panZoomMap.translateY);
  }
}

void mousePressed() {
  if (highlightedMunicipality != "") {
    selectedMunicipality = highlightedMunicipality;
    println("Selected: " + selectedMunicipality);

  }
  panZoomMap.mousePressed();
}


void mouseDragged() {
  panZoomMap.mouseDragged();
}


void mouseWheel(MouseEvent e) {
  panZoomMap.mouseWheel(e);
}


// === SOME HELPER ROUTINES FOR EASIER ACCESS TO FREQUENTLY NEEDED DATA IN THE TABLES ===

float getLatitude(String municipalityName) {
  TableRow r = locationTable.findRow(municipalityName, "Municipality");
  return r.getFloat("Latitude");
}

float getLongitude(String municipalityName) {
  TableRow r = locationTable.findRow(municipalityName, "Municipality");
  return r.getFloat("Longitude");
}

float getArea01(String municipalityName) {
  TableRow popRow = populationTable.findRow(municipalityName, "Municipality");
  int area = popRow.getInt("Area");
  float area_01 = (area - minArea) / (maxArea - minArea);
  return area_01;
}

// TODO: Update this based on your own radius calculation to make sure that the mouse selection
// routines work
float getRadius(String municipalityName) {
  float minRadius = 3;
  float maxRadius = 28;
  float amt = getArea01(municipalityName);
  return lerp(minRadius, maxRadius, amt);
}

// Returns the municipality currently under the mouse cursor so that it can be highlighted or selected
// with a mouse click.  If the municipalities overlap and more than one is under the cursor, the
// smallest municipality will be returned, since this is usually the hardest one to select.
String getMunicipalityUnderMouse() {
  float smallestRadiusSquared = Float.MAX_VALUE;
  String underMouse = "";
  for (int i=0; i<locationTable.getRowCount(); i++) {
    TableRow rowData = locationTable.getRow(i);
    String municipality = rowData.getString("Municipality");
    float latitude = rowData.getFloat("Latitude");
    float longitude = rowData.getFloat("Longitude");
    float screenX = panZoomMap.longitudeToScreenX(longitude);
    float screenY = panZoomMap.latitudeToScreenY(latitude);
    float distSquared = (mouseX-screenX)*(mouseX-screenX) + (mouseY-screenY)*(mouseY-screenY);
    float radius = getRadius(municipality);
    float radiusSquared = constrain(radius*radius, 1, height);
    if ((distSquared <= radiusSquared) && (radiusSquared < smallestRadiusSquared)) {
      underMouse = municipality;
      smallestRadiusSquared = radiusSquared;
    }
  }
  return underMouse;  
}



// === DATA PROCESSING ROUTINES ===

void loadRawDataTables() {
  locationTable = loadTable("FSM-municipality-locations.csv", "header");
  println("Location table:", locationTable.getRowCount(), "x", locationTable.getColumnCount()); 
  
  populationTable = loadTable("FSM-municipality-populations.csv", "header");
  println("Population table:", populationTable.getRowCount(), "x", populationTable.getColumnCount()); 
}


void computeDerivedData() {
  // lookup min/max data ranges for the variables we will want to depict
  minLatitude = TableUtils.findMinFloatInColumn(locationTable, "Latitude");
  maxLatitude = TableUtils.findMaxFloatInColumn(locationTable, "Latitude");
  println("Latitude range:", minLatitude, "to", maxLatitude);

  minLongitude = TableUtils.findMinFloatInColumn(locationTable, "Longitude");
  maxLongitude = TableUtils.findMaxFloatInColumn(locationTable, "Longitude");
  println("Longitude range:", minLongitude, "to", maxLongitude);

  minPop1980 = TableUtils.findMinFloatInColumn(populationTable, "Population 1980 Census");
  maxPop1980 = TableUtils.findMaxFloatInColumn(populationTable, "Population 1980 Census");
  println("Pop 1980 range:", minPop1980, "to", maxPop1980);
  
  minPop1994 = TableUtils.findMinFloatInColumn(populationTable, "Population 1994 Census");
  maxPop1994 = TableUtils.findMaxFloatInColumn(populationTable, "Population 1994 Census");
  println("Pop 1994 range:", minPop1994, "to", maxPop1994);

  minPop2000 = TableUtils.findMinFloatInColumn(populationTable, "Population 2000 Census");
  maxPop2000 = TableUtils.findMaxFloatInColumn(populationTable, "Population 2000 Census");
  println("Pop 2000 range:", minPop2000, "to", maxPop2000);

  minPop2010 = TableUtils.findMinFloatInColumn(populationTable, "Population 2010 Census");
  maxPop2010 = TableUtils.findMaxFloatInColumn(populationTable, "Population 2010 Census");
  println("Pop 2010 range:", minPop2010, "to", maxPop2010);

  minArea = TableUtils.findMinFloatInColumn(populationTable, "Area");
  maxArea = TableUtils.findMaxFloatInColumn(populationTable, "Area");
  println("Area range:", minArea, "to", maxArea);
 
}
*/
