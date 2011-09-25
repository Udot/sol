# encoding: utf-8
require 'bcrypt'
require 'securerandom'
require 'digest/sha1'

class User
  include DataMapper::Resource

  property :id, Serial
  property :email, String, :required => true, :index => :login, :unique => true, :unique_index => true, :format => :email_address
  property :crypted_pass, String, :length => 60..60, :required => true, :writer => :protected
  property :name, String, :required => true, :length => 3..30, :message => "Your name must not be blank and at least 3 characters."
  property :created_at, DateTime, :default => proc { DateTime.now }
  property :login, String, :unique => true, :required => true, :length => 4..15, :message => "Your login must not be blank and at least 4 characters long.", :unique_index => true
  property :token, String, :unique => true, :default => proc { User.generate_token }
  property :role, String, :default => proc { User.default_role } # "admin" or "normal"

  attr_accessor :password, :password_confirmation, :password_reset

  validates_presence_of :password, :password_confirmation, :if => :password_required?
  validates_confirmation_of :password, :if => :password_required?
  #
  #before :valid?, :crypted_pass

  has n, :eggs
  has n, :ssh_keys
  has n, :git_repositories

  before :valid?, :crypt_password

  def password_required?
    new? or password_reset
  end

  def reset_password(password, confirmation)
    if (password == confirmation)
      self.password_reset = true
      self.password = password
      self.password_confirmation = confirmation
      self.crypt_password
    end
  end

  def crypt_password
    self.crypted_pass = BCrypt::Password.create(password) if password
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

  # role check
  def is_admin?
    return true if role == "admin"
    return false
  end
  alias_method :admin?, :is_admin?
  
  def is_normal?
    return true if role == "normal"
    return false
  end
  alias_method :normal?, :is_normal? 


  ## Class methods
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

  # setting default role
  def self.default_role
    return "admin" if User.all.count == 1
    return "normal"
  end
  
  # authentication
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
