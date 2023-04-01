import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.BufferedReader;
import java.io.FileReader;

import java.util.Scanner;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class node_info {
  float loc_x;
  float loc_y;
  float txt_x;
  float txt_y;

    int node_id = 0;
    int node_edge_sum      = 0;
    int node_edge_absolute = 0;

    int spin_value_sol1    = 0;
    int spin_value_sol2    = 0;

    int ham_impact_sol1 = 0;
    int ham_impact_sol2 = 0;

    int[] connected_node          = new int[64];
    int[] connected_edge_weights  = new int[64];

    int  num_of_connected_nodes = 0;
    
    int   connected_edge_sum      = 0;
    int   connected_edge_sum_abs  = 0;

    String connected_node_text = "";
    String connected_edge_text = "";

    int order = 0;

    
    node_info(float x, float y, float tx, float ty) {
	this.loc_x = x;
	this.loc_y = y;

	this.txt_x = tx;
	this.txt_y = ty;
    }

    node_info(int node_id) {
	this.node_id = node_id;
	this.order = node_id;
    }



}

public class GraphImporter {

    int num_node;
    int num_edge;
    int num_solutions;


    node_info[] node_info_arr = new node_info[64];
    // Centroid of circle
    int cx = 350;
    int cy = 600;

    // Radious of circle
    int r        = 250;
    int dr_text  = 30;
  

    public int[][] importGraphWithViz(int[][] input_data_array, String graph_file_name) {
        try {
            Scanner scanner = new Scanner(new File(graph_file_name));
            int dim_x = 63;
            int dim_y = 0;

	    for(int i=0; i<64; i++){
		this.node_info_arr[i] = new node_info(i);
	    }
	    
            while (scanner.hasNextLine()) {
                String line = scanner.nextLine().trim();
                    if (line.isEmpty()) {
                        continue; // skip empty lines
                    }
            
                String[] char_list = line.split("\\s+");
                
                dim_y = char_list.length;
                
                for (int y = 0; y < dim_y; y++) {
                    //System.out.println("Debug" + Integer.parseInt(char_list[y]) + " y " + y);
                    input_data_array[dim_x][y] = Integer.parseInt(char_list[y]);
                }
                dim_x--;
            }
            if ((63-dim_x) != dim_y) {
                System.out.print("# of values in row " + (dim_x - 1) + " not equal to column dimension " + dim_y);
                System.exit(0);
            }
            
            // Debug Read Data
            for(int x = 0; x <2; x++){
              for(int y = 0; y<64; y++){
                if (input_data_array[x][y] != 0) {
                  System.out.println("Input Array \t " +"(" + x + "," + y + ")" + input_data_array[x][y]);
                }
              }
            }
            
            scanner.close();
            
            String dataDir = sketchPath("");
            //FileWriter fw = new FileWriter(dataDir + "debug.txt");

	    this.num_node = 0;
	    this.num_edge = 0;
            for (int x = 0; x < 64; x++) {                
                if (x == 0) { // node print
                    for (int y = 1; y < 60; y++) {
                        if (input_data_array[x][y] != 0) {
                            //fw.write("\t " + y + ";\n");
                            System.out.println("Nodes : " + y );
			    this.num_node++;

			    this.node_info_arr[y].node_id = y;    
                        }
                    }
                }
                if (x >= 1 & x <= 59) { // edge print
                    for (int y = 1; y < x; y++) {
                        int pair_weight = input_data_array[x][y] + input_data_array[y][x];
                        if (pair_weight != 0) {
                            //fw.write("\t " + x + " -- " + y + " [label = \"" + pair_weight + "\"];\n");
                            System.out.println("Edges \t " + x + " -- " + y + " [Weights = \"" + pair_weight + "\"]");
			    this.num_edge++;
			    
                        }
                    }
                }
            }
            //fw.write("}\n");
            //fw.close();
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }

	
	// Calcuating node location
	for (int i = 1; i <= this.num_node; i++) {
	    float angle = i * TWO_PI / this.num_node; // Angle
	    float x = cx + r * cos(angle); // x 
	    float y = cy + r * sin(angle); // y

	    float tx = x + dr_text *  cos(angle);
	    float ty = y + dr_text *  sin(angle);

	    //this.node_info_arr[i] = new node_info(x,y,tx,ty);
	    this.node_info_arr[i].loc_x = x;
	    this.node_info_arr[i].loc_y = y;
	    this.node_info_arr[i].txt_x = tx;
	    this.node_info_arr[i].txt_y = ty;

	}
	// Calculating linked list node
	for (int i = 1; i <= this.num_node; i++) {
	    int num_of_connected_nodes = 0;
	    for (int j = 1; j <= this.num_node; j++) {
		if( (input_data_array[i][j] != 0) && (input_data_array[j][i] !=0) && (i!=j)){
		    this.node_info_arr[i].connected_node[j] = 1;
		    num_of_connected_nodes++;
		}
	    }
	    this.node_info_arr[i].num_of_connected_nodes = num_of_connected_nodes;
	}

	// Calculating edge sum
	for (int i = 1; i <= this.num_node; i++) {
	    int pair_weight     = 0;
	    int pair_weight_abs = 0; 
	    for (int j = 1; j <= this.num_node; j++) {
		if(i != j){
		    pair_weight     = pair_weight     +         (input_data_array[i][j] + input_data_array[j][i]);
		    pair_weight_abs = pair_weight_abs + Math.abs(input_data_array[i][j] + input_data_array[j][i]);
		    this.node_info_arr[i].connected_edge_weights[j] = (input_data_array[i][j] + input_data_array[j][i]);
		}
	    }
	    this.node_info_arr[i].connected_edge_sum     = pair_weight;
	    this.node_info_arr[i].connected_edge_sum_abs = pair_weight_abs;
	}


	for (int i = 1; i <= 63; i++) {
	    String linked_list = "";
	    String linked_edges = "";
	    for (int j = 1; j <= 63; j++) {
		if(this.node_info_arr[i].connected_node[j] == 1){
		    String sign = (this.node_info_arr[i].connected_edge_weights[j] >= 0) ? "+" : "-";
		    linked_list  = linked_list + "||N" + String.format("%02d", j);
		    linked_edges = linked_edges+ "|| "  + sign + String.format("%02d", Math.abs(this.node_info_arr[i].connected_edge_weights[j]));
		}
	    }
	    this.node_info_arr[i].connected_node_text = linked_list;
	    this.node_info_arr[i].connected_edge_text = linked_edges;
	}
	
        return input_data_array;
    }
    
