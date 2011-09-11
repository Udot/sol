# encoding : utf-8
class MyApp < Sinatra::Application
  get '/apps' do
    env['warden'].authenticate!
    @apps = env["warden"].user.eggs     # putting user apps at hand
    Dragon.get_status                   # updating servers status
    haml "apps/index".to_sym
  end

  post "/apps" do
    env['warden'].authenticate!
    # creating server
    dragon = Dragon.create
    dragon.queue_in
    dragon.get_status
    dragon.save
    # creating app
    egg = Egg.create(:name => params[:name], :user_id => env['warden'].user.id)
    # creating repository
    egg.git_repository = GitRepository.create(:name => params[:name], :user_id => env['warden'].user.id, :egg_id => egg.id)
    egg.git_repository.generate_path
    egg.git_repository.remote_setup
    egg.git_repository.remote_status
    # linking
    egg.dragon = dragon
    egg.save
    redirect "/apps", :notice => "App created."
  end

  delete '/apps/:id' do
    env['warden'].authenticate!
    egg = Egg.get(params[:id])
    redirect "/apps", :error => "This app doesn't belong to you." unless egg.user.id == env['warden'].user.id
    dragon = egg.dragon
    dragon.destroy_remote
    dragon.destroy
    destroyed_status = [500, "no git repository linked"]
    if egg.git_repository
      destroyed_status = egg.git_repository.remote_destroy
      egg.git_repository.destroy if (destroyed_status[0].to_i == 200)
      egg.save
    end
    if (not [401, 500, 503].include?(destroyed_status[0].to_i)) || (egg.git_repository == nil)
      egg.destroy
      destroyed_status = [200, "app deleted"]
    end
    flash_class = "notice"
    flash_class = "error" if [401, 500, 503].include?(destroyed_status[0])
    redirect "/apps", flash_class.to_sym => destroyed_status[1]
  end

  get "/apps/:id" do
  end
end