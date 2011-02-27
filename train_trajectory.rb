# this is the main function
require 'yaml'

locations = YAML::load(File.read('train_locations.yml'))
polylines = YAML::load(File.read('polylines_stops.yml'))

# a and b are coordinates
def close(a, b)
  a[0] == b[0] ||
    a[1] == b[1] ||
     ( (a[0] - b[0]).abs < 0.001 && (a[1] - b[1]).abs < 0.001 )
end

locations.each do |line, trains|
  trains.each do |train|
    # find the polyline that the train is on
    x = train[:left]
    y = train[:arriving]
    matched_shape = polylines[line.upcase].detect {|shape|
      shape[:geometry].detect {|vertex| 
        lat,lng,stop = *vertex 
        # puts x.inspect
        lat == x[:geo][0] && lng == x[:geo][1] || close(x[:geo], [lat,lng])
      }
    }
    train = "#{line} train"
    if matched_shape
      puts "Matched shape for #{train} that left #{x[:name]}"
    else
      puts "# No matched shape for #{train} that left #{x[:name]}"
    end
  end
end

nil

