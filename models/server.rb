class Dragon
  include DataMapper::Resource

  belongs_to :user
  belongs_to :egg

  has n, :ssh_keys, :through => Resource

  property :id, Serial
  property :name, Text, :default => proc { Server.generate_name }
  property :user_id, Integer
  property :egg_id, Integer
  property :created_at, DateTime
  property :updated_at, DateTime
  property :token, String, :default => proc { Server.generate_token }
  # rackspace related
  property :image_name, String
  property :flavor_name, String
  property :state, String
  property :progress, Integer
  property :provider_id, Integer, :unique => true
  property :host_id, Integer, :unique => true
  property :public_address, String
  property :private_address, String
  # sol operation
  property :status, String
  property :operation_start_time, String
  property :operation_finish_time, String

  def self.generate_name
    Settings
  end

  def self.generate_token
    arh = Array.new
    (1..9).each { |i| arh << i.to_s }
    ("a".."z").each { |i| arh << i }
    ("A".."Z").each { |i| arh << i }
    4.times { arh.shuffle! }
    init_token = ""
    42.times { init_token += arh[rand(arh.size - 1)]}
    return Digest::SHA1.hexdigest(init_token)
  end

  def get_status
    # get status from redis
    redis_status = Redis.new(:host => Settings.redis.host, :port => Settings.redis.port, :password => Settings.redis.password, :db => Settings.redis.server_status)
    # key is server token content is (jsoned) hash :
    #    { "name" => string,                     # the name of the server
    #      "image" => integer,                   # the image id used to create it
    #      "flavor" => integer,                  # the flavor id used to create it
    #      "role" => string,                     # the role used to create it
    #      "provider_id" => integer,             # the provider id of the server (must store, need to do actions on the servers)
    #      "host_id" => integer,                 # host id, for provider needs (must store too)
    #      "image_name" => string,               # the image name
    #      "flavor_name" => string,              # the flavor name
    #      "public_ip" => string,                # the public ip (must store)
    #      "private_ip" => string,               # the private ip (must store)
    #      "state" => string,                    # the state on provider's side
    #      "progess" => integer,                 # the progress on provider's side (percentage)
    #      "status" => string,                   # one of  "waiting", "spawning", "created", "running", "out"
    #      "started_at" => string,               # time of start of the process
    #      "finished_at" => string,              # time of finish of the status
    # }
    r_status = JSON.parse(redis_status.get(token))
    self.public_ip = r_status['public_ip']
    self.private_ip = r_status['private_ip']
    self.provider_id = r_status['provider_id']
    self.host_id = r_status['host_id']
    self.state = r_status['state']
    self.progress = r_status['progress']
    self.image_name = r_status['image_name']
    self.flavor_name = r_status['flavor_name']
    self.operation_start_time = r_status['started_at']
    self.operation_finish_time = r_status['finished_at']
  end

  def queue_in
    redis_status = Redis.new(:host => Settings.redis.host, :port => Settings.redis.port, :password => Settings.redis.password, :db => Settings.redis.server_queue)
    redis_status = Redis.new(:host => Settings.redis.host, :port => Settings.redis.port, :password => Settings.redis.password, :db => Settings.redis.server_status)
    
    # queue in
    # queue in for creation
    # "queue" (jsoned) array with items :
    #    { "name" => string,         # hostname
    #      "role" => string,         # chef role
    #      "image" => integer,       # image id for rackspace, if nil then 10194286 (a base squeeze) is used
    #      "flavor" => integer,      # server size 1 = 256MB, 2 = 512MB, 3 = 1024MB ..., default = 1 (if nil)
    #      "token" => string         # unique token to identify server, will be picked up by cuddy in /etc/sol_token.txt
    # }
    queue = JSON.parse(redis_queue.get("queue"))
    queue << {"name" => name, "role" => "role[www-host]"}
    redis_queue.set("queue", queue.to_json)

    # set initial status
    arh = { "name" => nodename,
      "image" => image,
      "flavor" => flavor,
      "role" => role,
      "provider_id" => provider_id,
      "host_id" => host_id,
      "image_name" => image_name,
      "flavor_name" => flavor_name,
      "public_ip" => public_ip,
      "private_ip" => private_ip,
      "state" => state,
      "progess" => progess,
      "status" => "waiting",
      "started_at" => Time.now.to_s,
      "finished_at" => ""}
    redis_status.set(token, arh.to_json)
  end
end