# encoding: utf-8
require "rubygems"
require "bundler/setup"

# get all the gems in
Bundler.require(:default)
DataMapper::Logger.new($stdout, :debug)

DataMapper.setup(:default, :adapter => "mysql", :database => "jupiter", :username => "jupiter", :password => "jupiter")

require './models/init'

class Setup < Thor
  include Thor::Actions
  desc "user_init", "setup the first user"
  def user_init
		if User.all.count == 0
      a_user = User.create(:name => "Thomas Riboulet", :email => "riboulet@gmail.com", :password => "testtest", :password_confirmation => "testtest", :login => "mcansky")
      a_user.save
    end
  end
end