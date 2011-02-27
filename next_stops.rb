require 'yaml'
require 'json'

t = YAML::load(File.read('train_trajectories.yml'))

out =t.map do |line, trips|
  r = trips.map do |trip|
    trip[:arriving]
  end
end

File.open("next_stops.yml", 'w') {|f| f.puts out.to_yaml}
File.open("next_stops.json", "w")  {|f| f.puts out.to_json}
