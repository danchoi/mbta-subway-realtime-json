require 'yaml'
require 'json'
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

def fix_name(name)
  name = case name 
         when /North Station/i
           name 
         when  /Massachusetts Ave. Station/
           "MASSACHUSETTS AVE"
         when  /State St. Station/
           "STATE"
         else
           name.sub(/ Station$/, '').upcase
         end
  name = case name 
         when /Harvard Square/i
           'HARVARD'
         when /Central Square/i
           'CENTRAL'
         when /Porter Square/i
           'PORTER'
         else
           name
         end
  name.upcase
end

def geo(line, name)
  x = GEO_STOPS[line.upcase].detect {|x|
    fix_name(name) == x[0]
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
File.open("train_locations.json", "w")  {|f| f.puts r.to_json}



