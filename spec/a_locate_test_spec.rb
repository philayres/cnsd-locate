$testing = true
REQ = File.expand_path('./lib') 
require "#{REQ}/em_server"
$baseurl = 'localhost'
$port = Port
$server = "http://#{$baseurl}:#{$port}"
require './lib/client/requester'
require 'httpclient'
require 'rspec'


describe 'locate' do
  
  
  before(:all) do
    
    # clear up first
    test_client = 'test_client'
    secret = SecureApi::ClientSecret.create(test_client, :replace_client=>true)
    @requester = ReSvcClient::Requester.new $server, test_client, secret
  end
  
  it "should check status of server - if it fails, ensure the server is running" do    
    params = {}
    path = '/admin/status'
    @requester.make_request :get, params, path
    expect(@requester.code).to eq SecureApi::Response::OK 
  end

  it "check ip address is rejected if invalid format" do    
    params = {addr: 'abc'}
    path = '/locate/ip'
    @requester.make_request :get, params, path
    expect(@requester.code).to eq SecureApi::Response::BAD_REQUEST    
    expect(@requester.data['code']).to eq 'INVALID_ADDR_FORMAT'
  end
  
  it "check ip address is looked up" do    
    params = {addr: '50.138.223.47'}
    path = '/locate/ip'
    @requester.make_request :get, params, path
    expect(@requester.code).to eq SecureApi::Response::OK   
    n = @requester.data['network']
    nip = n.split('/').first.split('.')[0..1]
    expect(nip).to eq params[:addr].split('.')[0..1]
  end
  


  
end
