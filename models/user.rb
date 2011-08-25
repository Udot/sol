# encoding: utf-8
require 'bcrypt'
require 'securerandom'

class User
  configure do
    LOGGER = Logger.new("sinatra.log")
  end
  include DataMapper::Resource

  property :id, Serial
  property :email, String, :required => true, :index => :login, :unique => true, :unique_index => true, :format => :email_address
  property :crypted_pass, String, :length => 60..60, :required => true, :writer => :protected
  property :name, String, :unique => true, :required => true, :length => 3..30, :message => "Your name must not be blank and at least 3 characters.", :unique_index => true
  property :created_at, DateTime, :default => proc { DateTime.now }

  attr_accessor :password, :password_confirmation, :password_reset
  
  validates_presence_of :password, :password_confirmation, :if => :password_required?
  validates_confirmation_of :password, :if => :password_required?
  
  before :valid?, :crypted_pass

  has n, :projects
  has n, :sessions

  before :valid?, :crypt_password

  def password_required?
    new? or password_reset
  end

  def reset_password(password, confirmation)
    self.password_reset = true
    self.password = password
    self.password_confirmation = confirmation
    self.save
  end

  def crypt_password
    if password
      self.crypted_pass = BCrypt::Password.create(password)
    end
  end

  def crypted_pass
    pass = attribute_get(:crypted_pass)
    if pass
       BCrypt::Password.new(pass)
    else
      :no_password
    end
  end

  def authenticate(password)
    crypted_pass == password
  end

  def self.authenticate(username, password)
    un = username.to_s.downcase
    u = first(:conditions => ['lower(email) = ?', un])
    if u && u.authenticate(password)
      u
    else
      nil
    end
  end
end