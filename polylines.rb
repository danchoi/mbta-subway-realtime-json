require 'json'
require 'yaml'
require 'open-uri'
res = JSON.parse(open("http://civicapi.com/bos_rail/all").read)
r = {}
res["features"].each do |f|
  p = f["properties"]['properties']
  g = f["geometry"]["coordinates"]
  (r[p["LINE"]] ||= []) << {:shape => p["Shape_len"], :geometry => g}
end
File.open('polylines.yml', 'w') {|f| f.write r.to_yaml}
File.open('polylines.json', 'w') {|f| f.write r.to_json}
