# encoding : utf-8
class MyApp < Sinatra::Application
  get "/eggs" do
    env['warden'].authenticate!
    @active_tab = "eggs"
    Dragon.get_status
    PgDatabase.update_status
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
    redirect "/eggs/#{egg.id}", :notice => "Egg updated."
  end

  delete "/eggs/:id/destroy" do
    env['warden'].authenticate!
    egg = Egg.get(params[:id])
    redirect "/eggs", :error => "This egg doesn't belong to you." unless egg.user.id == env['warden'].user.id
    destroyed_status = [500, "no git repository linked"]
    if egg.pg_database
      db = egg.pg_database
      db.remote_destroy
      db.destroy
    end
    if egg.dragon
      dragon = egg.dragon
      dragon.destroy_remote
      dragon.destroy
    end
    if egg.git_repository
      destroyed_status = egg.git_repository.remote_destroy
      egg.git_repository.destroy if (destroyed_status[0].to_i == 200)
      egg.save
    end
    if (egg.git_repository == nil)
      egg.destroy
      destroyed_status = [200, "egg deleted"]
    end
    flash_class = "notice"
    flash_class = "error" if [401, 500, 503].include?(destroyed_status[0])
    redirect "/eggs", flash_class.to_sym => destroyed_status[1]
  end

  post "/eggs" do
    env['warden'].authenticate!
    egg = Egg.create(:name => params[:name], :user_id => env['warden'].user.id)
    # creating server
    dragon = Dragon.create
    dragon.queue_in
    dragon.get_status
    dragon.save
    egg.dragon = dragon
    egg.save
    logger.info("dragon created")
    # creating repository
    egg.git_repository = GitRepository.create(:name => params[:name], :user_id => env['warden'].user.id, :egg_id => egg.id)
    egg.git_repository.generate_path
    egg.git_repository.remote_setup
    egg.git_repository.remote_status
    egg.save
    logger.info("repository created")
    # creating database
    egg.pg_database = PgDatabase.create(:name => "db_" + egg.git_repository.path, :username => "user_" + egg.git_repository.path, :egg_id => egg.id)
    egg.pg_database.remote_create
    logger.info("database created")
    if egg.save
      redirect "/eggs/#{egg.id}", :notice => "Egg created."
    else
      redirect "/eggs", :error => "Could not save the Egg properly : #{egg.errors.to_s}"
    end
  end
end