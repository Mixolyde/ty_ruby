
require "benchmark"
require_relative "trainyard.rb"
require_relative "trainyard_heuristic.rb"
require_relative "trainyard_search.rb"

def ids_bench(problem)
  result = Trainyard_Search.iterative_deepening_search(problem)
  #Trainyard_Search.print_solution(problem, result)
end

def astar_bench(problem, heuristic)
  result = Trainyard_Search_Astar.search_astar(problem, heuristic)
  #Trainyard_Search_Astar.print_astar_solution(problem, result)
end

begin 
  Benchmark.bm(20) do |x|
    (3..5).each(){ |number|
      x.report("IDS #{number}")   { 
        ids_bench Problem.send(:"problem#{number}")
      }
    }
    (3..5).each(){ |number|
      x.report("A* #{number} NotOnGoalCount")   { 
        astar_bench Problem.send(:"problem#{number}"), NotOnGoalCount
      }
    }
    (2..5).each(){ |number|
      x.report("A* #{number} Dijkstra_Sum")   { 
        astar_bench Problem.send(:"problem#{number}"), Dijkstra_Sum
      }
    }
    (1..5).each(){ |number|
          x.report("A* #{number} DSumAndOOO")   { 
            astar_bench Problem.send(:"problem#{number}"), DSumAndOOO
          }
    }

end
  
rescue Error => e
  e.inspect
  e.backtrace
end