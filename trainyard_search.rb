# trainyard_search
# methods for searching trainyard problems for solutions
require_relative "trainyard.rb"

class Trainyard_Search
  # entrance method for ids
  def self.iterative_deepening_search(problem)
    limit = 0
    result = nil
    until result.is_a?(Solution_State)
      limit += 1
      result = depth_limited_search(problem, limit)
    end
    
    return result
  end
  
  # entrance method for dls
  def self.depth_limited_search(problem, limit)
    # start the search at depth 0 with no moves
    # puts "Searching for solution to get from #{problem.state} to #{problem.goal}"
    result = dls_with_solution(problem, Solution_State.new(problem.state, []), limit)
    return result
    
  end
  
  def self.dls_with_solution(problem, sstate, limit)
    return sstate if sstate.state == problem.goal
    #puts "Solution not found in this state #{sstate.state}"
    if sstate.moves.size >= limit
      #puts "Depth limit reached: #{sstate.depth} "
      return :failed_limit_reached
    end
    
    #expand the solution one depth and search all the new states
    dls_search_stack(problem, sstate.expand_solution(problem), limit)
  end
  
  def self.dls_search_stack(problem, sstates, limit)
    #puts "Received #{sstates.size} states in stack to check"
    # for each s state, check it for a solution, else, try the next one
    result = sstates.each{ |sstate|
      depth_result = dls_with_solution(problem, sstate, limit)
      
      #return out of each if we found the solution
      return depth_result if depth_result.is_a?(Solution_State)

    }
    
    # return solution if we found it
    return result if result.is_a?(Solution_State)
    # else return we ran out of stack to check
    return :failed_out_of_moves
  end
  
  def self.print_solution(problem, sstate)
    puts "DLS Solution found in #{sstate.moves.size} moves."
    puts "To get from #{problem.state.to_s} to #{problem.goal.to_s}, apply moves: "
    puts "#{sstate.moves.reverse.to_s}"
  end

end

class Trainyard_Search_Astar
  def self.search_astar(problem, heuristic)
    # curry the heuristic proc with problem arguments
    h_curried = Proc.new {|state| heuristic.calculate_fvalue(state, problem.goal, problem.yard) }
    first_fvalue = h_curried[problem.state]
    #puts "Initial fvalue: #{first_fvalue}"
    fringe_state = Astar_Solution_State.new(
      Solution_State.new(problem.state, []), first_fvalue)
    open_states = [fringe_state]
    closed_states = []
    done = false
    #puts "Initial astar state #{fringe_state.to_s}"
    until done
      result = search_astar_step(problem, open_states, closed_states, h_curried)
      if result == :failed_out_of_moves
        done = true
      elsif result.instance_of?(Astar_Solution_State)
        done = true
      elsif result.instance_of?(Array)
        open_states, closed_states = result
        #puts "New_open: #{open_states.size} new_closed: #{closed_states.size}"
      else
        raise ArgumentError, "Unexpected result of astar search step: #{result.class}"
      end
    end
    
    return result
  end
  
  def self.search_astar_step(problem, fringe, closed, h_curried)
    return :failed_out_of_moves if fringe.size == 0
    first, *rest = *fringe
    return first if first.sstate.state == problem.goal
    
    #puts "#{first} not solution, generating successors"
    successors = first.expand_solution(problem.yard, h_curried)
    #puts "Successors: #{successors.to_s}"
    
    #puts "Creating new fringe from successors and old fringe"
    new_fringe = successors.inject(rest) { |fringe_acc, successor|
      # if it's in the closed list and a bigger fvalue do nothing
      closed_any = closed.any? {|closed_state|
        bool = successor.equal_astar_states(closed_state) && closed_state.fvalue < successor.fvalue
        #puts " closed comparison successor #{successor} to #{closed_state} bool: #{bool}"
        bool
      }
      # if it's in the open list and a bigger fvalue do nothing
      rest_any =  rest.any? {|rest_state|
        bool = successor.equal_astar_states(rest_state) && rest_state.fvalue < successor.fvalue
        #puts "rest comparison successor #{successor} to #{rest_state} bool: #{bool}"
        bool
      }
      #puts "Closed #{closed_any} of #{closed.size} rest #{rest_any} of #{rest.size}"
      if closed_any or rest_any
        #puts "Not pushing successor onto fringe"
        fringe_acc
      else
        # else push it onto the fringe
        [successor] + fringe_acc
      end
    }
    #puts "new_fringe: #{new_fringe}"
    #puts "Sorting and Recursing"
    new_open = new_fringe.sort
    # puts "new_open: #{new_open}"
    new_closed = [first] + closed
    [new_open, new_closed]
    #self.search_astar_rec(problem, new_open, [first] + closed, h_curried)
    
  end
  
  def self.print_astar_solution(problem, sstatea)
    #puts sstatea
    puts "Astar Solution found in #{sstatea.sstate.moves.size} moves."
    puts "To get from #{problem.state.to_s} to #{problem.goal.to_s}, apply moves: "
    puts "#{sstatea.sstate.moves.reverse.to_s}"
  end
