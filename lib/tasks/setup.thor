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
      a_user = User.create( load_user_data(:user) )
      a_user.save
    end
    if ApiUser.count == 0
      an_auser = ApiUser.create( load_user_data(:api_user) )
    end
  end

  desc "pinpin_init", "setup a user for pinpin"
  def pinpin_init
    userdata = load_user_data(:pinpin_user)
    user = User.get(:login => userdata['login'])
    if user == nil
      rand_string = ""
      42.times { rand_string += (0..9).to_a[rand(10)].to_s }
      pass_string = Digest::SHA1::hexdigest(Time.now.to_s + rand_string)
      userdata = userdata.merge({:password => pass_string, :password_confirmation => pass_string})
      user = User.create( userdata )
      user.save!
    end
  end
  protected
  def load_user_data(userkey)
    user_data ||= YAML.load_file(BASE_USER_DATA_FILE)
    user_data[ userkey.to_s ]
  end
end
