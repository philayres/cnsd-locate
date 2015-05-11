$testing = true
REQ = File.expand_path('./lib') 
require "#{REQ}/em_server"
$baseurl = 'localhost'
$port = Port
$server = "http://#{$baseurl}:#{$port}"
require './lib/client/requester'
require 'httpclient'
require 'rspec'


describe 'client admin implementation' do
  
  
  before(:all) do
    
    # clear up first
    test_client = 'test_client'
    secret = SecureApi::ClientSecret.create(test_client, :replace_client=>true)
    @requester = ReSvcClient::Requester.new $server, test_client, secret
    
    super_client = ::SuperAdminClient
    super_secret = ::SuperAdminClientSecret
    @super_requester = ReSvcClient::Requester.new $server, super_client, super_secret
  end
  
  it "should check status of server - if it fails, ensure the server is running" do    
    

    params = {}
    path = '/admin/status'
    @requester.make_request :get, params, path
    expect(@requester.code).to eq SecureApi::Response::OK 
  end

  it "should ensure that a regular client can not access client admin methods" do    
    params = {limit: 1}
    path = '/client_admin/index'
    @requester.make_request :get, params, path
    expect(@requester.code).to eq SecureApi::Response::NOT_AUTHORIZED    
  end
  
  it "should enable super client to access client admin methods" do
    params = {limit: 1}
    path = '/client_admin/index'
    @super_requester.make_request :get, params, path
    expect(@super_requester.code).to eq SecureApi::Response::OK
  end
  
  it "should create a new client api entry" do
    params = {group_id: rand(100)}
    path = '/client_admin/create'
    @super_requester.make_request :post, params, path
    expect(@super_requester.code).to eq SecureApi::Response::OK
    
    new_client = @super_requester.data['client_id']
    new_secret = @super_requester.data['client_secret']
    expect(new_client.length).to eq 30
    expect(new_secret.length).to be > 10
    
    
    # Now check the client can be used       
    new_requester = ReSvcClient::Requester.new $server, new_client, new_secret
    params = {}
    path = '/admin/status'
    new_requester.make_request :get, params, path
    expect(new_requester.code).to eq SecureApi::Response::OK
    
  end
  
  it "should prevent a client being created with an illegal group id" do
    
    params = {group_id: "ajksgfjqwegr"}
    path = '/client_admin/create'
    @super_requester.make_request :post, params, path
    expect(@super_requester.code).to eq SecureApi::Response::BAD_REQUEST
    
    params = {}
    path = '/client_admin/create'
    @super_requester.make_request :post, params, path
    expect(@super_requester.code).to eq SecureApi::Response::UNPROCESSABLE
    
  end
  
  
end
