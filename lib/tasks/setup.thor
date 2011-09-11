# encoding: utf-8
require "rubygems"
require "bundler/setup"
require "digest/sha1"

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

  desc "pinpin_init", "setup a user for pinpin"
  def pinpin_init
    user = User.get(:login => "pinpin")
    if user == nil
      rand_string = ""
      42.times { rand_string += (0..9).to_a[rand(10)].to_s }
      pass_string = Digest::SHA1::hexdigest(Time.now.to_s + rand_string)
      user = User.create(:name => "pinpin", :email => "pinpin@something", :password => pass_string, :password_confirmation => pass_string, :login => "pinpin", :role => "normal")
      user.save
    end
  end
  
end