// Library

import controlP5.*;
// Installation ControlP5 : Unzip and put the extracted controlP5 folder into the libraries folder of your processing sketches. Reference and examples are included in the controlP5 folder.
// Or goto "Sketch" >> "Import Library" >> "Manage Libraries" >> Search and Install...  

// Raw data tables & objects

// Graphics and UI variables
ControlP5 cp5;
Knob k_node;
Knob k_density;
Knob k_run;
Button rectButton;
DropdownList dropdown;
DropdownList dropdown_sol;

PanZoomMap panZoomMap;
PFont labelFont;
String highlightedMunicipality = "";
String selectedMunicipality = "Romanum";

// parameters for data sweeping      
int node = 11;
float density = 0.3;
int run_num = 3;

GraphImporter importer = new GraphImporter();
int[][] inputGraphArray = new int[64][64];
int[][] solution_qubo     = new int[10][64];
int[][] solution_cobi     = new int[10][64];

int[]   mapping_table = new int[64];    // To change the order of nodes by filtering information (such as the sum of edge weights or the sign bit of a solution).
// === PROCESSING BUILT-IN FUNCTIONS ===

void setup() {
  // size of the graphics window
  size(1920,1080);

  // these coordinates define a rectangular region for the map that happens to be
  // centered around Micronesia
  panZoomMap = new PanZoomMap(5.2, 138, 10.0, 163.1);
  
  // these initial values provide a good view of Chuuk Lagoon, but you can
  // comment these out to start with all of the data on the screen
  panZoomMap.scale = 87430.2;
  panZoomMap.translateX = -47255.832;
  panZoomMap.translateY = -43944.914;
  
  labelFont = loadFont("Futura-Medium-18.vlw");

  // Drop down menu
  cp5 = new ControlP5(this);
  k_node = cp5.addKnob("Node")
      .setPosition(50, 50)
      .setRange(3, 58)
      .setValue(11)
      .setDragDirection(Knob.HORIZONTAL)
      .setNumberOfTickMarks(14)
      .setDecimalPrecision(0);

  k_density = cp5.addKnob("Density")
      .setPosition(100, 50)
      .setRange(0.3, 0.9)
      .setValue(0.4)
      .setDragDirection(Knob.HORIZONTAL)
      .setNumberOfTickMarks(7)
      .setDecimalPrecision(1);

  k_run = cp5.addKnob("Run")
      .setPosition(150, 50)
      .setRange(1, 3)
      .setValue(2)
      .setDragDirection(Knob.HORIZONTAL)
      .setNumberOfTickMarks(3)
      .setDecimalPrecision(0);

  // Create a new DropdownList object
  dropdown = cp5.addDropdownList("Sort")
          .setPosition(50, 200)
          .setSize(150,150)
          ;


  // create button with a rectangular shape
  rectButton = cp5.addButton("Load Graph")
      .setPosition(50, 125)
      .setSize(100, 50);

  // add callback function for button
  rectButton.onClick(new CallbackListener() {
    public void controlEvent(CallbackEvent event) {
      buttonClicked();
    }
  });

  // Add three options to the dropdown menu
  dropdown.addItem("Sequential", 0);
  dropdown.addItem("Reverse",    1);
  dropdown.addItem("(T.B.D) By sum of edge wegits", 2);
  dropdown.addItem("(T.B.D) By spin values in solution #1", 3);
  dropdown.addItem("(T.B.D) By spin values in solution #2", 4);

  // Set the default value of the dropdown menu to the first option (A)
  dropdown.setValue(0);

  // Create a new DropdownList object for qubo solution
  dropdown_sol = cp5.addDropdownList("Select Solution")
      .setPosition(350, 200)
      .setSize(200,200)
      ;

  dropdown_sol.addItem("Select Solution : 0" , 0);
  // Set the default value of the dropdown menu to the first option (A)
  dropdown_sol.setValue(0);

  
  mapping_table = importer.node_mapping_by_name(mapping_table);

}