    public int[][] parse_qubo(int[][] input_data_array, String filename) {
      try {
        println(filename);
        Scanner scanner = new Scanner(new File(filename));
        String line = scanner.nextLine().trim();
        
        String[] rowStrings = line.substring(1, line.length() - 1).split("\\}, \\{");
        int numRows = rowStrings.length;
        int numCols = rowStrings[0].split(", ").length;

	this.num_solutions = rowStrings.length;
        for (int i = 0; i < numRows; i++) {
          String[] colStrings = rowStrings[i].split(", ");
          for (int j = 0; j < numCols; j++) {
            colStrings[j] = colStrings[j].replace("[", "");
            colStrings[j] = colStrings[j].replace("{", "");
            colStrings[j] = colStrings[j].replace("}", "");
            int val = Integer.parseInt(colStrings[j].split(": ")[1]);
            int idx = Integer.parseInt(colStrings[j].split(": ")[0]);
            input_data_array[i][idx] = val;
            println("arr[" + i + "][" + idx + "] = " + val); 
          }
        }
        //System.out.println(Arrays.toString(maps));
      } 
      catch (FileNotFoundException e) {
          e.printStackTrace();
      } 
      catch (IOException e) {
          e.printStackTrace();
      }
      return input_data_array;
    }
    

    public int[][] parse_cobi(int[][] input_data_array, String filename) {
      try {
        println(filename);
        Scanner scanner = new Scanner(new File(filename));
        String line = scanner.nextLine().trim();
        
        String[] rowStrings = line.substring(1, line.length() - 1).split("\\}, \\{");
        int numRows = rowStrings.length;
        int numCols = rowStrings[0].split(", ").length;

        for (int i = 0; i < numRows; i++) {
          String[] colStrings = rowStrings[i].split(", ");
          for (int j = 0; j < numCols; j++) {
            colStrings[j] = colStrings[j].replace("[", "");
            colStrings[j] = colStrings[j].replace("{", "");
            colStrings[j] = colStrings[j].replace("}", "");
            int val = Integer.parseInt(colStrings[j].split(": ")[1]);
            int idx = Integer.parseInt(colStrings[j].split(": ")[0]);
            input_data_array[i][idx] = val;

	    this.node_info_arr[idx].spin_value_sol2 = val;
            println("arr[" + i + "][" + idx + "] = " + val);

	    
          }
        }
        //System.out.println(Arrays.toString(maps));
      } 
      catch (FileNotFoundException e) {
          e.printStackTrace();
      } 
      catch (IOException e) {
          e.printStackTrace();
      }
      System.out.println("\nData read done");
      System.out.println("# of nodes :" + this.num_node);
      System.out.println("# of edges :" + this.num_edge);
      System.out.println("# of qubo solutions :" + this.num_solutions);
      
      return input_data_array;
    }

