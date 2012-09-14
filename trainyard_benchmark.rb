
require "benchmark"
require_relative "trainyard.rb"
require_relative "trainyard_heuristic.rb"
require_relative "trainyard_search.rb"

def ids_bench
  time = Benchmark.realtime do
    result = Trainyard_Search.iterative_deepening_search(Problem.problem2)
    Trainyard_Search.print_solution(Problem.problem2, result)
  end
  puts "IDS Problem2 Time elapsed #{time*1000} milliseconds"
end

def astar_bench(desc, problem, heuristic)
  time = Benchmark.realtime do
      result = Trainyard_Search_Astar.search_astar(problem, heuristic)
      Trainyard_Search_Astar.print_astar_solution(problem, result)
    end
  puts "A* #{desc} elapsed #{time*1000} milliseconds"
end

#ids_bench
begin 
  #astar_bench "Problem 1, NotOnGoalCount", Problem.problem1, NotOnGoalCount
  astar_bench "Problem 2, NotOnGoalCount", Problem.problem2, NotOnGoalCount
  astar_bench "Problem 3, NotOnGoalCount", Problem.problem3, NotOnGoalCount
  astar_bench "Problem 4, NotOnGoalCount", Problem.problem4, NotOnGoalCount
  astar_bench "Problem 5, NotOnGoalCount", Problem.problem5, NotOnGoalCount
rescue e
  e.inspect
  e.backtrace
end