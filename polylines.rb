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
File.open('polylines.yml', 'w') {|f| f.write r.to_yaml}
File.open('polylines.json', 'w') {|f| f.write r.to_json}
