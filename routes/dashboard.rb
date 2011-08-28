# encoding : utf-8
class MyApp < Sinatra::Application
  get "/dashboard" do
    env['warden'].authenticate!
    @active_tab = "dashboard"
    @services = Array.new
    @services << {"name" => "Git gate", "description" => "Gateway to the trove", "status" => MercureApi.gate_status, "url" => "#"}
    haml "private/index".to_sym
  end
end