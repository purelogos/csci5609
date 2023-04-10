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

int[] ham_qubo     = new int[10];
int[] ham_cobi     = new int[10];

int[]   mapping_table = new int[64];    // To change the order of nodes by filtering information (such as the sum of edge weights or the sign bit of a solution).

int[][] flag_mouse_over         = new int[4][64];
int[][] flag_mouse_click        = new int[4][64];
int[][] flag_mouse_click_right  = new int[4][64];
int[][] flag_mouse_double_click = new int[4][64];


// Distance between each graph
int offset_pr1 = 640; // importer.r*2 + 100;
int offset_pr2 = 1280; //(importer.r*2 + 100) * 2;
float node_radius = 25;
// === PROCESSING BUILT-IN FUNCTIONS ===
int solution_number = 0;
int node_sort = 0; 

int last_clicked_node = 0;
int last_clicked_node_pre = 0;
int mouse_over_node = 0;

void setup() {
  // size of the graphics window
  size(1920,1080);


  fill(111, 87, 0);
  textAlign(CENTER, CENTER);
  text("Data Loader", 50, 50);



  
  // Drop down menu
  cp5 = new ControlP5(this);
  k_node = cp5.addKnob("Node")
      .setPosition(50, 50)
      .setRange(3, 58)
      .setValue(13)
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

  k_node.getCaptionLabel().setColor(0);
  k_density.getCaptionLabel().setColor(0);
  k_run.getCaptionLabel().setColor(0);

  k_node.getCaptionLabel().setFont(createFont("Arial", 12, true));
  k_density.getCaptionLabel().setFont(createFont("Arial", 12, true));
  k_run.getCaptionLabel().setFont(createFont("Arial", 12, true));
  
  // Create a new DropdownList object
  dropdown = cp5.addDropdownList("Sort")
          .setPosition(240, 55)
          .setSize(150,150)
          ;

  //dropdown.setFont(createFont("Arial", 10));

  // create button with a rectangular shape
  rectButton = cp5.addButton("Load Graph")
      .setPosition(70, 160)
      .setSize(100, 50);

  // add callback function for button
  rectButton.onClick(new CallbackListener() {
    public void controlEvent(CallbackEvent event) {
      buttonClicked();
    }
  });

  // Add three options to the dropdown menu
  dropdown.addItem("Sort by Sequential", 0);
  dropdown.addItem("Reverse",    1);
  dropdown.addItem("Sort by Edge Weight Sum", 2);
  dropdown.addItem("Sort by Edge Weight Sum ABS", 3);
  dropdown.addItem("By spin values in solution #1", 4);
  dropdown.addItem("By spin values in solution #2", 5);
  dropdown.addItem("Hamiltonian impact if single node flipped", 6);

  // Set the default value of the dropdown menu to the first option (A)
  dropdown.setValue(0);

  // Create a new DropdownList object for qubo solution
  dropdown_sol = cp5.addDropdownList("Select Solution")
      .setPosition(width/3+20, 180)
      .setSize(150,150)
      ;

  dropdown_sol.addItem("Select Solution : 0" , 0);
  // Set the default value of the dropdown menu to the first option (A)
  dropdown_sol.setValue(0);

  
  mapping_table = importer.node_mapping_by_name(mapping_table);

  for (int i = 0; i < 4; i++){
      for (int j = 1; j < 64; j++){
	  flag_mouse_over[i][j] = 0;         
	  flag_mouse_click[i][j] = 0;        
	  flag_mouse_click_right[i][j] = 0;        
	  flag_mouse_double_click[i][j] =0;
	  mapping_table[j] = j;
      }
  }

}