end

class Solution_State
  attr_reader :state, :moves
  
  def initialize(state, moves)
    @state = state
    @moves = moves
  end
  
  # returns a set of new solution states, expanded from this state based on the yard
  def expand_solution(problem)
    new_states = possible_moves(problem.yard, state).inject([]){ |acc, move| 
      new_positions = state.apply_move(move)
      # append accumulator array with new sstate unless the new position
      # has already been seen
      acc += [Solution_State.new(
        new_positions,
        [move] + moves )] unless already_seen?(new_positions)
        # remove already_seen solutions
        
      acc
    }
    return new_states
  end
  
  def already_seen?(lookstate)
    # go back through this solutions moves to see if the passed in positions
    # have been seen already
    # start with the current state
    return true if lookstate == state
    
    # clone current state and use it to iterate backward through moves
    current_look = state.clone
    moves.each{|move|
      # go back a state
      return true if lookstate == current_look.reverse_move!(move)
    }
    return false
  end
  
  def to_s
    "#{state.to_s} after moves: #{moves.reverse.to_s}"
  end
end

class Astar_Solution_State
  include Comparable
  attr_reader :fvalue, :sstate
  
  def initialize(sstate, fvalue)
    raise ArgumentError, "sstate must be a Solution_State", caller unless sstate.instance_of?(Solution_State)
    #puts "Initialize astar state"
    @sstate = sstate
    @fvalue = fvalue
  end
  
  # returns a set of new solution states, expanded from this state based on the yard
  def expand_solution(yard, heuristic_proc)
    new_states = possible_moves(yard, sstate.state).inject([]){ |states, move|
      new_state = update_astar_solution_state(move, heuristic_proc)
      # add the new state if not nil
      states += [new_state] if new_state
      states
    }
    return new_states
  end
  
  def update_astar_solution_state(move, heuristic_proc)
    # calculate the new state
    new_positions = @sstate.state.apply_move(move)
    
    return nil if @sstate.already_seen?(new_positions)
    
    # apply the Heuristic
    new_fvalue = @sstate.moves.length + heuristic_proc[new_positions] + 1
    # return a new astar sstate
    return Astar_Solution_State.new(
      Solution_State.new(new_positions, [move] + @sstate.moves), new_fvalue)
  end
  
  def equal_astar_states(other_astar)
    return @sstate.state == other_astar.sstate.state
  end
  
  def <=>(other)
    return nil unless other.instance_of?(Astar_Solution_State)
    @fvalue <=> other.fvalue
  end
    
  def to_s
    "#{@sstate.state.to_s} after #{@sstate.moves.length} moves at current fvalue: #{@fvalue}"
  end
end
