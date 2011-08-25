# encoding: utf-8
require "rubygems"
require "bundler/setup"

# get all the gems in
Bundler.require(:default)
DataMapper::Logger.new($stdout, :debug)

DataMapper.setup(:default, :adapter => "mysql", :database => "1111111", :username => "111", :password => "11111111")

require './models/init'

class Setup < Thor
  include Thor::Actions
  desc "user_init", "setup the first user"
  def user_init
		if User.all.count == 0
      a_user = User.create(:name => "11111", :email => "1111111111@ergerg.com", :password => "111111", :password_confirmation => "111111")
      a_user.save
    end
  end
end