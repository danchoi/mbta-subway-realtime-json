require 'json'
require 'yaml'

geo_stops = YAML::load(open("geo_subway_stops.yml").read)
polylines = YAML::load(open("polylines.yml").read)

# a and b are coordinates
def close(a, b)
  a[0] == b[0] ||
    a[1] == b[1] ||
     ( (a[0] - b[0]).abs < 0.001 && (a[1] - b[1]).abs < 0.001 )
rescue
  puts "Error: #{a.inspect} #{b.inspect}"
  raise
end


polylines.each do |line, segs|
  puts line
  puts "  %s segments " % segs.size
  puts "  %s vertices " % segs.reduce(0) {|sum, s| sum + s[:geometry].size}
  puts "  %s stops" % geo_stops[line].size
  # match vertices to stops
  # create a dictionary from geo_subway_stops keyed by lat,lng
  dict = {}
  geo_stops[line].each do |stop|
    lat = stop[1]
    lng = stop[2]
    name = stop[0]
    dict[ [line, lat, lng] ] = name
  end
  puts "  Created geo stop dictionary. Matching..."
  matched = [] # contains stops that were matched
  segs.each do |seg|
    # puts seg.inspect
    seg[:geometry].each do |vertex|
      # puts vertex.inspect
      # puts vertex.inspect
      key = [ line, vertex[0], vertex[1] ]
      if match = dict[ key ]
        puts "  MATCH #{key} => #{match}"
        if vertex.size == 2
          vertex << dict[key]
          matched << match 
        end
        # flag this key as aleady matched
      end
    end
  end
  segs.each do |seg|
    # puts "  No exact match for #{key}. Trying to find closest."
    seg[:geometry].each do |vertex|
      key = [ line, vertex[0], vertex[1] ]
      dict.each do |k, value|
        next if matched.include?(value)
        stop, lat, lng = *k
        if close([lat, lng], [ vertex[0], vertex[1] ] )
          # TODO fix later to get closest match
          puts "  CLOSE match #{key} => #{value.inspect}"
          if vertex.size == 2
            vertex << value
            matched << value
          end
        end
      end
    end
  end

  nil
end

puts "Writing polylines_stops.(yml|json)"
File.open('polylines_stops.yml', 'w') {|f| f.write polylines.to_yaml}
File.open('polylines_stops.json', 'w') {|f| f.write polylines.to_json}

File.open('polylines_stops.json', 'w') {|f| 
  polylines.each do | line, shapes |
    puts line
    shapes.each do |s|
      puts "  " + s[:geometry].select {|x| x.size > 2}.map {|x| x[2]}.inspect
    end
  end

}



