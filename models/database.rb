# encoding : utf-8
class PgDatabase
  include DataMapper::Resource

  belongs_to :egg

  property :id, Serial
  property :name, String, :unique => true
  property :egg_id, Integer
  property :created_at, DateTime
  property :updated_at, DateTime
  # database config
  property :username, String, :unique => true
  property :hostip, String                        # not used yet
  property :pwd_string, String, :default => proc { random_string }
  property :status, String
  # queue hash
  # in redis/2
  #  {"database" => string,         # database name
  #   "username" => string,         # the name of the user
  #   "hostip" => string,           # the ip address of the server doing the requests
  #   "token" => string,            # token string that will be slated with secret token (from config, shared with cuddy)
  #   "action" => string,           # action to do (create, destroy)
  #   "app" => string               # the name of the app
  # }
  # status hash (redis/2)
  # key is app name
  # { "database" => string,
  #   "username" => string,
  #   "passwd_string" => string,    # not the real password, a secret token is used to salt before hashing
  #   "status" => status,           # status of the db "waiting", "created", "destroyed"
  #   "started_at" => datetime,     # the time when the app was added in the queue
  #   "finished_at" => datetime,    # the time when the app was properly deployed
  # "error" => {"message" => "", "backtrace" => ""},
  # }
  def remote_create
    redis = Redis.new(:host => Settings.redis.host, :port => Settings.redis.port, :password => Settings.redis.password, :db => Settings.redis.db_queue)
    queue = []
    queue = JSON.parse(redis.get("queue")) unless redis.get("queue") == nil
    queue << {"database" => name, "username" => username, "token" => pwd_string, "action" => "create", "app" => egg.git_repository.path}
    redis.set("queue", queue.to_json)
    self.set_status("queued")
  end

  def remote_destroy
    redis = Redis.new(:host => Settings.redis.host, :port => Settings.redis.port, :password => Settings.redis.password, :db => Settings.redis.db_queue)
    queue = []
    queue = JSON.parse(redis.get("queue")) unless redis.get("queue") == nil
    queue << {"database" => name, "username" => username, "token" => pwd_string, "action" => "destroy", "app" => egg.git_repository.path}
    redis.set("queue", queue.to_json)
    self.set_status("queued for destruction")
  end

  def self.update_status
    redis = Redis.new(:host => Settings.redis.host, :port => Settings.redis.port, :password => Settings.redis.password, :db => Settings.redis.db_queue)
    PgDatabase.each do |db|
      begin
        r_status = JSON.parse(redis.get(db.egg.git_repository.path)) unless redis.get(db.egg.git_repository.path) == nil
        db.status = r_status['status'] unless r_status == nil
        db.status = "failing" if r_status == nil
        db.save
      rescue
        db.set_status("unkown")
        db.status = "unkown"
        db.save
      end
    end
  end

  def to_h
    return {"database" => name,
      "username" => username,
      "passwd_string" => pwd_string}
  end

  def set_status(msg)
    redis = Redis.new(:host => Settings.redis.host, :port => Settings.redis.port, :password => Settings.redis.password, :db => Settings.redis.db_queue)
    n_status = self.to_h
    begin
      n_status = JSON.parse(redis.get(egg.git_repository.path))
    rescue JSON::ParserError
    end
    n_status['status'] = msg
    redis.set(egg.git_repository.path, n_status.to_json)
  end

  def random_string
    a1 = (0..9)
    a2 = ("a".."z")
    a3 = ("A".."Z")
    ar = []
    a1.each { |d| ar << d.to_s }
    a2.each { |d| ar << d }
    a3.each { |d| ar << d }
    string = ""
    42.times { string += ar[rand(ar.size - 1)]}
    return string
  end
end