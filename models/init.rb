# encoding: utf-8
DataMapper::Logger.new($stdout, :debug) unless settings.environment.to_s == "development"

# load db config
db_config = YAML.load_file("./config/database.yml")[settings.environment.to_s]
DataMapper.setup(:default, :ssl => config_db['ssl'] || false, :hostname => db_config['hostname'] || "localhost", :adapter => db_config["adapter"], :database => db_config["database"], :username => db_config["username"], :password => db_config["password"])

require_relative 'user'
require_relative 'git_repository'
require_relative 'egg'
require_relative 'key'
require_relative 'server'
require_relative 'api_user'
require_relative 'mercure_api'

DataMapper.finalize
DataMapper.auto_upgrade!