
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

def astar_bench
  time = Benchmark.realtime do
      result = Trainyard_Search_Astar.search_astar(Problem.problem5, NotOnGoalCount)
      Trainyard_Search.print_solution(Problem.problem5, result)
    end
  puts "A* Problem5 Time NotOnGoalCount elapsed #{time*1000} milliseconds"
end

ids_bench
astar_bench