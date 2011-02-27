require 'yaml'
require 'json'
# Figure out subway locations

predictions = YAML::load(File.read("subway_predictions.yml"))

def reduce(trip_id, hash)
  name = hash['name']
  { 
    :trip_id => trip_id,
    :name => name,
    :altname => fix_name(name),
    :time => hash[:time.to_s] 
  }
end

# associate with lat, lng
GEO_STOPS = YAML::load(File.open("geo_subway_stops.yml"))

def fix_name(name)
  name = case name 
         when /^North Station/i, /^South Station/i
           name 
         when  /Massachusetts Ave. Station/
           "MASSACHUSETTS AVE"
         when  /State St. Station/
           "STATE"
         else
           name.sub(/ Station$/, '').upcase
         end
  name = case name 
         when /HARVARD SQUARE/i
           'HARVARD'
         when /CENTRAL SQUARE/i
           'CENTRAL'
         when /PORTER SQUARE/i
           'PORTER'
         else
           name
         end
  name.upcase
end

# MATCHING
def geo(line, name)
  x = GEO_STOPS[line.upcase].detect {|x|
    fixed_name = fix_name(name)
    fixed_name == x[0] ||
      # match first word; NOT SURE IF THIS WILL PRODUCE FALSE MATCHES
      fixed_name.split(' ')[0] == x[0].split(' ')[0]
  }
  if x
    x[1..-1]
  else
    nil
  end
end

r = {}
predictions.each do |line|
    r[line[:line]] = line[:trips].
      select {|t| t[:predictions].size > 1}.
      map { |trip| 
        left = reduce( trip[:trip_id],  trip[:predictions][0] )
        arr = reduce( trip[:trip_id], trip[:predictions][1] )
        left[:geo] = geo(line[:line], left[:name])
        arr[:geo] = geo(line[:line], arr[:name])
        { :trip_id => left[:trip_id], :left => left, :arriving => arr }
      }
end


File.open("train_locations.yml", 'w') {|f| f.puts r.to_yaml}
File.open("train_locations.json", "w")  {|f| f.puts r.to_json}



