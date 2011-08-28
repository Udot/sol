require 'net/http'
require "net/https"
require "json"

module MercureApi
  extend self
  def create(username, repository)
    repository_path = "#{Settings.repos.root_dir}/#{username}/#{repository}.git"
    payload = {"user" => username, "path" => repository_path}
    return self.post("/repositories/create", payload)
    #return self.other_post(username, repository_path)
  end

  def status(username, repository)
    repository_path = "#{Settings.repos.root_dir}/#{username}/#{repository}.git"
    payload = {"path" => repository_path}
    return self.post("/repositories/status", payload)
  end

  def gate_status
    code, body = self.get("/alive")
    if (code == "200") || (code == 200)
      return "alive"
    else
      return "dead"
    end
  end

  def deploy_keys(authfile)
    repository_path = "#{Settings.repos.root_dir}/#{username}/#{repository}.git"
    payload = {:data => {"authfile" => authfile}.to_json}
    code, response = self.post("/keys", payload)
    if (code == "200") || (code == 200)
      return true
    end
    return false
  end
  
  def get(request)
    http_r = Net::HTTP.new(Settings.mercure_api.host, Settings.mercure_api.port)
    http_r.use_ssl = Settings.mercure_api.ssl
    response = nil
    begin
      http_r.start() do |http|
        req = Net::HTTP::Get.new(request)
        req.add_field("USERNAME", Settings.mercure_api.username)
        req.add_field("TOKEN", Settings.mercure_api.token)
        response = http.request(req)
      end
    rescue Errno::ECONNREFUSED
      return false
    end
    return [response.code, response.body]
  end

  def post(request,payload)
    http_r = Net::HTTP.new(Settings.mercure_api.host, Settings.mercure_api.port)
    http_r.use_ssl = Settings.mercure_api.ssl
    response = nil
    http_r.start() do |http|
      req = Net::HTTP::Post.new(request, initheader = {'Content-Type' =>'application/json'})
      req.add_field("USERNAME", Settings.mercure_api.username)
      req.add_field("TOKEN", Settings.mercure_api.token)
      req.body = payload
      req.set_form_data(payload)
      response = http.request(req)
    end
    return [response.code, response.body]
  end

end