void draw() {
  // clear the screen
  background(230);

  node = (int) k_node.getValue();
  density = round(k_density.getValue()*10) / 10.0;
  run_num = (int) k_run.getValue();
  
  int solution_number = (int) dropdown_sol.getValue();

  // Execute different tasks based on the user's selection
  int node_sort = (int) dropdown.getValue();
  switch (node_sort) {
  case 0:
      // Execute task A
      System.out.println("\nSequential");
      mapping_table = importer.node_mapping_by_name(mapping_table);
      break;
  case 1:
      // Execute task B
      System.out.println("\nReverse");
      mapping_table = importer.node_mapping_by_reverse(mapping_table);
      break;
  case 2:
      // Execute task C
      System.out.println("\nBy weights");
      break;
  case 3:
      // Execute task C
      System.out.println("\nBy Solution #1");
      break;
  case 4:
      // Execute task C
      System.out.println("\nBy Solution #2");
      break;
      
  }

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

  
  /////////////////////////////////////////////////////////////////////////////////
  // Ising Problem 
  // Drawing Nodes
  draw_edges(0,0, 1);                  // mode 1
  draw_nodes(0,0, 1, solution_number); // mode 1

  /////////////////////////////////////////////////////////////////////////////////

  /////////////////////////////////////////////////////////////////////////////////
  // Solution #1
  // Drawing Nodes

  int offset_pr1 = importer.r*2 + 100;
  draw_edges(0+offset_pr1,0, 2);                   // mode 2
  draw_nodes(0+offset_pr1,0, 2,solution_number );  // mode 2


  /////////////////////////////////////////////////////////////////////////////////
  // Solution #2
  // Drawing Nodes

  int offset_pr2 = (importer.r*2 + 100) * 2;
  draw_edges(0+offset_pr2,0, 3);                   // mode 3
  draw_nodes(0+offset_pr2,0, 3, solution_number);  // mode 3

  
  /*     
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
    color c = lerpColorLab(lowestPopulationColor, highestPopulationColor, amt); //<>//
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

*/
// Returns the municipality currently under the mouse cursor so that it can be highlighted or selected
// with a mouse click.  If the municipalities overlap and more than one is under the cursor, the
// smallest municipality will be returned, since this is usually the hardest one to select.
String getMunicipalityUnderMouse() {
  // float smallestRadiusSquared = Float.MAX_VALUE;
  // String underMouse = "";
  // for (int i=0; i<locationTable.getRowCount(); i++) {
  //   TableRow rowData = locationTable.getRow(i);
  //   String municipality = rowData.getString("Municipality");
  //   float latitude = rowData.getFloat("Latitude");
  //   float longitude = rowData.getFloat("Longitude");
  //   float screenX = panZoomMap.longitudeToScreenX(longitude);
  //   float screenY = panZoomMap.latitudeToScreenY(latitude);
  //   float distSquared = (mouseX-screenX)*(mouseX-screenX) + (mouseY-screenY)*(mouseY-screenY);
  //   float radius = getRadius(municipality);
  //   float radiusSquared = constrain(radius*radius, 1, height);
  //   if ((distSquared <= radiusSquared) && (radiusSquared < smallestRadiusSquared)) {
  //     underMouse = municipality;
  //     smallestRadiusSquared = radiusSquared;
  //   }
  // }
  // return underMouse;
    return " ";
}



// === DATA PROCESSING ROUTINES ===

void buttonClicked() {
  // function to call when button is clicked
  String dataDir = sketchPath("");

  // Print the data directory to the console
  println("Sketch data directory: " + dataDir);
  String graph_folder = dataDir + "data/" + "N_" + String.format("%02d", node) + "__D_"+ Float.toString(density) + "__" + Integer.toString(run_num) + "/";

  println("Button clicked!");
  println("Data Folder: " + graph_folder);
  
  inputGraphArray = importer.importGraphWithViz(inputGraphArray, graph_folder + "dummy.txt");   // Problem
  solution_qubo   = importer.parse_qubo(solution_qubo, graph_folder + "1_solution_qubo.txt");   // Solution #1, has n solutions
  solution_cobi   = importer.parse_cobi(solution_cobi, graph_folder + "2_solution_cobi.txt");   // Solution #2, has 1 solution




  dropdown_sol.remove();
  // Create a new DropdownList object
  dropdown_sol = cp5.addDropdownList("Select Solution")
          .setPosition(350, 200)
          .setSize(150,150)
          ;

  for (int i = 0; i < importer.num_solutions; i++){
      // Add three options to the dropdown menu
      dropdown_sol.addItem("Select Solution : " + i, i);
  }
  // Set the default value of the dropdown menu to the first option (A)
  dropdown_sol.setValue(0);
  
}


void draw_nodes(float offset_x, float offset_y, int mode, int sol_num){
  float loc_x;
  float loc_y;

  float loc_tx;
  float loc_ty;

  int   qubo_solution_num = sol_num;
  
  for(int i = 1; i<= importer.num_node; i++){
      fill(0);
      int map_i = mapping_table[i];
      loc_x = importer.node_loc_arr[map_i].loc_x;
      loc_y = importer.node_loc_arr[map_i].loc_y;

      loc_tx = importer.node_loc_arr[map_i].txt_x;
      loc_ty = importer.node_loc_arr[map_i].txt_y;

      // update offset for drawing solution #1, #2
      loc_x = loc_x + offset_x;
      loc_y = loc_y + offset_y;

      loc_tx = loc_tx + offset_x;
      loc_ty = loc_ty + offset_y;

      // Node Drawing
      if(mode == 1) {
	  fill(0, 0, 0);   // Black
	  stroke(0);       // Black Line
	  strokeWeight(0); // 
	  ellipse(loc_x, loc_y , 25, 25);
      }
      else if(mode == 2) {
	  if(solution_qubo[qubo_solution_num][i] == -1) {
	      fill(255, 0, 0); // Red
	      stroke(0);       // Black Line
	      strokeWeight(0); // 
	      ellipse(loc_x, loc_y , 25, 25);
	  }
	  else if(solution_qubo[qubo_solution_num][i] == 1) {
	      fill(0, 0, 255); // Blue
	      stroke(0);       // Black Line
	      strokeWeight(0); // 
	      ellipse(loc_x, loc_y , 25, 25);
	  }
      }
      else if(mode == 3) {
	  if(solution_cobi[0][i] == -1) {
	      fill(255, 0, 0); // Red
	      if(solution_qubo[qubo_solution_num][i] != solution_cobi[0][i]) { // difference 
		  stroke(255,255,0);       // Yellow line
		  strokeWeight(10); 
	      }
	      else {
		  stroke(0);       // Black Line
		  strokeWeight(0); //
	      }
	      ellipse(loc_x, loc_y , 25, 25);
	  }
	  else if(solution_cobi[0][i] == 1) {
	      fill(0, 0, 255); // Blue
	      if(solution_qubo[qubo_solution_num][i] != solution_cobi[0][i]) { // difference 
		  stroke(255,255,0);       // Yellow line
		  strokeWeight(10); 
	      }
	      else {
		  stroke(0);       // Black Line
		  strokeWeight(0); //
	      }
	      ellipse(loc_x, loc_y , 25, 25);
	  }	  
      }
      

      // Text Drawing
      fill(0, 0, 0); // Black
      textSize(15); // 
      textAlign(CENTER, CENTER);
      if (i != 1)
	  text("N" + String.format("%02d", i), loc_tx, loc_ty);
      else
	  fill(255, 0, 0);
      	  text("N" + String.format("%02d", i), loc_tx, loc_ty);
  }
}


void draw_edges(float offset_x, float offset_y, int mode){
  float startWeight = 1;
  float endWeight = 5;
  color startColor = color(0, 0, 0);  

  color endColor_plus  = color(255, 0, 0);
  color endColor_minus = color(0, 0, 255);
  color lineColor = color(0, 0, 0);

  float loc_x_ni;
  float loc_y_ni;

  float loc_x_nj;
  float loc_y_nj;
	  
  // Drawing Edges
  for(int i = 1; i<= importer.num_node; i++){
      for(int j = 1; j < i; j++){
	  int pair_weight = inputGraphArray[i][j] + inputGraphArray[j][i];

	  int map_ni = mapping_table[i];
	  int map_nj = mapping_table[j];

	  loc_x_ni = importer.node_loc_arr[map_ni].loc_x;
	  loc_y_ni = importer.node_loc_arr[map_ni].loc_y;

	  loc_x_nj = importer.node_loc_arr[map_nj].loc_x;
	  loc_y_nj = importer.node_loc_arr[map_nj].loc_y;

	  // update offset for drawing solution #1, #2
	  loc_x_ni = loc_x_ni + offset_x;
	  loc_y_ni = loc_y_ni + offset_y;
		             
	  loc_x_nj = loc_x_nj + offset_x;
	  loc_y_nj = loc_y_nj + offset_y;

	  
	  // X-->X, Y-->Y
	  if (pair_weight != 0) {
	      if(mode == 1) {
		  float weightValue = abs(pair_weight)/14.0;
		  float weight = startWeight + weightValue * (endWeight - startWeight);
		  //color lineColor = pair_weight < 0 ? startColor : endColor;
		  if(pair_weight>0)
		      lineColor = lerpColor(startColor, endColor_plus, weightValue);
		  if(pair_weight<0)
		      lineColor = lerpColor(startColor, endColor_minus, weightValue);
		  strokeWeight(weight);
		  stroke(lineColor);
	      }
	      if(mode == 2) {
		  lineColor = color(200, 200, 200);
		  float weight = 1;
		  strokeWeight(weight);
		  stroke(lineColor);
	      }

	      if(mode == 3) {
		  lineColor = color(200, 200, 200);
		  float weight = 1;
		  strokeWeight(weight);
		  stroke(lineColor);
	      }
    
	      line(loc_x_ni, loc_y_ni,  loc_x_nj, loc_y_nj);
	  }
      }
  }
}
