# encoding : utf-8
class MyApp < Sinatra::Application
  ## routes allowing the ssh shell to check authorizations and repositories
  ## 
  get '/api/web/unicorn' do
    if not api_auth(env)
      # the git lib gateway doesn't have a proper api username and/or token
      status 401
      body "Unauthorized / Authentication failed"
      return
    end
    if params[:app_name]
      app = GitRepository.get(:path => params[:app_name]).egg
      status 200
      body {"config" => app.unicorn_conf.to_json}
    else
      # one or both params are missing
      status 400
      body "some params missing"
      return
    end
  end

  post "/api/server/status/?" do
    if not api_auth(env)
      # the git lib gateway doesn't have a proper api username and/or token
      status 401
      body "Unauthorized / Authentication failed"
      return
    end
    data = JSON.parse(params)
    server = Dragon.get(:token => data["token"])
    server.get_status
    status 200
    body "ok"
  end

  post "/api/web/pubkey/?" do
    if not api_auth(env)
      # the git lib gateway doesn't have a proper api username and/or token
      status 401
      body "Unauthorized / Authentication failed"
      return
    end
    data = JSON.parse(params)
    if data["username"] && data["pub_key"] && (data["username"] == "pinpin")
      user = User.get(:login => data["username"])
      user.ssh_key.destroy unless user.ssh_key == nil
      n_key = SshKey.create(:name => "default", :ssh_key => data["pub_key"], :deploy => true)
      user.ssh_key = n_key
      user.save
      status 200
      body "ok"
    else
      # one or both params are missing
      status 400
      body "some params missing or incorrect"
      return
    end
  end

  post "/api/web/register/?" do
    if not api_auth(env)
      # the git lib gateway doesn't have a proper api username and/or token
      status 401
      body "Unauthorized / Authentication failed"
      return
    end
    data = JSON.parse(params)
    host = data["hostname"]
    name = host.split('.').first
    app = Dragon.get(:name => name)
    app.cuddy_token = data["token"]
    app.save
    status 200
    body "Registered"
  end

  private
  def api_auth(the_env)
    token = the_env['HTTP_TOKEN'] || the_env['TOKEN']
    username = the_env['HTTP_USERNAME'] || the_env['USERNAME']
    api_user = ApiUser.first(:login => username)
    return true if api_user.token == token
    return false
  end
end