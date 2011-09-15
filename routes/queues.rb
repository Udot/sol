# encoding : utf-8
class MyApp < Sinatra::Application

  get "/queues" do
    env['warden'].authenticate!
    @queues = {"build" => [], "deploy" => [], "db" => [], "db_status" => [], "apps" => [], "servers" => [], "servers_status" => []}
    redis_build = Redis.new(:host => Settings.redis.host,
      :port => Settings.redis.port,
      :password => Settings.redis.password,
      :db => Settings.redis.build_queue)
    redis_deploy = Redis.new(:host => Settings.redis.host,
      :port => Settings.redis.port,
      :password => Settings.redis.password,
      :db => Settings.redis.deploy_queue)    
    redis_db = Redis.new(:host => Settings.redis.host,
      :port => Settings.redis.port,
      :password => Settings.redis.password,
      :db => Settings.redis.db_queue)    
    redis_app = Redis.new(:host => Settings.redis.host,
      :port => Settings.redis.port,
      :password => Settings.redis.password,
      :db => Settings.redis.app_status)
    redis_servers_q = Redis.new(:host => Settings.redis.host,
      :port => Settings.redis.port,
      :password => Settings.redis.password,
      :db => Settings.redis.server_queue)
    redis_servers_s = Redis.new(:host => Settings.redis.host,
      :port => Settings.redis.port,
      :password => Settings.redis.password,
      :db => Settings.redis.server_status)

    # build queue
    @queues['build'] = JSON.parse(redis_build.get('queue')) unless redis_build.get('queue') == nil
    # deploy queue
    redis_deploy.keys.each do |token|
      @queues['deploy'] << {"key" => token, "data" => JSON.parse(redis_deploy.get(token))}
    end
    # db queue
    @queues['db'] = JSON.parse(redis_db.get('queue')) unless redis_db.get('queue') == nil
    # db status TOGO
    redis_db.keys.each do |app|
      @queues['db_status'] << {"key" => app, "data" => JSON.parse(redis_db.get(app))} unless app == "queue"
    end
    # apps status
    redis_app.keys.each do |app|
      @queues['apps'] << {"key" => app, "data" => JSON.parse(redis_app.get(app))}
    end
    # server creation queue
    @queues['servers'] = JSON.parse(redis_servers_q.get("queue")) unless redis_servers_q.get('queue') == nil
    # servers status
    redis_servers_s.keys.each do |server|
      @queues['servers_status'] << {"key" => server, "data" => JSON.parse(redis_servers_s.get(server))}
    end
    haml "queues/index".to_sym
  end
end