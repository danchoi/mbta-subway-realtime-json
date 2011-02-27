require 'yaml'
require 'json'

t = YAML::load(File.read('train_trajectories.yml'))

res = {}
out = t.map do |line, trips|
  res[line] = trips.map do |trip|
    trip[:arriving]
  end
end

File.open("next_stops.yml", 'w') {|f| f.puts res.to_yaml}
File.open("next_stops.json", "w")  {|f| f.puts res.to_json}
