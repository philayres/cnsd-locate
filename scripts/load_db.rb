require 'csv'
puts "Starting to load database"
fout = File.open(ARGV[1], "w")
arr_of_arrs = CSV.read(ARGV[0])
f = "connect cnsd_locate;\n SET autocommit=0;\n"

arr_of_arrs[1..-1].each do |r|
  f << "INSERT INTO ip_locations (network,network_start_integer,network_last_integer,geoname_id,registered_country_geoname_id,represented_country_geoname_id,is_anonymous_proxy,is_satellite_provider,postal_code,latitude,longitude) 
        VALUES ('#{r[0]}', '#{r[1]}', '#{r[2]}', '#{r[3]}', '#{r[4]}', '#{r[5]}', '#{r[6]}', '#{r[7]}', '#{r[8]}', '#{r[9]}', '#{r[10]}');\n" 
end

f << "COMMIT;\n"

fout.write(f)
fout.close
