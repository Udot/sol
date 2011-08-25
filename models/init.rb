# encoding: utf-8
DataMapper::Logger.new($stdout, :debug)

DataMapper.setup(:default, :adapter => "mysql", :database => "1111111", :username => "111", :password => "11111111")

require_relative 'user'
require_relative 'project'
require_relative 'session'

DataMapper.finalize
DataMapper.auto_upgrade!