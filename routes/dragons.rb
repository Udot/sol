# encoding : utf-8
class MyApp < Sinatra::Application
  get "/dragons" do
    env['warden'].authenticate!
    @active_tab = "dragons"
    @dragons = Dragon.all
    @dragons.each { |s| s.get_status }
    haml "dragons/index".to_sym
  end

  get "/dragons/new" do
    env['warden'].authenticate!
    @active_tab = "dragons"
    @dragon_name = Dragon.generate_name
    haml "dragons/new".to_sym
  end

  post "/dragons" do
    env['warden'].authenticate!
    dragon = Dragon.create
    dragon.queue_in
    dragon.get_status
    dragon.save
    redirect "/dragons", :notice => "Dragon created"
  end

  delete "/dragons/:id" do
    env['warden'].authenticate!
    dragon = Dragon.get(params[:id])
    dragon.remote_destroy
    dragon.destroy
    redirect "/dragons", :notice => "Dragon destroyed"
  end

end