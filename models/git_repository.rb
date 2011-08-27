# encoding: utf-8
require 'bcrypt'
require 'securerandom'
require 'digest/sha1'

class GitRepository
  configure do
    LOGGER = Logger.new("sinatra.log")
  end
  include DataMapper::Resource

  property :id, Serial
  property :created_at, DateTime, :default => proc { DateTime.now }
  property :name, String, :unique => true, :required => true, :length => 4..15, :message => "Your login must not be blank and at least 4 characters long.", :unique_index => true
  property :path, String, :unique => true, :default => proc { self.name }
  property :user_id, Integer
  property :egg_id, Integer

  belongs_to :user
  belongs_to :egg

end