# encoding : utf-8
class MyApp < Sinatra::Application
  get "/users" do
    env['warden'].authenticate!
    if env['warden'].user.admin?
      @active_tab = "users"
      @users = User.all
      haml "users/index".to_sym
    else
      redirect_to "/users/#{env['warden'].user.id}", :error => "You are not admin"
    end
  end

  get "/users/:id" do
    env['warden'].authenticate!
    @active_tab = "users"
    @user = User.get(params[:id])
    haml "users/show".to_sym
  end
end