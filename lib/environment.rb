DEBUG = true
Encoding.default_external = Encoding::UTF_8

require 'fileutils' 
require 'rubygems'
require 'json'
require 'eventmachine'
require 'evma_httpserver'
require 'digest/sha2'
require 'mysql2'
require 'date'
require 'base64'
require 'cgi'
require 'date'
require 'connection_pool'
require 'logger'
require 'ipaddr'
Dir[File.dirname('./initializers') + '/*.rb'].each {|file| require file }
require "#{REQ}/secure_api/response"
require "#{REQ}/secure_api/api_server"
#require "#{REQ}/helpers/logging.rb"

if DEBUG
  require "#{REQ}/test_implementations/test_implementation" 
  require "#{REQ}/test_implementations/test_implementation_callbacks" 
end

require "#{REQ}/helpers/config_manager.rb"
require "#{REQ}/helpers/db_connection.rb"
require "#{REQ}/helpers/db_object.rb"
require "#{REQ}/secure_api/client_secret"
require "#{REQ}/secure_api/api_auth"
require "#{REQ}/secure_api/api_control"

require "#{REQ}/api_models/admin_implementation"

require "#{REQ}/api_models/implementation"
require "#{REQ}/api_models/location/ip_locations"
require "#{REQ}/api_models/location/geo_locations"


Config = ConfigManager.get_config
BaseDirs = Config[:directories]
#Log = Logger.start_logging('log1')
KB_LOG = "#{KB_BASE_DIR}/log/run.log".freeze

module KeepBusy
  def self.mem str=''
    return unless CONFIG_SHOWMEM
    res = `ps -o rss -p #{$$}`.strip.split.last.to_i 
    puts "mem:#{str}=#{res}"
    res
  end
  
  def self.logger
    LOG
  end
  
  def self.log_and_raise e
    logger.error e
    raise e
  end

  def self.log_and_exit c, e
    logger.warn "#{c}::>#{e} "
    throw :request_exit, {status: 409, content_type: 'text/json', content: {details: e,  code: c}}
  end

  LOG = Logger.new(KB_LOG)
  LOG.info "Started running (#{self}): Log file: #{KB_LOG}"
  
end

Log = KeepBusy.logger

Log.info "Setting configuration"
Api = SecureApi::Implementation
Port = ($force_port || Config[:server][:port]).freeze
RequestTimeout = ( Config[:server][:request_timeout] || {__default: 30000} ).freeze
ParamLengthLimit = 65536

AllowOneTimeOnly = (Config[:allow_one_time_only].nil? ? true : Config[:allow_one_time_only]).freeze
Log.info "Allow One Time Only? #{AllowOneTimeOnly}"


Log.info "Creating DB pool"
DBP = {pool: Database::DbConnection.create_new_pool } unless $no_db


SuperAdminClient = Config[:credentials][:super_admin_id].freeze
SuperAdminClientSecret = Config[:credentials][:super_admin_secret].freeze


options = {}
options[:threads] = (Config[:server][:threads] || 10).freeze

SecureApi::ApiServer.start_serving Port, options unless $testing || $configuration