/* CSci-5609 Visualization Support Code  created by Prof. Dan Keefe, Fall 2023

To size or color graphics based on data, we need to know min and max ranges for the data.
These utilities help to quickly calculate mins and maxes for data organized in tables.
*/
static class TableUtils {
  
  static float findMinFloatInColumn(Table t, int column) {
    float[] values = t.getFloatColumn(column);
    float min = values[0];
    for (int i=0; i<values.length; i++) {
      if (values[i] < min) {
        min = values[i]; 
      }
    }
    return min;
  }

  static float findMinFloatInColumn(Table t, String columnName) {
    return findMinFloatInColumn(t, t.getColumnIndex(columnName));
  }
  
  static float findMaxFloatInColumn(Table t, int column) {
    float[] values = t.getFloatColumn(column);
    float max = values[0];
    for (int i=0; i<values.length; i++) {
      if (values[i] > max) {
        max = values[i]; 
      }
    }
    return max;
  }

  static float findMaxFloatInColumn(Table t, String columnName) {
    return findMaxFloatInColumn(t, t.getColumnIndex(columnName));
  }

  static public boolean contains(int[] arr, int value) {
    for (int i : arr) {
      if (i == value) {
        return true;
      }
    }
    return false;
  }
  

  static public int[] findRowIndicesForTwoCriteria(Table t, final String value1, final int column1,
                                                   final String value2, final int column2) {
    int[] indices1 = t.findRowIndices(value1, column1);
    int[] indices2 = t.findRowIndices(value2, column2);
    int[] indicesOut = new int[t.getRowCount()];
    int count = 0;
    for (int r=0; r<t.getRowCount(); r++) {
      if ((contains(indices1, r)) && (contains(indices2, r))) {
        indicesOut[count] = r;
        count++;
      }
    }
    return PApplet.subset(indicesOut, 0, count);
  }

  
  static public int[] findRowIndicesForTwoCriteria(Table t, final String value1, final String column1,
                                                   final String value2, final String column2) {
    return findRowIndicesForTwoCriteria(t, value1, t.getColumnIndex(column1), value2, t.getColumnIndex(column2)); 
  }
  
  
  static public void printTable(Table t) {
     for (int r=0; r<t.getRowCount(); r++) {
       TableRow rowValues = t.getRow(r);
       for (int c=0; c<t.getColumnCount(); c++) {
         print(rowValues.getString(c));
         if (c < t.getColumnCount() -1) {
           print(", "); 
         }
       }
       println();
     }
  }
  
}
