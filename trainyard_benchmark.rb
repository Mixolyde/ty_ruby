
require "benchmark"
require_relative "trainyard.rb"
require_relative "trainyard_heuristic.rb"
require_relative "trainyard_search.rb"

def ids_bench(desc, problem)
  time = Benchmark.realtime do
    result = Trainyard_Search.iterative_deepening_search(problem)
    Trainyard_Search.print_solution(problem, result)
  end
  puts "IDS #{desc} elapsed #{time*1000} milliseconds"
  time
end

def astar_bench(desc, problem, heuristic)
  time = Benchmark.realtime do
      result = Trainyard_Search_Astar.search_astar(problem, heuristic)
      Trainyard_Search_Astar.print_astar_solution(problem, result)
    end
  puts "A* #{desc} elapsed #{time*1000} milliseconds"
  time
end

ids_report = (3..5).each(){ |number|
  time = ids_bench "Problem #{number}", Problem.send(:"problem#{number}")
  [number, time]
}

begin 
  astar_report_goal = (2..5).each(){ |number|
    time = astar_bench "Problem #{number}, NotOnGoalCount", Problem.send(:"problem#{number}"), NotOnGoalCount
    [number, time]
  }
  
  astar_report_dijkstra = (2..5).each(){ |number|
      time = astar_bench "Problem #{number}, Dijkstra_Sum", Problem.send(:"problem#{number}"), Dijkstra_Sum
      [number, time]
  }
  
rescue Error => e
  e.inspect
  e.backtrace
end