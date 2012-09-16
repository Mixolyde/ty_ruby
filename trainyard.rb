#!/usr/bin/ruby -d

# train switch yard AI programming assignment
# assignment: http://www.cis.udel.edu/~decker/courses/681s07/prog1.html

class Yard < Array
  # an array that looks like [[:t1, :t2], [:t1, :t3], [:t3, :t5], [:t4, :t5], [:t2, :t6], [:t5, :t6]]
  # which says that :t1 is paired to :t2, etc

  def initialize(tracks)
    raise ArgumentError, "Argument must be an array of track connections", caller unless tracks.instance_of?(Array)
    tracks.each{|track|
      raise ArgumentError, "Each track must be an array", caller unless track.instance_of?(Array)
      raise ArgumentError, "Each track array must be size 2", caller unless track.size == 2
    }
    super(tracks)
  end
  
  # return a list of all possible, not necessarily legal, moves for this yard
  def all_moves
    inject([]) { |accum, track | accum << [:left, track[1], track[0]] << [:right, track[0], track[1]] }
  end
  
  # Class methods used to generate test yards
  def self.all_yards
    [Yard.yard1, Yard.yard2, Yard.yard3, Yard.yard4]
  end
  
  def self.yard1
    self.new([[:t1, :t2], [:t1, :t3], [:t3, :t5], [:t4, :t5], [:t2, :t6], [:t5, :t6]])
  end

  def self.yard2
    self.new([[:t1, :t2], [:t2, :t3], [:t2, :t4], [:t1, :t5]])
  end

  def self.yard3
    self.new([[:t1, :t2], [:t1, :t3]])
  end
  
  def self.yard4
    self.new([[:t1, :t2], [:t1, :t3], [:t1, :t4]])
  end

  def list_tracks
    track_hash = inject({}){ |hash, (track1, track2)| hash[track1] = :track; hash[track2] = :track; hash}
    track_hash.keys
  end
  
  def get_neighbor_tracks(track)
    inject([]) {|neighbors, (left, right)|
      #for each track, if the left or right is the requested track
      #add the other to the neighbor list
      if track == left
        [right] + neighbors
      elsif track == right
        [left] + neighbors
      else
        neighbors
      end
    }

  end
end

class State < Hash
  # a state is a hash like: {:t1=>[:engine], :t2=>[:d], :t3=>[:b], :t4=>[:a, :e], :t5=>[:c]}
  # stating the :engine is on track 1, etc
  
  def cars_on_track(track)
    return fetch(track) if fetch(track, nil)
    return []
  end
  
  def apply_move!(move)
    replace(apply_move(move))
    self
  end
  
  def apply_move(move)
    case move[0]
    when :right
      ltrack = move[1]
      rtrack = move[2]
      return shift_car(ltrack, rtrack, -1)
    when :left
      ltrack = move[2]
      rtrack = move[1]
      return shift_car(ltrack, rtrack, 1)
    else
      raise ArgumentError, "Not a valid move", caller
    end
  end
  
  def reverse_move!(move)
    replace(reverse_move(move))
    self
  end
  
  def reverse_move(move)
    #puts "Reversing #{move} on #{self.positions}"
    case move[0]
    when :right #[:right left toright]
      return apply_move([:left, move[2], move[1]])
    when :left #[:left right to left]
      #puts "Applying #{[:right, move[2], move[1]]}"
      return apply_move([:right, move[2], move[1]])
    else
      raise ArgumentError, "Not a valid move", caller
    end
  end
  
  def update_track!(track, cars)
    replace(update_track(track, cars))
    self
  end
  
  def update_track(track, cars)
    newpositions = self.clone
    case cars
    when []
      newpositions.delete(track)
    else
      newpositions[track] = cars
    end
    State[newpositions]
  end
  
  def shift_car!(ltrack, rtrack, shift_amount)
    replace(shift_car(ltrack, rtrack, shift_amount))
    self
  end
  
  def shift_car(ltrack, rtrack, shift_amount)
    joinedtracklist = self.cars_on_track(ltrack) + self.cars_on_track(rtrack)
    leftcarscount = self.cars_on_track(ltrack).size
    newleftcars, newrightcars = joinedtracklist.partition.with_index{|e,idx| idx < leftcarscount + shift_amount }
    #puts "New Left: #{newleftcars.to_s} New Right: #{newrightcars.to_s}"
    newState = self.update_track(ltrack, newleftcars).update_track(rtrack, newrightcars)
    return newState  
  end
  
  def locate_car(car)
    each(){| (track, track_cars) |
      return track if track_cars.member?(car)
    }
    :error_car_not_found
  end
  
