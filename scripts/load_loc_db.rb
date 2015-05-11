require 'csv'
puts "Starting to load location database"
fout = File.open(ARGV[1], "w")
arr_of_arrs = CSV.read(ARGV[0])
f = "connect cnsd_locate;\n SET autocommit=0;\n"

arr_of_arrs[1..-1].each do |r0|
  r = []
  r0.each do |r1| 
    if (r1.nil? || r1 == '')  
      r << 'NULL'
    else
      puts "R1: #{r1}"  if r1=="Tul'skaya Oblast'"
      r << "'#{r1.gsub("'","\\\\'")}'"
    end
    
  end
  
  f << "INSERT INTO geo_locations (geoname_id,locale_code,continent_code,continent_name,country_iso_code,country_name,subdivision_1_iso_code,subdivision_1_name,subdivision_2_iso_code,subdivision_2_name,city_name,metro_code,time_zone) 
        VALUES (#{r[0]}, #{r[1]}, #{r[2]}, #{r[3]}, #{r[4]}, #{r[5]}, #{r[6]}, #{r[7]}, #{r[8]}, #{r[9]}, #{r[10]}, #{r[11]}, #{r[12]});\n" 
end

f << "COMMIT;\n"

fout.write(f)
fout.close
