# encoding: utf-8
require_relative "../lib/remote_syslog" unless settings.environment.to_s == "development"
DataMapper::Logger.new($stdout, :debug) if settings.environment.to_s == "development"
DataMapper::Logger.new(RemoteSyslog.new(Settings.remote_log_host,Settings.remote_log_port), :info) unless settings.environment.to_s == "development"

# load db config
db_config = YAML.load_file("./config/database.yml")[settings.environment.to_s]
DataMapper.setup(:default, :ssl => true, :host => db_config['host'] || "localhost", :adapter => db_config["adapter"], :database => db_config["database"], :username => db_config["username"], :password => db_config["password"]) unless settings.environment.to_s == "development"
DataMapper.setup(:default, :adapter => db_config["adapter"], :database => db_config["database"], :username => db_config["username"], :password => db_config["password"]) unless settings.environment.to_s == "production"

require_relative 'user'
require_relative 'git_repository'
require_relative 'egg'
require_relative 'key'
require_relative 'server'
require_relative 'api_user'
require_relative 'mercure_api'

DataMapper.finalize
DataMapper.auto_upgrade!