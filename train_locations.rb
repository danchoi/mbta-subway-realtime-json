require 'yaml'
# Figure out subway locations

predictions = YAML::load(File.read("subway_predictions.yml"))

def reduce(hash)
  { 
    :name => hash[:name.to_s],
    :time => hash[:time.to_s] 
  }
end

# associate with lat, lng
GEO_STOPS = YAML::load(File.open("geo_subway_stops.yml"))

def geo(line, name)
  x = GEO_STOPS[line.upcase].detect {|x|
    name.sub(/ Station$/, '').upcase == x[0]
  }
  x ? x[1..-1] : nil
end

r = {}
predictions.each do |line|
    r[line[:line]] = line[:trips].
      select {|t| t[:predictions].size > 1}.
      map { |trip| 
        left = reduce( trip[:predictions][0] )
        arr = reduce( trip[:predictions][1] )
        left[:geo] = geo(line[:line], left[:name])
        arr[:geo] = geo(line[:line], arr[:name])
        { :left => left, :arriving => arr }
      }
end


File.open("train_locations.yml", 'w') {|f| f.puts r.to_yaml}



