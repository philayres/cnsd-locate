module Location
  class GeoLocations < DbObject
    
    
    BinaryTag = '>>>BINARY::'
    
    def self.table_name 
      'geo_locations'
    end

    def table_name 
      self.class.table_name
    end
    
    
    attr_accessor :id, :geoname_id, :locale_code, :continent_code, :continent_name, :country_iso_code, :country_name, 
      :subdivision_1_iso_code, :subdivision_1_name, :subdivision_2_iso_code, :subdivision_2_name, :city_name, :metro_code, :time_zone
    
        
    def initialize       
      @id = nil
    end
            
    def self.find_location geoname_id
            
      geoname_id = geoname_id.to_i
      condition = "geoname_id = #{geoname_id}"
            
      find_all_by condition
    end
        
    
  private
    def save_sql
    end
    
  end
end
