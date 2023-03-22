import numpy as np
import random
from dwave_qbsolv import QBSolv

def import_graph(input_data_array, graph_file_name):
    with open(graph_file_name, 'r') as f:
        text = f.readlines()
        dim_x = len(text) #dim_x = number of rows in array of given file
        #print('the number of rows = ', dim_x)
        #print(text)
        #print('\n', '\n')

        for x in range(dim_x): #iterate through every row in the array
            char_list = (text[x]).split() #create a list of the numbers in the current row (list type = string)
            
            #print('row', x, ': ')
            #print(char_list)

            dim_y = len(char_list)  #dim_y = number of columns/values in current row
            if dim_x != dim_y:
                #print('# of values in row ', x, ' not equal to column dimension ', dim_y)
                quit()

            for y in range(dim_y):  #iterate through every column in a single row
                input_data_array[x][y] = int(char_list[y])   #transfer 1D row data into 2D array of type = int

                #print('input_data_array[',x,'][',y,']', input_data_array[x][y])
            
        #print('input_data_array fully updated = ')
        #print(input_data_array)
    
    return input_data_array


input_graph_array_chip1 = np.zeros((64,64), dtype=np.int8)
input_graph_array_chip1 = import_graph(input_graph_array_chip1, 'dummy.txt')

#print(input_graph_array_chip1)
#print(input_graph_array_chip1[62][2])

h = {(0, 0): 0, (1, 1): 0, (0, 1): 0}
a =1 
b = 0

h[(a, b)] = -10

h.clear()



#print(Q)

j = {(0, 0): 0, (1, 1): 0, (0, 1): 0}
a =1 
b = 0

j[(a, b)] = -10

j.clear()


for x in range(62,3,-1):
	for y in range(59,63-x,-1):
		if ((input_graph_array_chip1[x,y] +input_graph_array_chip1[x-(y-(63-x)),y-(y-(63-x))]) != 0 ):
			j[(63-x, y)] = -1*(input_graph_array_chip1[x,y] + input_graph_array_chip1[x-(y-(63-x)),y-(y-(63-x))])
			#print( '(x,y)', x, y, '(63-x,y)', 63-x, y, 'x-(y-(63-x)), y-(y-(63-x))', x-(y-(63-x)), y-(y-(63-x)))
                        #print( 'j[(63-x, y)]', j[(63-x, y)])
 
		
#print('test\n')		
#print(j)
#print('test1\n')		
#print(h)

response = QBSolv().sample_ising(h,j, timeout=180)
response_list = list(response.samples())
print(response_list)
#print(list(response.data_vectors['energy']))

print("energies=" + str(list(response.data_vectors['energy'])))
		
