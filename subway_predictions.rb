`curl -s http://developer.mbta.com/RT_Archive/RealTimeHeavyRailKeys.csv > station_keys.csv`
`curl -s "http://developer.mbta.com/Data/Red.txt" > subway.csv`
`curl -s "http://developer.mbta.com/Data/orange.txt" >> subway.csv`
`curl -s "http://developer.mbta.com/Data/blue.txt" >> subway.csv`
require 'csv'
require 'yaml'
require 'date'
require 'json'

def stop_keys
  return @stop_keys if @stop_keys
  @stop_keys  = {}
  File.open("station_keys.csv").readlines[1..-1].map {|line| CSV.parse_line(line)}.
    each do |line| 
      key = line[1].strip
      stop_id = line[9]
      @stop_keys[key] = {:stop_id => stop_id, :name => line[11]}
    end
  @stop_keys
end

def add_stop_name(line_data)
  stop_key = line_data[2].strip
  data = stop_keys[stop_key]
  if data.nil?
    puts "#{line_data.inspect} has no matching stop"
    return
  end
  stop_id, name = data.values
  line_data.insert(2, name)
  line_data.insert(3, stop_id)
  line_data
end

def fmt_prediction(line, a)
  r = {}
  %w{ name code1 code2 status time remaining type route }.each_with_index do |f, i|
    r[f] = a[i].strip
  end
  fmt = "%m/%d/%Y %I:%M:%S %p"
  time = r['time'].
    gsub(/ (\d):/, ' 0\1:'). # correct a single digit hour
    gsub(/^(\d)\//, '0\1/') # correct a single month

  r['time'] = DateTime.strptime time, fmt
  r['route'] = if line == "Red"
                if r['route'] == '0'
                  "Braintree Branch"
                else
                  "Ashmont Branch"
                end
               else
                 r['route']
               end
  r.delete('code1')
  r.delete('code2')
  r.delete('remaining')
  r.delete('type')
  r
rescue
  STDERR.puts time, $!
end


res = File.readlines("subway.csv").
  map {|x| CSV.parse_line(x) }.
  map {|x| add_stop_name(x) }.
  group_by {|x| x[0]}.map {|line, x| 
    { :line => line,
      :trips => x.map {|z| z[1..-1]}.
        group_by {|x| x[0].to_i}.
        map {|trip_id, x| 
          {:trip_id => trip_id, :predictions => x.
            map {|a| a[1..-1]}.map {|y| fmt_prediction(line, y) }.
            sort_by {|stop| stop['time']}}
        }
      }
    }

File.open("subway_predictions.yaml", "w")  {|f| f.puts res.to_yaml}
File.open("subway_predictions.json", "w")  {|f| f.puts res.to_json}



__END__

Notes
http://www.eot.state.ma.us/developers/

http://developer.mbta.com/RT_Archive/DataExplained.txt

http://developer.mbta.com/RT_Archive/RealTimeHeavyRailKeys.csv


