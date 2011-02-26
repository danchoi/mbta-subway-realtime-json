require 'yaml'
# Figure out subway locations

predictions = YAML::load(File.read("subway_predictions.yml"))

def reduce(hash)
  { :name => hash[:name.to_s],
    :time => hash[:time.to_s] }
end

r = {}
predictions.each do |line|
    r[line[:line]] = line[:trips].
      select {|t| t[:predictions].size > 1}.
      map { |trip| 
          {:left => reduce( trip[:predictions][0] ), 
            :arriving => reduce(trip[:predictions][1]) }
      }
    
end

# associate with lat, lng

geo_stops = YAML::load(File.open("geo_subway_stops.yml"))

File.open("train_locations.yml", 'w') {|f| f.puts r.to_yaml}



