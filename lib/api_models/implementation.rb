## A test implementation to allow api_http_spec tests to run and exercise the API
# It also should make a good skeleton from which to create real implementations

require 'net/http'
module SecureApi
  
  class Implementation < SecureApi::ApiControl    
    
    include AdminImplementation 
    
    def routes
      r = {
        locate: {
          __default_parameters: {},
          ip_get: {params: {addr: :req}}
        }        
      }

      add_admin_routes r
      
      ### For testing only ###      
      add_test_routes r if DEBUG      
      
      
      
      r
    end
    
    def before_locate_get
      if params[:username] == ''
        throw :not_processed_request, {status: Response::NOT_FOUND, content_type: Response::TEXT , content: "no such record"}
      end      
    end
    

    def locate_ip_get
      addr = params[:addr]
      
      # check the ip address format is valid
      unless valid_ip_format(addr)        
        set_response status: Response::BAD_REQUEST, content_type: Response::JSON, content: @reason
        return
      end
      
      res = lookup_ip addr
      
      unless res        
        set_response status: Response::BAD_REQUEST, content_type: Response::JSON, content: @reason
        return
      end
      
      
      set_response status: Response::OK, content_type: Response::JSON, content: res 
    end


    def bad_request?
      false
    end

    
    def valid_ip_format addr
      valid_format = addr.match(/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/)      
      return true if valid_format
      KeepBusy.logger.warn "Invalid IP address format provided: #{addr}"
      @reason = {message: "Invalid IP address format", code: 'INVALID_ADDR_FORMAT'}
      return false
    end
    
    def ip_to_int addr      
      ip = IPAddr.new addr.dup
      ip.to_i       
    rescue => e
      KeepBusy.logger.warn "IP address invalid converting to integer: #{addr}. #{e.inspect}"
      nil
    end

    def lookup_ip addr
      if addr.is_a? String
        addr = ip_to_int(addr)        
      else
        # Just in case something weird comes through, force a valid integer
        addr = addr.to_i
      end
      
      KeepBusy.logger.info "lookup_ip for addr #{addr}"
      
      if addr.nil? || addr == 0
        @reason = {message: "Invalid IP address format", code: 'INVALID_ADDR_FORMAT'}
        return
      end
      
      ls = Location::IpLocations.find_location(addr)
      if ls
        return ls
      else
        nil
      end
      
    end
    
  end
end