end

class Problem
  attr_reader :yard, :state, :goal
  
  def initialize(yard, state, goal)
    raise ArgumentError, "yard must be a Yard", caller unless yard.instance_of?(Yard)
    raise ArgumentError, "state must be a State", caller unless state.instance_of?(State)
    raise ArgumentError, "goal must be a State", caller unless goal.instance_of?(State)
    @yard = yard
    @state = state
    @goal = goal
  end
  
  def to_s
    "Yard: " + @yard.to_s + " State: " + @state.to_s + " Goal: " + @goal.to_s
  end
  
  def self.all_problems
    [self.problem1, self.problem1, self.problem1, self.problem1, self.problem1]
  end
  
  def self.problem1
      self.new(Yard.yard1(),
        # {t1, [engine]}, {t2, [e]}, {t4, [b, c, a]}, {t6, [d]}
        State[:t1, [:engine], :t2, [:e], :t4, [:b, :c, :a], :t6, [:d]],
        State[:t1, [:engine, :a, :b, :c, :d, :e]] )
  end
  
  def self.problem2
    self.new(Yard.yard2(),
      State[ {:t1=>[:engine], :t2=>[:d], :t3=>[:b], :t4=>[:a, :e], :t5=>[:c]} ],
      State[ {:t1=>[:engine, :a, :b, :c, :d, :e]} ])
  end  
  
  def self.problem3
    self.new(Yard.yard3(),
      State[:t1, [:engine], :t2, [:a], :t3, [:b]],
      State[:t1, [:engine, :a, :b]] )
  end

  def self.problem4
    self.new(Yard.yard4(),
      State[:t1, [:engine], :t2, [:a], :t3, [:b, :c], :t4, [:d]],
      State[:t1, [:engine, :a, :b, :c, :d]] )
  end

  def self.problem5
    self.new(Yard.yard4(),
      State[:t1, [:engine], :t2, [:a], :t3, [:c, :b], :t4, [:d]], # note, b and c are out of order
      State[:t1, [:engine, :a, :b, :c, :d]] )
  end
end

def illegal_move?(move, yard, state)
  # move = [:left, :t1, :t2]
  #puts "Testing: " + move.to_s + " in yard: " + yard.to_s + " in state: " + state.to_s

  case move[0]
  when :left
    right = move[1]
    left = move[2]
    # test that there's something to move
    # puts "Right: " + right.to_s + " " + state.positions[right].to_s
    return true unless state[right]
  when :right
    right = move[2]
    left = move[1]
    return true unless state[left]
  else
    return true
  end
  
  #puts "left: " + left.to_s + " right: " + right.to_s
  # test that tracks are connected
  return true if not yard.include?([left, right])
  # test that engine is on one of the tracks  
  return true if not state.cars_on_track(left).include?(:engine) and 
    not state.cars_on_track(right).include?(:engine)
  # else it's a legal move
  return false
  
end

def possible_moves(yard, state)
  yard.all_moves.select{ |move| (not illegal_move?(move, yard, state)) }
end

def expand(yard, state)
  return possible_moves(yard, state).collect{ |move| state.apply_move(move) }
end