# encoding: utf-8

class GitRepository
  configure do
    LOGGER = Logger.new("sinatra.log")
  end
  include DataMapper::Resource

  property :id, Serial
  property :created_at, DateTime, :default => proc { DateTime.now }
  property :name, String, :unique => true, :required => true, :length => 4..15, :message => "Your login must not be blank and at least 4 characters long.", :unique_index => true
  property :path, String, :unique => true
  property :user_id, Integer
  property :egg_id, Integer

  belongs_to :user
  belongs_to :egg

  def generate_path
    self.path = name.gsub(/\s/,'_').downcase.gsub(/[àáâãäå]/,'a').gsub(/æ/,'ae').gsub(/ç/, 'c').gsub(/[èéêë]/,'e').gsub(/[üùû]/,'u').gsub(/[œ]/, 'oe')
  end

  def remote_url
    return "git@#{Settings.git.host}:#{user.login}/#{path}.git"
  end

  def remote_setup
    request = MercuryApi.create(user.login, path)
    return true if request[0] == 200
    return false
  end
end