
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
    puts track_distances
    # io:format("Got all track distances to other tracks~n~w~n", [TrackDistances]),
    #for each track in the goal state, get the distance of each element to
    #where it is in the current State and sum those
    #initial sums are 0
    #get current location of the engine and distances from that track for computing heuristic
    #lists:foldl(fun({Track, Cars}, Sum) ->
    #    {Track, CurrentDistances} = lists:keyfind(Track, 1, TrackDistances),
    #    lists:foldl(fun(Car, TrackSum) ->
    #        CurrentTrack = locate_car(Car, State),
    #        {CurrentTrack, Distance} = lists:keyfind(CurrentTrack, 1, CurrentDistances),
    #        %add this distance to the current sum and fold
    #        Distance  + TrackSum
    #    end, 0, Cars)
    #    + Sum end, 0, Goal)
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
    #puts "tocount: #{tracks_to_count}"
    [track, :trackname]
    
  end
end