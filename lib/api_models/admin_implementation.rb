module AdminImplementation
  Response = SecureApi::Response
  def add_admin_routes r

    a = {
      admin: {
          status_get: {}
      },
      client_admin: {
        index_get: {params: {limit: :req}},
        create_post: {params: {group_id: :req}}
      }
      
    }

    r.merge! a

  end


  def admin_status_get
    set_response status: Response::OK, content_type: Response::JSON, content: {} 
  end

  def client_admin_index_get
    set_response status: Response::OK, content_type: Response::JSON, content: []
  end
  
  def client_admin_create_post
    
    ct = params[:group_id].to_i
    if ct < 1
      set_response status: Response::BAD_REQUEST, content_type: Response::JSON, content: {message: "New client not created. Bad Group ID", code: 'BAD_GROUP_ID', group_id: ct}
      return
    end
    
    nc = SecureRandom.hex 15
    key = SecureApi::ClientSecret.create(nc, replace_client: false, client_type: ct)
    
    set_response status: Response::OK, content_type: Response::JSON, content: {message: "New client created", code: 'NEW_CLIENT_OK', client_id: nc, client_secret: key}
    
  end
  
  def before_client_admin_all
    unless params[:client] == ::SuperAdminClient
      KeepBusy.logger.warn "The regular client '#{params[:client]}' attempted to access client_admin functionality"
      throw :not_processed_request, {status: Response::NOT_AUTHORIZED, content_type: Response::TEXT , content: "Not Permitted"}
    end         
  end


end
