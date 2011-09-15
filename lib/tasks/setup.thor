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
  BASE_USER_DATA_FILE = "./config/base_users.yml"
  desc "user_init", "setup the first user"
  def user_init
    if User.all.count == 0
      user_data = YAML.load_file(BASE_USER_DATA_FILE)
      a_user = User.create( user_data['user'] )
      a_user.save
    end
    if ApiUser.count == 0
      an_auser = ApiUser.create( user_data['api_user'] )
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