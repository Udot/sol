# encoding : utf-8
class Egg
  include DataMapper::Resource

  belongs_to :user
  has n, :ssh_keys, :through => Resource
  has 1, :dragon
  has 1, :git_repository
  has 1, :pg_database

  property :id, Serial
  property :name, Text, :unique => true
  property :user_id, Integer
  property :created_at, DateTime
  property :updated_at, DateTime
  # unicorn config
  property :unicorn_workers, Integer                   # unicorn workers qty (default = 2)
  property :unicorn_port, Integer                      # unicorn port
  property :fqdn, String, :unique => true, :default => proc { generate_fqdn }              # user chosen fqdn
  property :synth_fqdn, String                         # randomly generated fqdn -> need to have an internal DNS
  property :database_done, Boolean, :default => false

  # return a proper unicorn config
  def unicorn_conf
    shared = "/var/www/hosts/#{git_repository.path}/shared"
    config = ""
    config += "listen #{unicorn_port}, :tcp_nopush => true\n"
    config += "worker_processes #{unicorn_workers}\n"
    config += "user cuddy, www-data\n"
    config += "pid #{shared}/unicorn_#{git_repository.path}.pid\n"
    config += "working_directory /var/www/hosts/#{git_repository.path}/current\n"
    config += "stderr_path #{shared}/log/stderr.log\n"
    config += "stdout_path #{shared}/log/stdout.log\n"
    return config
  end

  # return proper nginx conf
  def nginx_conf
    config = ""
    config += "server {\n"
    config += "\tlisten\t\t\t80;\n"
    config += "\tserver_name  #{fqdn};\n"
    config += "\taccess_log  off;\n"
    config += "\terror_log off;\n"
    config += "\t# proxy to unicorn\n"
    config += "\tlocation / {\n"
    config += "\t\tproxy_pass         http://#{dragon.public_address}:#{unicorn_port}/;\n"
    config += "\t\tproxy_redirect     off;\n"
    config += "\t\tproxy_set_header   Host             $host;\n"
    config += "\t\tproxy_set_header   X-Real-IP        $remote_addr;\n"
    config += "\t\tproxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;\n"
    config += "\t\tproxy_max_temp_file_size 0;\n"
    config += "\t\tclient_max_body_size       10m;\n"
    config += "\t\tclient_body_buffer_size    128k;\n"
    config += "\t\tproxy_connect_timeout      90;\n"
    config += "\t\tproxy_send_timeout         90;\n"
    config += "\t\tproxy_read_timeout         90;\n"
    config += "\t\tproxy_buffer_size          4k;\n"
    config += "\t\tproxy_buffers              4 32k;\n"
    config += "\t\tproxy_busy_buffers_size    64k;\n"
    config += "\t\tproxy_temp_file_write_size 64k;\n"
    config += "\t}\n"
    config += "}\n"
  end

  def generate_fqdn
    name_s = name.gsub(/^\.*/,'').gsub(/\s/,'_').downcase.gsub(/[àáâãäå]/,'a').gsub(/æ/,'ae').gsub(/ç/, 'c').gsub(/[èéêë]/,'e').gsub(/[üùû]/,'u').gsub(/[œ]/, 'oe')
    return "#{name_s}.#{Settings.domain_name}"
  end

  # enqueue in redis db 0 for build
  # "queue" is a jsoned Array, items are using following format :
  #   {  "name" => string,           # the name of the app
  #      "repository" => string,     # the url of the git repository
  #      "db_string" => string,      # basis for pwd
  #      "cuddy_token" => string     # the token of the host that will host it
  #   }
  def enqueue
    redis_build_queue = Redis.new(:host => Settings.redis.host, :port => Settings.redis.port,
      :password => Settings.redis.password, :db => Settings.redis.build_queue)
    queue = []
    queue = JSON.parse(redis_build_queue.get("queue")) if redis_build_queue.get("queue") != nil
    queue << {"name" => name, "repository" => git_repository.remote_url, "db_string" => "something", "cuddy_token" => dragon.token}
    redis_build_queue.set("queue", queue.to_json)
  end
end
