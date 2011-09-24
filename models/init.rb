current_path = File.expand_path(File.dirname(__FILE__))
require_relative "#{current_path}/../lib/simple_logger"
# encoding: utf-8

db_config = YAML.load_file("#{current_path}/../config/database.yml")[settings.environment.to_s]
FileUtils.mkdir("#{current_path}/../db") unless settings.environment.to_s == "production" || File.exist?("#{current_path}/../db")
DataMapper.setup(:default, :ssl => true, :host => db_config['host'] || "localhost", :adapter => db_config["adapter"], :database => db_config["database"], :username => db_config["username"], :password => db_config["password"]) unless settings.environment.to_s == "development"
DataMapper.setup(:default, :adapter => db_config["adapter"], :database => db_config["database"], :username => db_config["username"], :password => db_config["password"]) unless settings.environment.to_s == "production"

DataMapper::Logger.new(SimpleLogger.new("#{current_path}/../log/development.log"), :debug) unless settings.environment.to_s == "production"
DataMapper::Logger.new(SimpleLogger.new, :info) if settings.environment.to_s == "production"

# db init done in app.rb

require_relative 'user'
require_relative 'git_repository'
require_relative 'egg'
require_relative 'key'
require_relative 'server'
require_relative 'api_user'
require_relative 'mercure_api'
require_relative 'database'

DataMapper.finalize
DataMapper.auto_upgrade!
