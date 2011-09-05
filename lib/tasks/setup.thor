# encoding: utf-8
require "rubygems"
require "bundler/setup"

# get all the gems in
Bundler.require(:default)

RailsConfig.load_and_set_settings("./config/settings.yml")
require './models/init'

class Setup < Thor
  include Thor::Actions
  desc "user_init", "setup the first user"
  def user_init
		if User.all.count == 0
      a_user = User.create(:name => "Thomas Riboulet", :email => "riboulet@gmail.com", :password => "testtest", :password_confirmation => "testtest", :login => "mcansky", :role => "admin")
      a_user.save
    end
    if ApiUser.count == 0
      an_auser = ApiUser.create(:login => "shell_user")
    end
  end
end