void draw() {
  // clear the screen
  background(230);

  node = (int) k_node.getValue();
  density = round(k_density.getValue()*10) / 10.0;
  run_num = (int) k_run.getValue();
  
  solution_number = (int) dropdown_sol.getValue();

  // data probe
  fill(0);
  stroke(111, 87, 0);
  textSize(20);
  textAlign(LEFT, BOTTOM);
  //text("Ising Problem : " + mouseX + "," + mouseY,  mouseX, mouseY);


  // First Pannel
  fill(255);
  stroke(0);       
  strokeWeight(0); 
  rect(0,0, width, 280);

  // Problem Pannel title
  fill(245);
  stroke(0);       // Black Line
  strokeWeight(0); //
  rect(0,260, width/3, 20);
  rect(0,280, width/3, 20);
  
  // Solution1 Pannel title
  fill(245);
  stroke(0);       // Black Line
  strokeWeight(0); //
  rect(width/3,260, width/3, 20);
  rect(width/3,280, width/3, 20);
  
  // Solution1 Pannel title
  fill(245);
  stroke(0);       // Black Line
  strokeWeight(0); //
  rect(width*2/3,260, width/3, 20);
  rect(width*2/3,280, width/3, 20);

  // Problem Pannel 
  fill(250);
  stroke(0);       // Black Line
  strokeWeight(0); //
  rect(0,300,       width/3, height-300);

  // Solution1 Pannel 
  fill(250);
  stroke(0);       // Black Line
  strokeWeight(0); //
  rect(width/3,300, width/3, height-300);

  // Solution1 Pannel 
  fill(250);
  stroke(0);       // Black Line
  strokeWeight(0); //
  rect(width*2/3,300,width/3,height-300);
  




  fill(0);
  stroke(111, 87, 0);
  textSize(20);
  textAlign(LEFT, BOTTOM);
  text("Problem Selecter :" , 45,40);

  fill(0);
  stroke(111, 87, 0);
  textSize(20);
  textAlign(LEFT, BOTTOM);
  text("Problem Loader :" , 45,155);

  fill(0);
  stroke(111, 87, 0);
  textSize(20);
  textAlign(LEFT, BOTTOM);
  text("Sorting Selector for Analysis :" , 240, 40);  


  fill(0);
  stroke(111, 87, 0);
  textSize(20);
  textAlign(LEFT, BOTTOM);
  text("Golden Solution Selector :" , 650, 160); 



  
  fill(0);
  stroke(111, 87, 0);
  textSize(20);
  textAlign(CENTER, BOTTOM);
  text("Graph Representation of the Ising Problem" ,320, 283);    

  fill(0);
  stroke(111, 87, 0);
  textSize(20);
  textAlign(CENTER, BOTTOM);
  text("The Golden Solution for Optimizing Ising Problem" ,960, 283);    

  fill(0);
  stroke(111, 87, 0);
  textSize(20);
  textAlign(CENTER, BOTTOM);
  text("Results of Measurements Obtained Using Hardware (UMN VLSI Lab)" ,1600, 283);    

  fill(0);
  stroke(111, 87, 0);
  textSize(20);
  textAlign(CENTER, BOTTOM);
  text("No of candidate spin for Gradient Decent : " + importer.num_ham_improve ,1500, 250);    





  for(int i = 1; i<=14; i++){
      color endColor_plus  = color(0, 0, 255);
      color endColor_minus = color(255, 0, 0);
      float weightValue = i/14.0;
      float startWeight = 1;
      float endWeight = 5;
      color startColor = color(0, 0, 100); 

      color lineColor = lerpColor(startColor, endColor_plus, weightValue);
      float weight = startWeight + weightValue * (endWeight - startWeight);

      strokeWeight(weight);
      stroke(lineColor);

      text("+" + i, 465, 60+i*14);
      line(415, 47+i*14, 455, 47+i*14);
  }

  for(int i = -1; i>=-14; i--){
      color endColor_plus  = color(0, 0, 255);
      color endColor_minus = color(255, 0, 0);
      float weightValue = -1 * i/14.0;
      float startWeight = 1;
      float endWeight = 5;
      color startColor = color(100, 0, 0); 

      color lineColor = lerpColor(startColor, endColor_minus, weightValue);
      float weight = startWeight + weightValue * (endWeight - startWeight);

      strokeWeight(weight);
      stroke(lineColor);

      text("" + i, 570,   60-i*14);
      line(520, 47-i*14, 560, 47-i*14);
  }

  strokeWeight(0);
  stroke(0);


//	
//	if(mode == 1) {
//			  float weightValue = abs(pair_weight)/14.0;
//			  float weight = startWeight + weightValue * (endWeight - startWeight);
//			  //color lineColor = pair_weight < 0 ? startColor : endColor;
//			  if(pair_weight>0)
//			      lineColor = lerpColor(startColor, endColor_plus, weightValue);
//			  if(pair_weight<0)
//			      lineColor = lerpColor(startColor, endColor_minus, weightValue);
//			  strokeWeight(weight);
//			  stroke(lineColor);
//		      }


  if(last_clicked_node != 0){
	  fill(#006400);
	  textAlign(LEFT, BOTTOM);
	  textSize(17); //

	  text("Node ID :" + str(importer.node_info_arr[last_clicked_node].node_id)                      , width*2/3+30, 50   );
	  text("Num of linked nodes :" + importer.node_info_arr[last_clicked_node].num_of_connected_nodes, width*2/3+30, 50+15);
	  text("Linked Nodes " + importer.node_info_arr[last_clicked_node].connected_node_text           , width*2/3+30, 50+30);
	  text("Linked Edges " + importer.node_info_arr[last_clicked_node].connected_edge_text           , width*2/3+30, 50+45);
	  
	  text("Sum of edges :" + str(importer.node_info_arr[last_clicked_node].connected_edge_sum)             , width*2/3+30, 50+60);
	  text("Sum of edges(ABS) :" + str(importer.node_info_arr[last_clicked_node].connected_edge_sum_abs)    , width*2/3+30, 50+75);
  }

  if(last_clicked_node_pre != 0){
	  fill(#006400);
	  textAlign(LEFT, BOTTOM);
	  textSize(17); // 
	  text("Node ID :" + str(importer.node_info_arr[last_clicked_node_pre].node_id)                      , width*2/3+30, 150   );
	  text("Num of linked nodes :" + importer.node_info_arr[last_clicked_node_pre].num_of_connected_nodes, width*2/3+30, 150+15);
	  text("Linked Nodes " + importer.node_info_arr[last_clicked_node_pre].connected_node_text           , width*2/3+30, 150+30);
	  text("Linked Edges " + importer.node_info_arr[last_clicked_node_pre].connected_edge_text           , width*2/3+30, 150+45);
	  
	  text("Sum of edges :" + str(importer.node_info_arr[last_clicked_node_pre].connected_edge_sum)             , width*2/3+30, 150+60);
	  text("Sum of edges(ABS) :" + str(importer.node_info_arr[last_clicked_node_pre].connected_edge_sum_abs)    , width*2/3+30, 150+75);
  }



  /////////////////////////////////////////////////////////////////////////////////
  // Draw bar chart for comparing solution quality

  float barGap = 20;                   // gap between bars
  float normalizedData = width/3 -205; // normalize the data
  float barHeight = 20;   
  float xPos = width*1/3 + 205; 
  float yPos = 60;       

  fill(0, 100, 200);      
  rect(xPos, yPos, normalizedData, barHeight); // draw the bar

  normalizedData = map(Math.abs(ham_cobi[0]), 0, Math.abs(ham_qubo[solution_number]), 0, normalizedData); // normalize the data
  yPos = yPos + (barHeight + barGap); 
  rect(xPos, yPos, normalizedData, barHeight); // draw the bar


  // Solution Quaility
  fill(0);
  stroke(111, 87, 0);
  textSize(30);
  textAlign(LEFT, BOTTOM);
  String formula = "H = - ∑ Spin(i)*Spin(j)*Edge(ij)";
  text("Solution Quality : " + formula , 660, 50);    

  fill(0);
  stroke(111, 87, 0);
  textSize(20);
  textAlign(LEFT, BOTTOM);
  text("Golden Solution", 655, 82);
  fill(255);
  text(str(Math.abs(ham_qubo[solution_number])) + "  " + "= 100" + "%", 850, 82);    

  fill(0);
  stroke(111, 87, 0);
  textSize(20);
  textAlign(LEFT, BOTTOM);
  text("Measurements Result", 655, 122);
  fill(255);
  
  float error = 0;
  if(ham_cobi[0] != 0) {
      error = ((float) (ham_cobi[0])) / (float)(ham_qubo[solution_number]) * 100;
  }
  text(str(Math.abs(ham_cobi[0])) + "  = " + str(error) + "%"   , 850, 122);

  
  /////////////////////////////////////////////////////////////////////////////////
  // Draw legends of error nodes
  
  stroke(255,120,0);       // Yellow line
  strokeWeight(10);
  fill(0, 0, 255); // Blue
  ellipse(1850, 360 , node_radius, node_radius);

  stroke(255,120,0);       // Yellow line
  strokeWeight(10);
  fill(255, 0, 0); // Red
  ellipse(1890, 360 , node_radius, node_radius);

  stroke(0,0,0);  
  strokeWeight(0);
  fill(0, 0, 0); 

  fill(0);
  stroke(111, 87, 0);
  textSize(20);
  textAlign(LEFT, BOTTOM);
  text("Mismatched Nodes : " , 1730, 330);


  fill(0);
  stroke(111, 87, 0);
  textSize(20);
  textAlign(LEFT, BOTTOM);
  text("Candidate for GD : " , 1300, 330);


  fill(#800080); // Purple
  ellipse(1310, 360 , node_radius+10, node_radius+10);
  strokeWeight(0);
  fill(0, 0, 255); // Blue
  ellipse(1310, 360 , node_radius, node_radius);


  fill(#800080);    // Purple
  ellipse(1340, 360 , node_radius+10, node_radius+10);
  strokeWeight(0);
  fill(255, 0, 0); // Red
  ellipse(1340, 360 , node_radius, node_radius);


  fill(#800080); // Purple
  ellipse(1380, 360 , node_radius+20, node_radius+20);
  stroke(255,120,0);       // Yellow line
  strokeWeight(10);
  fill(0, 0, 255); // Blue
  ellipse(1380, 360 , node_radius, node_radius);


  strokeWeight(0);
  stroke(0,0,0);       // Yellow line
  fill(#800080); // Purple
  ellipse(1420, 360 , node_radius+20, node_radius+20);
  stroke(255,120,0);       // Yellow line
  strokeWeight(10);
  fill(255, 0, 0); // Red
  ellipse(1420, 360 , node_radius, node_radius);

  /////////////////////////////////////////////////////////////////////////////////
  // Draw legends of error nodes
  stroke(0,0,0);  
  strokeWeight(0);
  fill(0, 0, 0); 

  fill(0, 0, 255);         // Blue
  ellipse(1210, 360 , node_radius, node_radius);
  fill(255); // White
  textAlign(CENTER, CENTER);
  textSize(16); // 
  text("+1", 1210, 360);

	      
  fill(255, 0, 0);         // Red
  ellipse(1250, 360 , node_radius, node_radius);
  fill(255); // White
  textAlign(CENTER, CENTER);
  textSize(16); // 
  text("-1", 1250, 360);


  stroke(0,0,0);  
  strokeWeight(0);
  fill(0, 0, 0); 

  fill(0);
  stroke(111, 87, 0);
  textSize(20);
  textAlign(LEFT, BOTTOM);
  text("Spin Values : {+1, -1}" , 1090, 330);

  
  /////////////////////////////////////////////////////////////////////////////////
  // Ising Problem 
  // Drawing Nodes
  draw_edges(0,0, 1);                  // mode 1
  draw_nodes(0,0, 1, solution_number); // mode 1

  /////////////////////////////////////////////////////////////////////////////////

  /////////////////////////////////////////////////////////////////////////////////
  // Solution #1
  // Drawing Nodes
  draw_edges(0+offset_pr1,0, 2);                   // mode 2
  draw_nodes(0+offset_pr1,0, 2,solution_number );  // mode 2


  /////////////////////////////////////////////////////////////////////////////////
  // Solution #2
  // Drawing Nodes
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
          .setPosition(width/3+20, 180)
          .setSize(150,150)
          ;

  for (int i = 0; i < importer.num_solutions; i++){
      // Add three options to the dropdown menu
      dropdown_sol.addItem("Select Solution : " + i, i);
  }
  // Set the default value of the dropdown menu to the first option (A)
  dropdown_sol.setValue(0);

  // reset previous clicked information
  for (int i = 0; i < 4; i++){
      for (int j = 1; j < 64; j++){
	  flag_mouse_over[i][j] = 0;         
	  flag_mouse_click[i][j] = 0;
	  flag_mouse_click_right[i][j] = 0;   
	  flag_mouse_double_click[i][j] =0;
      }
  }

  last_clicked_node = 0;
  last_clicked_node_pre = 0;



  // Execute different tasks based on the user's selection
  node_sort = (int) dropdown.getValue();
  switch (node_sort) {
  case 0:
      // Execute task A
      //System.out.println("\nSequential");
      mapping_table = importer.node_mapping_by_name(mapping_table);
      break;
  case 1:
      // Execute task B
      //System.out.println("\nReverse");
      mapping_table = importer.node_mapping_by_reverse(mapping_table);
      break;
  case 2:
      // Execute task C
      mapping_table = importer.node_mapping_by_edge(mapping_table);
      break;
  case 3:
      mapping_table = importer.node_mapping_by_edge_abs(mapping_table);
      break;
  case 4:
      mapping_table = importer.node_mapping_by_spin_sol1(mapping_table);
      break;
  case 5:
      mapping_table = importer.node_mapping_by_spin_sol2(mapping_table);
      break;
  case 6:
      mapping_table = importer.node_mapping_by_ham_impact(mapping_table);

      break;
  }

  hamiltonian();  
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
      loc_x = importer.node_info_arr[map_i].loc_x;
      loc_y = importer.node_info_arr[map_i].loc_y;

      loc_tx = importer.node_info_arr[map_i].txt_x;
      loc_ty = importer.node_info_arr[map_i].txt_y;

      // update offset for drawing solution #1, #2
      loc_x = loc_x + offset_x;
      loc_y = loc_y + offset_y;

      loc_tx = loc_tx + offset_x;
      loc_ty = loc_ty + offset_y;

      // Detect mouse over
      float distance = dist(loc_x, loc_y, mouseX, mouseY);
      float radius = node_radius;

      if(distance <= radius/2){
	  radius = node_radius * 2;
	  flag_mouse_over[mode][i] = 1;


      }
      else {
	  radius = node_radius;
	  flag_mouse_over[mode][i] = 0;
      }
      
      // Node Drawing
      if(mode == 1) {
	  fill(0, 0, 0);   // Black
	  stroke(0);       // Black Line
	  strokeWeight(0); // 
	  ellipse(loc_x, loc_y , radius, radius);
      }
      else if(mode == 2) {
	  if(solution_qubo[qubo_solution_num][i] == -1) {
	      fill(255, 0, 0); // Red
	      stroke(0);       // Black Line
	      strokeWeight(0); // 
	      ellipse(loc_x, loc_y , radius, radius);

	      fill(255); // Black
	      textAlign(CENTER, CENTER);
	      textSize(16); // 
	      text("-1", loc_x, loc_y);
	  }
	  else if(solution_qubo[qubo_solution_num][i] == 1) {
	      fill(0, 0, 255); // Blue
	      stroke(0);       // Black Line
	      strokeWeight(0); // 
	      ellipse(loc_x, loc_y , radius, radius);

	      fill(255); // White
	      textAlign(CENTER, CENTER);
	      textSize(16); // 
	      text("+1", loc_x, loc_y);
	  }
      }
      else if(mode == 3) {
	  
	  
	  if(solution_cobi[1][i] == -1) {
	      if(solution_qubo[qubo_solution_num][i] != solution_cobi[1][i]) { // difference 
		  // gradient decents
		  if(importer.node_info_arr[i].ham_impact_sol2 > 0){
		      fill(#800080); // Green
		      ellipse(loc_x, loc_y , radius+20, radius+20);
		  }
		  stroke(255,120,0);       // Yellow line
		  strokeWeight(10);
	      }
	      else {
		  // gradient decents
		  if(importer.node_info_arr[i].ham_impact_sol2 > 0){
		      fill(#800080); // Green
		      ellipse(loc_x, loc_y , radius+11, radius+11);
		  }
		  stroke(0);       // Black Line
		  strokeWeight(0); //
	      }
	      fill(255, 0, 0); // Red
	      ellipse(loc_x, loc_y , radius, radius);
	  }
	  else if(solution_cobi[1][i] == 1) {
	      if(solution_qubo[qubo_solution_num][i] != solution_cobi[1][i]) { // difference 
		  // gradient decents
		  if(importer.node_info_arr[i].ham_impact_sol2 > 0){
		      fill(#800080); // Green
		      ellipse(loc_x, loc_y , radius+20, radius+20);
		  }
		  stroke(255,120,0);       // Yellow line
		  strokeWeight(10); 
	      }
	      else {
		  // gradient decents
		  if(importer.node_info_arr[i].ham_impact_sol2 > 0){
		      fill(#800080); // Green
		      ellipse(loc_x, loc_y , radius+11, radius+11);
		  }
		  stroke(0);       // Black Line
		  strokeWeight(0); //
	      }
	      fill(0, 0, 255); // Blue
	      ellipse(loc_x, loc_y , radius, radius);
	  }
	  
	  
	  stroke(0);       // Black Line
	  strokeWeight(0); //
      }
      

      // Text Drawing
      fill(0, 0, 0); // Black
      textSize(15); // 
      textAlign(CENTER, CENTER);
      if (i != 1)
	  text("N" + String.format("%02d", i), loc_tx, loc_ty);
      else {
	  fill(255, 0, 0);
	  text("N" + String.format("%02d", i), loc_tx, loc_ty);
      }

	  
      if(flag_mouse_over[mode][i] == 1){
	  fill(#006400);
	  textAlign(LEFT, BOTTOM);
	  textSize(17); // 
	  text("Node ID :" + str(importer.node_info_arr[i].node_id)    , mouseX+30, mouseY);
	  text("Num of linked nodes :" + importer.node_info_arr[i].num_of_connected_nodes, mouseX+30, mouseY+15);
	  text("Linked Nodes " + importer.node_info_arr[i].connected_node_text    , mouseX+30, mouseY+30);
	  text("Linked Edges " + importer.node_info_arr[i].connected_edge_text    , mouseX+30, mouseY+45);
	  
	  text("Sum of edges :" + str(importer.node_info_arr[i].connected_edge_sum)    , mouseX+30, mouseY+60);
	  text("Sum of edges(ABS) :" + str(importer.node_info_arr[i].connected_edge_sum_abs)    , mouseX+30, mouseY+75);
      }
  }

  fill(0);

  // Bar chart drawing under the graph
  float barWidth = 20;      // Width of each bar
  float barHeight = 0;
  float bar_x = offset_x + 75; // Starting x-coordinate for bars

  float maxVal = -255; // Find max values
  float[] normalizedValues = new float[64]; 
  float[] values           = new float[64];
  String title_of_bar = "";

  float has_negative = 0;  // positive : 0, negative : 1

  // Assing value array
  for (int i = 1; i <= importer.num_node; i++) {
      if(node_sort == 0 || node_sort == 1) {                            // Sequential, Reverse
	  values[i] = importer.node_info_arr[i].num_of_connected_nodes;
	  title_of_bar = "Number of connected nodes\n (Top 20 Nodes)";
	  if(maxVal < values[i]){
	      maxVal = values[i];
	  }
	  if ( values[i] < 0) {
	      has_negative = 1;
	  }
      }

      else if(node_sort == 2) {                                        // 
	  values[i] = importer.node_info_arr[i].connected_edge_sum;
	  title_of_bar = "Sum of Edge Weights \n (Top 20 Nodes)";
	  if(maxVal < values[i]){
	      maxVal = values[i];
	  }
	  if ( values[i] < 0) {
	      has_negative = 1;
	  }
      }

      else if(node_sort == 3) {                                        // 
	  values[i] = importer.node_info_arr[i].connected_edge_sum_abs;
	  title_of_bar = "Sum of Edge Weights(ABS) \n (Top 20 Nodes)";
	  if(maxVal < values[i]){
	      maxVal = values[i];
	  }
	  if ( values[i] < 0) {
	      has_negative = 1;
	  }
      }

      else if(node_sort == 6) {                                        // 
	  values[i] = importer.node_info_arr[i].ham_impact_sol2;
	  title_of_bar = "Candidate spins \n for Gradient Descent";
	  if(maxVal < values[i]){
	      maxVal = values[i];
	  }
	  if ( values[i] < 0) {
	      // has_negative = 1;
	      values[i] = 0;
	  }
      }
      
  }
  
  for (int i = 1; i <= importer.num_node; i++) {
      if(maxVal >= 0)
	  normalizedValues[i] = values[i] / (float)maxVal; // Normalization
      else
	  normalizedValues[i] = -1 * values[i] / (float)maxVal; // Normalization
  }

  for (int i = 1; (i <= importer.num_node) && (i < 20 ); i++) {   // run order
      // Print Graph based on mapping order

      textSize(18);
      textAlign(CENTER, CENTER);
	  
      int map_i=0;
      for (int j= 1; j<= importer.num_node; j++){
	  if(i == importer.node_info_arr[j].order) {            // check sort order == run order
	      map_i = importer.node_info_arr[j].node_id;                         // return node id
	  }
      }

      if(mode == 3) {
	  if(solution_qubo[qubo_solution_num][map_i] != solution_cobi[1][map_i]) { // difference 
	      stroke(255,120,0);       // Yellow line
	      strokeWeight(10); 
	  }
	  else {
	      stroke(0);       // Black Line
	      strokeWeight(0); //
	  }
      }

      
      if(has_negative == 0) {
	  // Select node_sort mode::
	  barHeight = map(normalizedValues[map_i], 0, 1, 0, 150); 
	  rect(bar_x, height -50 - barHeight, barWidth, barHeight);                      // Draw bar
	  text("N" + str(importer.node_info_arr[map_i].node_id), bar_x+10, height -40);         // Draw text      
	  text(str(values[i]),                                   bar_x+10, height -20);         // Draw text

      }
      else {
	  if(values[i]>=0){
	      // Select node_sort mode::
	      barHeight = map(normalizedValues[map_i], 0, 1, 0, 75); 
	      rect(bar_x, height -125 - barHeight, barWidth, barHeight);                      // Draw bar
	      text("N" + str(importer.node_info_arr[map_i].node_id), bar_x+10, height -40);         // Draw text      
	      text(str(values[i]),                                   bar_x+10, height -20);         // Draw text
	  }
	   if(values[i]<0){
	      // Select node_sort mode::
	      barHeight = map(normalizedValues[map_i], 0, 1, 0, 75); 
	      rect(bar_x, height -125 - barHeight, barWidth, barHeight);                      // Draw bar
	      text("N" + str(importer.node_info_arr[map_i].node_id), bar_x+10, height -40);         // Draw text      
	      text(str(values[i]),                                   bar_x+10, height -20);         // Draw text
	  }

      }
      
      // print solutions 
      if(mode == 2){
	  fill(0);
	  stroke(111, 87, 0);
	  textSize(20);
	  textAlign(LEFT, BOTTOM);
	  String sign = (solution_qubo[solution_number][map_i] < 0) ? "" : "+";
	  if( i == 1) {
	      text("SOL  =  { ", width/3+10, 303);
	      text(sign + str(solution_qubo[solution_number][map_i]), bar_x+10, 303);         // Draw text      	      
	  }
	  else if( i < 18 ){
	      text("," + sign + str(solution_qubo[solution_number][map_i]), bar_x+10, 303);         // Draw text      
	  }
	  else if ( i == 18 ) {
	      text("..", bar_x+10, 303);         // Draw text      
	  }

	  if ( i == importer.num_node || i == 18) {
	      text("}", bar_x+35, 303);
	  }

      }
      if(mode == 3){
	  fill(0);
	  stroke(111, 87, 0);
	  textSize(20);
	  textAlign(LEFT, BOTTOM);
	  String sign = (solution_cobi[1][map_i] < 0) ? "" : "+";
	  if( i == 1) {
	      text("MEAS =  { ", width*2/3+10, 303);
	      text(sign + str(solution_cobi[1][map_i]), bar_x+10, 303);         // Draw text      	      
	  }
	  else if( i < 18 ){
	      text("," + sign + str(solution_cobi[1][map_i]), bar_x+10, 303);         // Draw text      
	  }
	  else if ( i == 18 ) {
	      text("..", bar_x+10, 303);         // Draw text      
	  }

	  if ( i == importer.num_node || i == 18) {
	      text("}", bar_x+35, 303);
	  }

      }

      
      bar_x += barWidth + 10; // Increase x-coordinate for next bar
  }
  textSize(20);
  textAlign(CENTER, CENTER);
  translate(offset_x+30, 950);
  rotate(-HALF_PI);
  text(title_of_bar, 0,0);
  rotate(+HALF_PI);
  translate(-(offset_x+30), -950);  

}


void draw_edges(float offset_x, float offset_y, int mode){
  float startWeight = 1;
  float endWeight = 5;
  color startColor = color(0, 0, 0);

  color startColor_plus  = color(0,   0, 100);  
  color startColor_minus = color(100, 0, 0);
  
  color endColor_plus  = color(0, 0, 255);
  color endColor_minus = color(255, 0, 0);
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

	  loc_x_ni = importer.node_info_arr[map_ni].loc_x;
	  loc_y_ni = importer.node_info_arr[map_ni].loc_y;

	  loc_x_nj = importer.node_info_arr[map_nj].loc_x;
	  loc_y_nj = importer.node_info_arr[map_nj].loc_y;

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
		      lineColor = lerpColor(startColor_plus, endColor_plus, weightValue);
		  if(pair_weight<0)
		      lineColor = lerpColor(startColor_minus, endColor_minus, weightValue);
		  strokeWeight(weight);
		  stroke(lineColor);
	      }
	      if(mode == 2) {
		  lineColor = color(200, 200, 200);
		  float weight = 1;
		  if(flag_mouse_over[mode][i] == 1 || flag_mouse_over[mode][j] == 1 || flag_mouse_click[mode][i] == 1 || flag_mouse_click[mode][j] == 1){   // mouse over || mouse clicked
		      float weightValue = abs(pair_weight)/14.0;
		      weight = startWeight + weightValue * (endWeight - startWeight);
		      //color lineColor = pair_weight < 0 ? startColor : endColor;
		      if(pair_weight>0)
			  lineColor = lerpColor(startColor_plus, endColor_plus, weightValue);
		      if(pair_weight<0)
			  lineColor = lerpColor(startColor_minus, endColor_minus, weightValue);
		  }
		  else {

		  }
		  strokeWeight(weight);
		  stroke(lineColor);
	      }

	      if(mode == 3) {
		  lineColor = color(200, 200, 200);
		  float weight = 1;
		  if(flag_mouse_over[mode][i] == 1 || flag_mouse_over[mode][j] == 1 || flag_mouse_click[mode][i] == 1 || flag_mouse_click[mode][j] == 1){   // mouse over || mouse clicked
		      float weightValue = abs(pair_weight)/14.0;
		      weight = startWeight + weightValue * (endWeight - startWeight);
		      //color lineColor = pair_weight < 0 ? startColor : endColor;
		      if(pair_weight>0)
			  lineColor = lerpColor(startColor_plus, endColor_plus, weightValue);
		      if(pair_weight<0)
			  lineColor = lerpColor(startColor_minus, endColor_minus, weightValue);
		  }
		  else {

		  }
		  strokeWeight(weight);
		  stroke(lineColor);
	      }
    
	      line(loc_x_ni, loc_y_ni,  loc_x_nj, loc_y_nj);
	  }
      }
  }
}



void mouseClicked() {

    if(node_sort == 4) {
	mapping_table = importer.node_mapping_by_spin_sol1(mapping_table);
    }

    if(node_sort == 6) {
	mapping_table = importer.node_mapping_by_ham_impact(mapping_table);
    }
    if(mouseButton == LEFT){
	float loc_x;
	float loc_y;

	float dis_x;
	float dis_y;

	int select = (int) dropdown_sol.getValue();

	println("mouse clicked");
	println("Solution Number : " + str(select));


	if(importer.num_node > 0) {  // after drawing graph
	    for(int i = 1; i<= importer.num_node; i++){


		int map_i = mapping_table[i];
		loc_x = importer.node_info_arr[map_i].loc_x;
		loc_y = importer.node_info_arr[map_i].loc_y;

		// Problem Graph
		dis_x = loc_x + 0;
		dis_y = loc_y + 0;

		float d = dist(mouseX, mouseY, dis_x, dis_y);
		if (d < node_radius/2) { // if mouse is clicking on the node
		    flag_mouse_click[1][i] = ~flag_mouse_click[1][i];     // invert flag
		}

		// Solution #1
		dis_x = loc_x + offset_pr1;
		dis_y = loc_y;

		d = dist(mouseX, mouseY, dis_x, dis_y);

		if (d < node_radius/2) { // if mouse is clicking on the node
		    if(flag_mouse_click[2][i] == 0) {
			flag_mouse_click[2][i] = 1;
			if(last_clicked_node != last_clicked_node_pre){
			    last_clicked_node_pre = last_clicked_node;
			}
			last_clicked_node = i;
		    }
	      
		    else
			flag_mouse_click[2][i] = 0;
	      
		}

		// Solution #2
		dis_x = loc_x + offset_pr2;
		dis_y = loc_y;

		d = dist(mouseX, mouseY, dis_x, dis_y);
		if (d < node_radius/2) { // if mouse is clicking on the node
		    if(flag_mouse_click[3][i] == 0) {
			flag_mouse_click[3][i] = 1;
			if(last_clicked_node != last_clicked_node_pre){
			    last_clicked_node_pre = last_clicked_node;
			}
			last_clicked_node = i;


		    }
		    else
			flag_mouse_click[3][i] = 0;
		    println("mouse clicked"); 
		}
      
	    }
	}
    }

    else if(mouseButton == RIGHT){
	float loc_x;
	float loc_y;

	float dis_x;
	float dis_y;

	if(importer.num_node > 0) {  // after drawing graph
	    for(int i = 1; i<= importer.num_node; i++){

		int map_i = mapping_table[i];
		loc_x = importer.node_info_arr[map_i].loc_x;
		loc_y = importer.node_info_arr[map_i].loc_y;

		// Solution #2
		dis_x = loc_x + offset_pr2;
		dis_y = loc_y;

		float d = dist(mouseX, mouseY, dis_x, dis_y);
		if (d < node_radius/2) { // if mouse is clicking on the node
		    if(flag_mouse_click_right[3][i] == 0) {
			flag_mouse_click_right[3][i] = 1;
		    }
		    else
			flag_mouse_click_right[3][i] = 0;
		    println("mouse right clicked"); 
		}
      
	    }
	}


	for(int i = 1; i<= importer.num_node; i++){
	    if(flag_mouse_click_right[3][i] == 1) {
		solution_cobi[1][i] = -1 * solution_cobi[0][i];
	    }
	    else
		solution_cobi[1][i] =  1 * solution_cobi[0][i];
	}
    }

    // update hamiltonian
    hamiltonian();

    
    
}

// int[][] inputGraphArray = new int[64][64];
// int[][] solution_qubo     = new int[10][64];
// int[][] solution_cobi     = new int[10][64];
// 
// int[] ham_qubo     = new int[10];
// int[] ham_cobi     = new int[10];
void hamiltonian(){

    int results_qubo = 0;
    int results_cobi = 0;
    for(int i=1 ; i <= importer.num_node; i++){
	for(int j=1 ; j < i; j++){
	    // same sign
	    if(solution_qubo[solution_number][i] == solution_qubo[solution_number][j]) {
		results_qubo = results_qubo - (inputGraphArray[i][j] + inputGraphArray[j][i]);
	    }
	    // different sign
	    else {
		results_qubo = results_qubo + (inputGraphArray[i][j] + inputGraphArray[j][i]);
	    }

	    // same sign
	    if(solution_cobi[1][i] == solution_cobi[1][j]) {
		results_cobi = results_cobi - (inputGraphArray[i][j] + inputGraphArray[j][i]);
	    }
	    // different sign
	    else {
		results_cobi = results_cobi + (inputGraphArray[i][j] + inputGraphArray[j][i]);
	    }
	}	    
    }
    ham_qubo[solution_number] = results_qubo;
    ham_cobi[0]               = results_cobi;
    

    // Calculating the impact of hamiltonian if inverting single bit
    importer.num_ham_improve = 0;
    for(int node = 1; node<= importer.num_node; node++){
	// generating new solution space - solution_cobi[2][:] and fliping node based on iterator
	for(int i = 1; i<= importer.num_node; i++){
	    if (node == i)
		solution_cobi[2][i] = solution_cobi[1][i] * (-1);
	    else 
		solution_cobi[2][i] = solution_cobi[1][i];
	}

	int result_impact = 0;
	// Calcuating hamiltonian impact using solution_cobi[2]
	for(int i=1 ; i <= importer.num_node; i++){
	    for(int j=1 ; j < i; j++){
		// same sign
		if(solution_cobi[2][i] == solution_cobi[2][j]) {
		    result_impact =  result_impact - (inputGraphArray[i][j] + inputGraphArray[j][i]);
		}
		// different sign
		else {
		    result_impact = result_impact + (inputGraphArray[i][j] + inputGraphArray[j][i]);
		}
	    }
	}
	importer.node_info_arr[node].ham_impact_sol2 = results_cobi - result_impact;  // assign difference 
	if (results_cobi > result_impact) {
	    importer.num_ham_improve++;
	}
	
    }
}
