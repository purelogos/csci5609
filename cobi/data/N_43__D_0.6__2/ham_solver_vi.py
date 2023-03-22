import numpy as np
import random

#import graph same as in the main_test.py
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
                print('# of values in row ', x, ' not equal to column dimension ', dim_y)
                quit()

            for y in range(dim_y):  #iterate through every column in a single row
                input_data_array[x][y] = int(char_list[y])   #transfer 1D row data into 2D array of type = int

                #print('input_data_array[',x,'][',y,']', input_data_array[x][y])
            
        #print('input_data_array fully updated = ')
        #print(input_data_array)
    
    return input_data_array

#majority vote software
def majority_vote(input_file, sample_col):
    #create a temp graph to store the majority vote values
	solution_graph = np.zeros((63), dtype=np.int8)
    
    #read in the sample results from the chip
	with open(input_file, 'r') as f:
		text = f.readlines()	
	
	#iterate through the sample results and take the majority vote each snapshot
	for x in range(0,59):
		majority_vote_counter = 0
		for y in range(0,8):
			sample_line = text[41+x*10+y].replace(" ", "")
			
			if(sample_line[sample_col] == '1'):
				majority_vote_counter = majority_vote_counter + 1
				#print(majority_vote_counter)
        
        #decide based on the samples whether the spin is a 1 or -1
		if(majority_vote_counter < 5):
			solution_graph[x+4] = 1
		else:
			solution_graph[x+4] = -1
	
	return solution_graph


#variables that are to be changed
#samples taken is how many hamilitonians will be solved, best qubo comes from the qubo solver
samples_taken = 100
best_qubo_solution = -156
#set to 1 to print every ham
print_each_ham = 0
#set to 1 to print final succes probability
sucess_probability_print = 1
#set to 1 to print best hamilitonian
best_ham_print = 1
#set to 1 to print hamilitonian average
average_print = 1

#starting the software
input_graph_array_chip1 = np.zeros((64,64), dtype=np.int8)
input_graph_array_chip1 = import_graph(input_graph_array_chip1, 'dummy.txt')

ham_best = 0
counter_percentage = 0
ham_average = 0
solution_best = np.zeros((63), dtype=np.int8)
for w in range(0,samples_taken):
    majority_vote_array = majority_vote('chip2_test.txt', w)

    
    ham_solution = 0
    for x in range(62,3,-1):
        for y in range(59,63-x,-1):
            if ((input_graph_array_chip1[x,y] +input_graph_array_chip1[x-(y-(63-x)),y-(y-(63-x))]) != 0 ):
                j = input_graph_array_chip1[x,y] +input_graph_array_chip1[x-(y-(63-x)),y-(y-(63-x))]
                ham_solution = ham_solution + -1*(input_graph_array_chip1[x,y] + input_graph_array_chip1[x-(y-(63-x)),y-(y-(63-x))])*majority_vote_array[x]*majority_vote_array[63-y]
    
    if(ham_solution  <best_qubo_solution*0.95):
        counter_percentage = counter_percentage + 1
    
    ham_average = ham_average + ham_solution
    if(print_each_ham == 1):
        print("Sample " + str(w) + ":" + str(ham_solution))
    if(ham_best > ham_solution):
        ham_best = ham_solution
        solution_best = majority_vote_array

outline = "{["
for w in range(0,60):
    if(input_graph_array_chip1[63][w] == 1):
        #print ("nodes" + str(w) + ":\tspin " + str(solution_best[63-w]))
        if(w > 1):
            outline = outline +", "
        outline = outline + str(w)+": "+ str(solution_best[63-w])
outline = outline + "}]"
print(outline)

#print out the statistics
if(best_ham_print == 1):
    print('Best Ham: ' + str(ham_best))
    print(solution_best)
if(sucess_probability_print == 1):
    print('Sucess Probability: ' + str(counter_percentage))
if(average_print == 1):
    print('Ham Average: ' +str(ham_average/samples_taken))


