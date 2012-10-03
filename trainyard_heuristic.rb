
class NotOnGoalCount
  def self.calculate_fvalue(state, goal, yard)
    # for each track in the goal, check its cars for their position
    goal.inject(0){ |sum, (key, value)|
      # puts "Sum: #{sum} Counting cars: #{value} on track: #{key}"
      # for each car on the track, check the matching track for it
      sum += value.inject(0) {|sumt, car|
        sumt += 1 unless state.cars_on_track(key).include?(car)
        sumt
      }
      
    }
    
  end
end

# sum the distance of every car not on its goal track to the goal
class Dijkstra_Sum
  def self.calculate_fvalue(state, goal, yard)
    track_distances = dijkstra_all(yard)
    #puts "Dijkstra distance hash: #{track_distances}"
    
    #for each track in the goal state, get the distance of each element to
    #where it is in the current State and sum those
    #initial sums are 0
    
    dijkstra_total = goal.inject(0){|sum, (goal_track, goal_cars) |
      goal_cars.each(){|goal_car|
        #puts "Locating #{goal_car} in current_state"
        goal_distance = track_distances[goal_track][state.locate_car(goal_car)]
        sum += goal_distance
      }
      sum
    }
    
    dijkstra_total
    
    #    + out_of_order_score(State, Goal, Yard)
  end
  
  def self.dijkstra_all(yard)
    tracks = yard.list_tracks
    dijkstra_hash = {}
    tracks.each{ |track| dijkstra_hash[track] = dijkstra(track, yard) }
    dijkstra_hash
  end
  
  def self.dijkstra(track, yard)
    tracks_to_count = yard.list_tracks - [track]
    distance_hash = Hash[track, 0]
    open_list = get_neighbor_distances(yard, track, 0)
    #puts "Starting dijkstra distance: #{distance_hash} open: #{open_list}"
    until tracks_to_count.size == 0 or open_list.size == 0
      #puts "Current dijkstra distance: #{distance_hash} open: #{open_list}"
      # add current open node to the distance list
      (track, distance) = open_list.shift
      distance_hash[track] = distance
      # remove processed track from to_count list
      tracks_to_count -= [track]   
      neighbor_distances = get_neighbor_distances(yard, track, distance)
      #puts "new neighbor distances: #{neighbor_distances}"
      # for each neighbor, add it to the open list, if not already present
      neighbor_distances.map{|(neighbor, neighbor_distance)|
        # if open list and  not contain the neighbor, add it
        open_list += [[neighbor, neighbor_distance]] if
          open_list.none?{ |open_neighbor|
            open_neighbor.first == neighbor
          } and
          not distance_hash.key?(neighbor)
        
      }
    end
    # return the completed distance_hash
    distance_hash

  end
  
  def self.get_neighbor_distances(yard, track, initial_distance)
    yard.get_neighbor_tracks(track).inject([]) {|list, neighbor_track|
      list += [[neighbor_track, initial_distance + 1]]
    }
  end
end

class Out_Of_Order
  def self.calculate_fvalue(state, goal, yard)
    #for each track in the goal state with cars on it
    ooo_total = goal.inject(0) {|sum, (goal_track, goal_cars) |
      current_cars = state.cars_on_track(goal_track)
      #if there are enough cars to consider in goal_cars and current_cars, check for out of order
      if goal_cars.length > 1 and current_cars.length > 0 and goal_cars != current_cars
        sum += out_of_order_track(current_cars, goal_cars)
      end
      # return current sum to the accumulator
      sum
    }
    ooo_total
  end
  
  # (* 1 2 3 4 5)  goal
  # (5 4 3 2 1 *)  current  
  def self.out_of_order_track(track_cars, goal_cars)
    return 0 if goal_cars.length < 2 or track_cars.length < 1
    #for each goal_car
    current_goal_cars = goal_cars.clone
    # starting sum
    sum = 0
    
    until current_goal_cars.length == 0
      current_goal_car = current_goal_cars.shift
      # if the goal car appears in current track
      goal_index = track_cars.index(current_goal_car)
      if goal_index
        # for each of the cars after the goal car 
        sum += current_goal_cars.inject(0){ |checksum, goal_car_check|
          # if they appear in the current track before the goal car 
          # they are out of order
          check_index = track_cars.index(goal_car_check)
          if check_index and check_index < goal_index
            checksum += 1
          end
          checksum
        }
      end
    end
    # return the total out of order count
    sum
  end
  
    def self.out_of_order_track_2(track_cars, goal_cars)
      return 0 if goal_cars.length < 2 or track_cars.length < 1
      #for each track_car
      
      track_sum = track_cars.inject(0){ |sum, track_car|
        if goal_cars.member?(track_car) and 
          track_cars.index(track_car) != goal_cars.index(track_car)
          sum += 2
        end
        sum
      }
      
      track_sum
      
    end

end

class DSumAndOOO
  def self.calculate_fvalue(state, goal, yard)
    # add the sum to the out of order count for the best heuristic EVAR!
    Dijkstra_Sum.calculate_fvalue(state, goal, yard) + Out_Of_Order.calculate_fvalue(state, goal, yard)
  end

end