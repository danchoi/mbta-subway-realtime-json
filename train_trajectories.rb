# this is the main function
require 'yaml'
require 'json'
$:.unshift File.dirname(__FILE__)
require 'haversine'

locations = YAML::load(File.read('train_locations.yml'))
polylines = YAML::load(File.read('polylines_stops.yml'))

# a and b are coordinates
def close(a, b)
  a[0] == b[0] ||
    a[1] == b[1] ||
     ( (a[0] - b[0]).abs < 0.001 && (a[1] - b[1]).abs < 0.001 )
end

# reverses the polyline if necessary
def correct_direction(orig, dest, shape)
  orig_idx = nil
  dest_idx = nil
  shape[:geometry].each_with_index do |x, i|
    name =  x[2]
    if orig == name && orig_idx.nil?
      orig_idx = i
    elsif dest == name && dest_idx.nil?
      dest_idx = i
    end
  end
  shape[:orig_idx] = orig_idx
  shape[:dest_idx] = dest_idx
  # puts "  %s -> %s" % [orig_idx, dest_idx]
  reverse = false
  if orig_idx == nil && dest_idx == nil
    puts "  ## No stop matches for #{orig} -> #{dest}"
    return shape[:geometry]
  elsif orig_idx == nil || dest_idx == nil
    puts "  * Only one stop match for #{orig} -> #{dest}"
    return nil
  elsif orig_idx > dest_idx
    # cut off everything before the dest_idx
    puts "Reversing for #{orig} -> #{dest}"
    return shape[:geometry][(dest_idx)..(orig_idx)].reverse
  else
    # cut off everything after the dest_idx 
    return  shape[:geometry][orig_idx..(dest_idx + 1)]
  end
end

locations.each do |line, trains|
  trains.each do |train|
    begin
      # find the polyline that the train is on
      x = train[:left]
      y = train[:arriving]
      matched_shape = polylines[line.upcase].detect {|shape|
        shape[:geometry].detect {|vertex| 
          lat,lng,stop = *vertex 
          stop == x[:name] ||
            (lat == x[:geo][0] && lng == x[:geo][1]) || 
              close(x[:geo], [lat,lng])
        } && shape[:geometry].detect {|vertex| 
          lat,lng,stop = *vertex 
          stop == y[:name] ||
            (lat == y[:geo][0] && lng == y[:geo][1]) || 
              close(y[:geo], [lat,lng])
        } 
      }
      trainstr = "#{line} line train"
      if matched_shape
        puts "Matched shape for #{trainstr}: #{x[:altname]} -> #{y[:altname]}"
        # Decorate the location with a trajectory:
        res = correct_direction(x[:altname], y[:altname], matched_shape)
        if res
          train[:trajectory] = res
        end
      else
        puts "  # No matched shape for #{trainstr}: #{x[:altname]} -> #{y[:altname]}"
        train[:error] = "No polyline matched"
      end
      train[:interval] = y[:time] - x[:time] 
      dist = 0
      train[:trajectory].each_cons(2) {|x, y|
        lat1,lng1 = *x
        lat2,lng2 = *y
        # puts "%s %s => %s %s" % [lat1,lng1, lat2,lng2]
        dist = haversine_distance( lat1, lng1, lat2, lng2)
      }
      train[:distance] =dist

    rescue
      puts "ERROR for train #{train.inspect}: #{$!}"
    end
  end
end


File.open("train_trajectories.yml", 'w') {|f| f.puts locations.to_yaml}
File.open("train_trajectories.json", "w")  {|f| f.puts locations.to_json}

