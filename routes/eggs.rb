# encoding : utf-8
class MyApp < Sinatra::Application
  get "/eggs" do
    env['warden'].authenticate!
    @active_tab = "eggs"
    @eggs = env["warden"].user.eggs
    haml "eggs/index".to_sym
  end

  get "/eggs/new" do
    env['warden'].authenticate!
    @active_tab = "eggs"
    haml "eggs/new".to_sym
  end

  get "/eggs/:id" do
    env['warden'].authenticate!
    @active_tab = "eggs"
    @egg = Egg.get(params[:id])
    redirect "/eggs", :error => "This egg doesn't belong to you." unless @egg.user.id == env['warden'].user.id
    haml "eggs/show".to_sym
  end

  get "/eggs/:id/edit" do
    env['warden'].authenticate!
    @active_tab = "eggs"
    @egg = Egg.get(params[:id])
    redirect "/eggs", :error => "This egg doesn't belong to you." unless @egg.user.id == env['warden'].user.id
    haml "eggs/edit".to_sym
  end

  post "/eggs/:id/update" do
    env['warden'].authenticate!
    egg = Egg.get(params[:id])
    redirect "/eggs", :error => "This egg doesn't belong to you." unless egg.user.id == env['warden'].user.id
    egg.name = params[:name]
    egg.save
    redirect "/eggs", :notice => "Egg updated."
  end

  delete "/eggs/:id/destroy" do
    env['warden'].authenticate!
    egg = Egg.get(params[:id])
    redirect "/eggs", :error => "This egg doesn't belong to you." unless egg.user.id == env['warden'].user.id
    destroyed_status = [500, "no git repository linked"]
    destroyed_status = egg.git_repository.remote_destroy if egg.git_repository
    egg.git_repository.destroy
    egg.destroy
    flash_class = "notice"
    flash_class = "error" if [401, 500, 503].include?(destroyed_status[0])
    redirect "/eggs", flash_class.to_sym => destroyed_status[1]
  end

  post "/eggs" do
    env['warden'].authenticate!
    egg = Egg.create(:name => params[:name], :user_id => env['warden'].user.id)
    egg.git_repository = GitRepository.create(:name => params[:name], :user_id => env['warden'].user.id, :egg_id => egg.id)
    egg.git_repository.generate_path
    egg.git_repository.remote_setup
    egg.git_repository.remote_status
    egg.save
    redirect "/eggs", :notice => "Egg updated."
  end
end