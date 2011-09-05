# encoding : utf-8
class MyApp < Sinatra::Application
  get "/dashboard" do
    env['warden'].authenticate!
    @active_tab = "dashboard"
    @eggs = env['warden'].user.eggs
    @services = Array.new
    @services << {"name" => "Git gate", "description" => "Gateway to the trove", "status" => MercureApi.gate_status, "url" => "#"}
    haml "private/index".to_sym
  end

  get "/about" do
    @active = "about"
    haml :"public/about"
  end

  get "/contact" do
    @active = "contact"
    haml :"public/contact"
  end
end