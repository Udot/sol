# encoding : utf-8
class MyApp < Sinatra::Application
  ## routes allowing the ssh shell to check authorizations and repositories
  ## 
  get '/api/git/rights' do
    if not api_auth(env)
      # the git lib gateway doesn't have a proper api username and/or token
      status 401
      body "Unauthorized / Authentication failed"
      return
    end
    if params[:username] && params[:repository]
      user = User.first(:login => params[:username])
      git_repository = GitRepository.first(:path => params[:repository].gsub(/\.git$/,''))
      if git_repository.user == user
        # repository owned by that user : ok
        answer = {"access" => true}.to_json
        status 200
        body answer
        return
      else
        # repository is not owned by that user : ko
        status 401
        body "Unauthorized"
        return
      end
    else
      # one or both params are missing
      status 400
      body "some params missing"
      return
    end
  end

  # git repository post via post-receive hook
  post '/api/git/push' do
    if not api_auth(env)
      # the git lib gateway doesn't have a proper api username and/or token
      status 401
      body "Unauthorized / Authentication failed"
      return
    end
    if params[:rev] && params[:repository]
      rep = GitRepository.first(:path => params[:repository])
      rep.last_rev = params[:rev]
      rep.last_update = Time.now
      rep.save
      rep.egg.enqueue
      status 200
    else
      status 400
      body "some params missing"
      return
    end
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