    public int[] node_mapping_by_name (int[] input_mapping_array) {

	for (int i = 1; i <= this.num_node; i++) {
	    input_mapping_array[i] = i;
	    this.node_info_arr[i].order = i;
	}

	return input_mapping_array;
    }

    public int[] node_mapping_by_reverse (int[] input_mapping_array) {

	for (int i = 1; i <= this.num_node; i++) {
	    input_mapping_array[i] = this.num_node - i + 1;
	    this.node_info_arr[i].order = this.num_node - i + 1;
	}

	return input_mapping_array;
    }

    public int[] node_mapping_by_edge (int[] input_mapping_array) {

	// Results
	for (int i = 1; i < this.num_node; i++) {
	    println(this.node_info_arr[i].node_id + ": " +this.node_info_arr[i].order + ": " + this.node_info_arr[i].connected_edge_sum);
	}

	for (int i = 1; i <= this.num_node; i++) {
	    int highCount = 0;
	    for (int j = 1; j <= this.num_node; j++) {
		if (this.node_info_arr[i].connected_edge_sum < this.node_info_arr[j].connected_edge_sum) {
		    highCount++;
		}
	    }
	    this.node_info_arr[i].order = highCount +1;

	    input_mapping_array[i] = highCount +1;
	}

	// same order change
	for (int i = 1; i <= this.num_node; i++) {
	    int order = this.node_info_arr[i].order;
	    int order_plus = 1;
	    for (int j = i+1; j <= this.num_node; j++) {
		if (this.node_info_arr[i].order == this.node_info_arr[j].order) {
		    this.node_info_arr[j].order = order + order_plus;
		    input_mapping_array[j]      = order + order_plus; 
		    order_plus++;
		}
	    }
	}

	// Results
	for (int i = 1; i < this.node_info_arr.length; i++) {
	    println(this.node_info_arr[i].node_id + ": " + this.node_info_arr[i].order + ": " + this.node_info_arr[i].connected_edge_sum);
	}

	//input_mapping_array[i] = this.num_node - i + 1;
	return input_mapping_array;
    }


