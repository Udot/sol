# encoding : utf-8
class MyApp < Sinatra::Application
  get "/eggs" do
    env['warden'].authenticate!
    @active_tab = "eggs"
    haml "eggs/index".to_sym
  end
end