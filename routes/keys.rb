# encoding : utf-8
class MyApp < Sinatra::Application
  get "/keys" do
    env['warden'].authenticate!
    @active_tab = "keys"
    @ssh_keys = env['warden'].user.ssh_keys
    haml "keys/index".to_sym
  end

  get "/keys/new" do
    env['warden'].authenticate!
    @active_tab = "keys"
    @ssh_key = SshKey.new
    haml "keys/new".to_sym
  end

  post "/keys" do
    env['warden'].authenticate!
    redirect "/keys/new", :error => "invalid key" unless SshKey.valid?(params[:ssh_key])
    key = SshKey.create(:name => params[:name], :ssh_key => params[:ssh_key], :user_id => env["warden"].user.id)
    key.save
    redirect "/keys", :notice => "ssh key added."
  end

  get "/keys/:id" do
    env['warden'].authenticate!
    @ssh_key = SshKey.get(params[:id])
    @active_tab = "keys"
    redirect "/keys", :error => "This key doesn't belong to you." unless @ssh_key.user.id == env['warden'].user.id
    haml "keys/show".to_sym
  end

  get "/keys/:id/edit" do
    env['warden'].authenticate!
    @ssh_key = SshKey.get(params[:id])
    @active_tab = "keys"
    redirect "/keys", :error => "This key doesn't belong to you." unless @ssh_key.user.id == env['warden'].user.id
    haml "keys/edit".to_sym
  end

  post "/keys/:id/update" do
    env['warden'].authenticate!
    redirect "/keys/#{params[:id]}/edit", :error => "invalid key" unless SshKey.valid?(params[:ssh_key])
    ssh_key = SshKey.get(params[:id])
    redirect "/keys", :error => "This key doesn't belong to you." unless @ssh_key.user.id == env['warden'].user.id
    ssh_key.name = params[:name]
    ssh_key.ssh_key = params[:ssh_key]
    ssh_key.save
    redirect "/keys", :notice => "key updated."
  end

  get "/keys/export" do
    env['warden'].authenticate!
    redirect "/keys", :notice => "You don't have enough rights" unless env['warden'].user.admin?
    if SshKey.deploy
      redirect "/keys", :notice => "Keys have been exported."
    else
      redirect "/keys", :error => "A problem occured while exporting keys."
    end
  end
end