    public int[] node_mapping_by_edge_abs (int[] input_mapping_array) {

	// Results
	for (int i = 1; i < this.num_node; i++) {
	    println(this.node_info_arr[i].node_id + ": " +this.node_info_arr[i].order + ": " + this.node_info_arr[i].connected_edge_sum_abs);
	}

	for (int i = 1; i <= this.num_node; i++) {
	    int highCount = 0;
	    for (int j = 1; j <= this.num_node; j++) {
		if (this.node_info_arr[i].connected_edge_sum_abs < this.node_info_arr[j].connected_edge_sum_abs) {
		    highCount++;
		}
	    }
	    this.node_info_arr[i].order = highCount +1;

	    input_mapping_array[i] = highCount +1;
	}

	// same order change
	for (int i = 1; i <= this.num_node; i++) {
	    int order = this.node_info_arr[i].order;
	    int order_plus = 1;
	    for (int j = i+1; j <= this.num_node; j++) {
		if (this.node_info_arr[i].order == this.node_info_arr[j].order) {
		    this.node_info_arr[j].order = order + order_plus;
		    input_mapping_array[j]      = order + order_plus; 
		    order_plus++;
		}
	    }
	}

	// Results
	for (int i = 1; i < this.node_info_arr.length; i++) {
	    println(this.node_info_arr[i].node_id + ": " + this.node_info_arr[i].order + ": " + this.node_info_arr[i].connected_edge_sum_abs);
	}

	//input_mapping_array[i] = this.num_node - i + 1;
	return input_mapping_array;
    }

    public int[] node_mapping_by_spin_sol2 (int[] input_mapping_array) {

	// Results
	for (int i = 1; i < this.num_node; i++) {
	    println(this.node_info_arr[i].node_id + ": " +this.node_info_arr[i].order + ": " + this.node_info_arr[i].spin_value_sol2);
	}

	for (int i = 1; i <= this.num_node; i++) {
	    int highCount = 0;
	    for (int j = 1; j <= this.num_node; j++) {
		if (this.node_info_arr[i].spin_value_sol2 < this.node_info_arr[j].spin_value_sol2) {
		    highCount++;
		}
	    }
	    this.node_info_arr[i].order = highCount +1;

	    input_mapping_array[i] = highCount +1;
	}

	// same order change
	for (int i = 1; i <= this.num_node; i++) {
	    int order = this.node_info_arr[i].order;
	    int order_plus = 1;
	    for (int j = i+1; j <= this.num_node; j++) {
		if (this.node_info_arr[i].order == this.node_info_arr[j].order) {
		    this.node_info_arr[j].order = order + order_plus;
		    input_mapping_array[j]      = order + order_plus; 
		    order_plus++;
		}
	    }
	}
	// Results
	for (int i = 1; i < this.node_info_arr.length; i++) {
	    println(this.node_info_arr[i].node_id + ": " + this.node_info_arr[i].order + ": " + this.node_info_arr[i].spin_value_sol2);
	}

	//input_mapping_array[i] = this.num_node - i + 1;
	return input_mapping_array;
    }


    public int[] node_mapping_by_spin_sol1 (int[] input_mapping_array) {

	// Results
	for (int i = 1; i < this.num_node; i++) {
	    println(this.node_info_arr[i].node_id + ": " +this.node_info_arr[i].order + ": " + solution_qubo[solution_number][i]);
	}

	for (int i = 1; i <= this.num_node; i++) {
	    int highCount = 0;
	    for (int j = 1; j <= this.num_node; j++) {
		if (solution_qubo[solution_number][i] < solution_qubo[solution_number][j]) {
		    highCount++;
		}
	    }
	    this.node_info_arr[i].order = highCount +1;

	    input_mapping_array[i] = highCount +1;
	}

	// same order change
	for (int i = 1; i <= this.num_node; i++) {
	    int order = this.node_info_arr[i].order;
	    int order_plus = 1;
	    for (int j = i+1; j <= this.num_node; j++) {
		if (this.node_info_arr[i].order == this.node_info_arr[j].order) {
		    this.node_info_arr[j].order = order + order_plus;
		    input_mapping_array[j]      = order + order_plus; 
		    order_plus++;
		}
	    }
	}
	// Results
	for (int i = 1; i < this.node_info_arr.length; i++) {
	    println(this.node_info_arr[i].node_id + ": " + this.node_info_arr[i].order + ": " + solution_qubo[solution_number][i]);
	}

	//input_mapping_array[i] = this.num_node - i + 1;
	return input_mapping_array;
    }
    
}
