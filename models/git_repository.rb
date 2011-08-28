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
  property :status, String, :default => "loose"
  property :user_id, Integer
  property :egg_id, Integer
  property :last_check_at, DateTime

  belongs_to :user
  belongs_to :egg

  def generate_path
    self.path = name.gsub(/\s/,'_').downcase.gsub(/[àáâãäå]/,'a').gsub(/æ/,'ae').gsub(/ç/, 'c').gsub(/[èéêë]/,'e').gsub(/[üùû]/,'u').gsub(/[œ]/, 'oe')
  end

  def remote_url
    return "git@#{Settings.git.host}:#{user.login}/#{path}.git"
  end

  def remote_setup
    request = MercureApi.create(user.login, path)
    if request != nil
      if request[0] == "200"
        self.status = "created"
        return true
      end
    end
    return false
  end

  def updated_status
    return status if ((last_check_at != nil) && (last_check_at > Time.now - 720))
    self.status = remote_status
    last_check_at = Time.now
    return status
  end

  def remote_status
    request = MercureApi.status(user.login, path)
    if request != nil
      if request[0] == "200"
        return JSON.parse(request[1])["status"]
      end
    end
    return "loose"
  end

  def is_loose?
    return true if status == "loose"
    return false
  end
  alias_method :loose?, :is_loose?

  def is_created?
    return true if status == "created"
    return false
  end
  alias_method :created?, :is_created?
end