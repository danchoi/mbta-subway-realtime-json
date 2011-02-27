require 'json'
require 'yaml'

geo_stops = YAML::load(open("geo_subway_stops.yml").read)
polylines = YAML::load(open("polylines.yml").read)

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
  segs.each do |seg|
    # puts seg.inspect
    seg[:geometry].each do |vertex|
      # puts vertex.inspect
      puts vertex.inspect
      key = [ line, vertex[0], vertex[1] ]
      if dict[ key ]
        puts "  Found match for #{dict[key]}"
        vertex << dict[key]
      end
    end
  end
  nil
end

puts "Writing polylines_stops.(yml|json)"
File.open('polylines_stops.yml', 'w') {|f| f.write polylines.to_yaml}
File.open('polylines_stops.json', 'w') {|f| f.write polylines.to_json}

