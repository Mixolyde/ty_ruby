
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
    dijkstra_total = goal.inject(0){|sum, (goal_track, goal_cars) |
    
    }
  end
end