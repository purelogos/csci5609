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

public class GraphImporter {

    public int[][] importGraphWithViz(int[][] input_data_array, String graph_file_name) {
        try {
            Scanner scanner = new Scanner(new File(graph_file_name));
            int dim_x = 63;
            int dim_y = 0;
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
            FileWriter fw = new FileWriter(dataDir + "debug.txt");

            for (int x = 0; x < 64; x++) {                
                if (x == 0) { // node print
                    for (int y = 1; y < 60; y++) {
                        if (input_data_array[x][y] != 0) {
                            fw.write("\t " + y + ";\n");
                            System.out.println("Nodes : " + y );
                        }
                    }
                }
                if (x >= 1 & x <= 59) { // edge print
                    for (int y = 1; y < x; y++) {
                        int pair_weight = input_data_array[x][y] + input_data_array[y][x];
                        if (pair_weight != 0) {
                            fw.write("\t " + x + " -- " + y + " [label = \"" + pair_weight + "\"];\n");
                            System.out.println("Edges \t " + x + " -- " + y + " [Weights = \"" + pair_weight + "\"]");
                        }
                    }
                }
            }
            fw.write("}\n");
            fw.close();
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
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
    
 


}