# encoding : utf-8
class MyApp < Sinatra::Application
  get "/dragons" do
    env['warden'].authenticate!
    @active_tab = "dragons"
    haml "dragons/index".to_sym
  end
end