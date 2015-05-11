module TestImplementationCallbacks
  Response = SecureApi::Response

  
  # An example of a callback method definition for the appropriate controller, action, method 
  # Notice that this is prefixed with self. since it is initially referenced against the class
  # not an instance of the object.
  # Note that it is the responsibility of the callback to call response.send_response in order to mark the end of
  # the HTTP request
  # The arguments passed in provide control:
  #   result: the original set_response hash as set by the 
  #           controller_action_method implementation
  #   request: the ApiServer instance that was instantiated during the call
  #           which can be used to access the original params hash
  
  def callback_controller2_action6_post result, response, request
    puts "Using alternative callback for #{result} "      
    # Notice the usage: api.set_response ... since we are not inside the Api instance when this method is initially used
    # We can also use the original `result` from the action implementation (for example, result[:content_type])      
    res = {status: Response::OK, content_type: result[:content_type], content: {ok: "it is#{request.params[:a_value]}"} }
    sleep 1
    # Repeat this to override previous settings
    request.send_response res, response
    response.send_response
  end

  
end
