require 'json'
require 'yaml'
require 'open-uri'
res = JSON.parse(open("http://civicapi.com/bos_rail/all").read)
r = {}


res["features"].each do |f|
  p = f["properties"]['properties']
  # not sure if this destroys any info, but we need to eliminate extra nesting that occurs sometimes
  g = f["geometry"]["coordinates"]
  if g[0][0].is_a?(Array) # should be a float; flatten
    puts "flattening extra nested array"
    g = g.flatten(1)
  end
  (r[p["LINE"]] ||= []) << {:shape_len => p["Shape_len"], :geometry => g}
end

# TODO join any polylines in a LINE that are connected
puts "Joining polylines"
r.each do |key, shapes| 
  puts key.inspect
  puts shapes.size
  endpts = {}
  startpts = {}
  new_shapes = []
  shapes.each do |s|
    a = [ s[:geometry][0][0], s[:geometry][0][1] ]
    b = [ s[:geometry][-1][0], s[:geometry][-1][1] ]
    puts "%s -> %s" % [a, b]
    startpts[a] = s
    endpts[b] = s 
  end
  shapes.each do |s|
    a = s[:geometry][0]
    b = s[:geometry][-1]
    if n = endpts[a] 
      puts "Connecting shapes via endpoint"
      new_shape = {
        :shape_len => (n[:shape_len] + s[:shape_len]),
        :geometry => ( n[:geometry] + s[:geometry]),
        :merged => true
      }
      new_shapes << new_shape
    end
    if n = startpts[b]
      puts "Connecting shapes via startpoint"
      new_shape = {
        :shape_len => (s[:shape_len] + n[:shape_len]  ),
        :geometry => ( s[:geometry] + n[:geometry] ),
        :merged => true
      }
    end
  end
  r[key] = shapes + new_shapes
end


File.open('polylines.yml', 'w') {|f| f.write r.to_yaml}
File.open('polylines.json', 'w') {|f| f.write r.to_json}


