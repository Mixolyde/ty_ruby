Ruby solution to a fun Artifical Intelligence homework assignment

The assignment can be found online at:

http://www.cis.udel.edu/~decker/courses/681s07/prog1.html

Files:
* trainyard - basic data structures and utility methods for yards, states and problems
* trainyard_search - data structures and methods for iterative deepening search and a* search
* trainyard_heuristic - heuristics for a* search
* trainyard_test - unit tests for all of the above
* trainyard_benchmark - simple timing methods for benchmarking the search solutions

I'm considering this project done, althought nearly ten minutes for the big problem
isn't great. There are other problems to solve!

Statistics from the benchmark:

				   user     system      total        real
	IDS 3                  0.000000   0.000000   0.000000 (  0.000000)
	IDS 4                  0.000000   0.000000   0.000000 (  0.004500)
	IDS 5                  0.062000   0.000000   0.062000 (  0.058508)
	A* 3 NotOnGoalCount    0.000000   0.000000   0.000000 (  0.000000)
	A* 4 NotOnGoalCount    0.000000   0.000000   0.000000 (  0.002500)
	A* 5 NotOnGoalCount    0.047000   0.000000   0.047000 (  0.052507)
	A* 2 Dijkstra_Sum      5.803000   0.000000   5.803000 (  5.806237)
	A* 3 Dijkstra_Sum      0.000000   0.000000   0.000000 (  0.001000)
	A* 4 Dijkstra_Sum      0.000000   0.000000   0.000000 (  0.011502)
	A* 5 Dijkstra_Sum      0.093000   0.000000   0.093000 (  0.082010)
	A* 1 DSumAndOOO      570.605000   0.156000 570.761000 (572.897749)
	A* 2 DSumAndOOO        3.089000   0.000000   3.089000 (  3.091393)
	A* 3 DSumAndOOO        0.000000   0.000000   0.000000 (  0.001000)
	A* 4 DSumAndOOO        0.000000   0.000000   0.000000 (  0.008001)
	A* 5 DSumAndOOO        0.031000   0.000000   0.031000 (  0.028503)
	
