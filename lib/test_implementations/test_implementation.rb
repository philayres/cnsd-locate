module TestImplementation
  Response = SecureApi::Response

  def controller1_action1_get
    opt1 = params[:opt1].upcase
    opt2 = "#{params[:opt2].upcase} has been forced to upper case" if params[:opt2]
    set_response  status: Response::OK , content_type: Response::JSON, content: {opt1: opt1, opt2: opt2} 
  end

  def controller1_action2_get
    set_response  status: Response::OK , content_type: Response::JSON, content: {opt1: params[:opt1], opt2: params[:opt2], pw: params[:password]} 
  end

  def controller1_action3_get

  end

  def controller2_action1_post
    set_response  status: Response::OK , content_type: Response::JSON, content: {posted: "POSTED!", opt1: params[:opt1], opt2: params[:opt2], opt3: params[:opt3]} 
  end

  def controller2_action2_get
    set_response  status: Response::OK , content_type: Response::JSON, content: {opt1: params[:opt1], opt2: params[:opt2], username: params[:username]} 
  end

  def controller2_action3_get

  end

  def controller2_action3_post

  end

  def controller2_action4_post
    set_response  status: Response::OK , content_type: Response::JSON, content: {posted: "POSTED!", opt1: params[:opt1], opt2: params[:opt2], opt3: params[:opt3]} 
  end

  def controller2_action5_post
    KeepBusy.logger.info params.inspect 
    set_response  status: Response::OK , content_type: Response::JSON, content: {url_params: @url_params , body_params: @body_params } 
  end

  def controller2_action6_post
    KeepBusy.logger.info params.inspect 
    set_response status: Response::BAD_REQUEST , content_type: Response::JSON, content: {ok: "it is not"}
  end

  def before_controller2_get
    if params[:username] == ''
      throw :not_processed_request, {status: Response::NOT_FOUND, content_type: Response::TEXT , content: "no such record"}
    end      
  end

  def after_controller2_all
    if params[:password] == ''        
      throw :request_exit, {status: Response::BAD_REQUEST, content_type: Response::TEXT, content: 'This password is not secret.'}
    end      
  end

end
