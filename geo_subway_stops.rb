# generates a YAML of the stop coordinates
require 'json'
require 'yaml'
require 'open-uri'

json = open("http://civicapi.com/bos_t_stops/all").read

res = JSON.parse(json)
r = res['features'].map do |x|
  geo = x['geometry']['coordinates']
  line = x['properties']['properties']['LINE']
  station = x['properties']['properties']['STATION']
  {'geo' => geo, 'line' => line, 'station' => station}
end
s = {}
r.group_by {|x| x['line']}.
  # select {|line, stops| line.split("/").size == 1}.
  each {|line, stops|
    s[line] = stops.map {|x| [x['station'], x['geo']].flatten }
  }
r.group_by {|x| x['line']}.
  select {|line, stops| line.split("/").size == 2}.
  each {|line, stops|
    line.split("/").each do |x|
      s[x] += stops.map {|x| [x['station'], x['geo']].flatten }
    end
  }  

File.open("geo_subway_stops.yml", 'w') {|f| f.puts s.to_yaml}

