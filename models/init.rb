# encoding: utf-8
DataMapper::Logger.new($stdout, :debug)

DataMapper.setup(:default, :adapter => "mysql", :database => "jupiter", :username => "jupiter", :password => "jupiter")

require_relative 'user'
require_relative 'git_repository'
require_relative 'egg'
require_relative 'key'
require_relative 'server'
require_relative 'api_user'

DataMapper.finalize
DataMapper.auto_upgrade!