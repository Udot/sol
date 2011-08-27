# encoding : utf-8
class MyApp < Sinatra::Application
  get "/keys" do
    env['warden'].authenticate!
    @active_tab = "keys"
    haml "keys/index".to_sym
  end
end