module Location
  class IpLocations < DbObject
    
    
    BinaryTag = '>>>BINARY::'
    
    def self.table_name 
      'ip_locations'
    end

    def table_name 
      self.class.table_name
    end
    
    
    attr_accessor :id, :network_start_integer, :network_last_integer, :network, :geoname_id, :registered_country_geoname_id, 
                  :represented_country_geoname_id, :is_anonymous_proxy, :is_satellite_provider, :postal_code, :latitude, :longitude,
                  :location_details
    
        
    def initialize       
      @id = nil
    end
            
    def self.find_location addr
      
      addr = addr.to_i # to ensure no injection
      condition = "network_start_integer <= #{addr} AND network_last_integer >= #{addr}"
            
      res = find_all_by condition
      
      unless res && res.first
        KeepBusy.logger.info "No IP location found for #{addr}"
        return nil 
      end
      res = res.first
      
      g = res.geoname_id
      unless g && g != ''
        KeepBusy.logger.info "No geoname found for the location for IP #{addr}"
        return nil 
      end
      
      
      gn = Location::GeoLocations.find_location(g)
      unless gn && gn.first
        KeepBusy.logger.info "No geo location found for the location for IP #{addr} in geoname #{g}"     
        return nil 
      end
      
      res.location_details = gn.first
      
      KeepBusy.logger.info "Found a result for IP #{addr}, geoname #{g}\n#{res.to_json}"     
      
      res
      
    end
        
    
  private
    def save_sql
    end
    
  end
end
