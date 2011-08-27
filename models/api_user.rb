# encoding: utf-8
require 'bcrypt'
require 'securerandom'
require 'digest/sha1'

class ApiUser
  configure do
    LOGGER = Logger.new("sinatra.log")
  end
  include DataMapper::Resource

  property :id, Serial
  property :created_at, DateTime, :default => proc { DateTime.now }
  property :login, String, :unique => true, :required => true, :length => 4..15, :message => "Your login must not be blank and at least 4 characters long.", :unique_index => true
  property :token, String, :unique => true, :default => proc { ApiUser.generate_token }

  # API token generation
  def self.generate_token
    the_token = ""
    ash = []
    (0..9).each { |a| ash << a.to_s }
    ("a".."z").each { |a| ash << a }
    ("A".."Z").each { |a| ash << a }
    4.times { ash.shuffle! }
    30.times { the_token += ash[rand(ash.size)] }
    return Digest::SHA1.hexdigest(Time.now.to_s + the_token)
  end

end