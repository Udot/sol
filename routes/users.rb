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

  get "/users/:id/edit" do
    env['warden'].authenticate!
    @active_tab = "users"
    @user = User.get(params[:id])
    haml "users/edit".to_sym
  end

  post "/users/:id/update" do
    env['warden'].authenticate!
    user = User.get(params[:id])
    user.name = params[:name]
    user.email = params[:email]
    user.role = params[:role] if (env['warden'].user.admin? && user.id != env['warden'].user.id)
    user.save
    if (params[:password] && params[:password_confirmation]) && ((params[:password] != "") && (params[:password_confirmation] != "") && (params[:password] == params[:password_confirmation]))
      user.password = params[:password]
      user.password_confirmation = params[:password_confirmation]
      user.save
    elsif (params[:password] && params[:password_confirmation]) && ((params[:password] != "") && (params[:password_confirmation] != "") && (params[:password] != params[:password_confirmation]))
      redirect "/users/#{user.id}/edit", :error => "Passwords don't match."
    end
    redirect "/users/#{user.id}"
  end
end