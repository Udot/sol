require 'net/http'
require "net/https"
require "json"

module MercureApi
  extend self
  def create(username, repository)
    repository_path = "#{Settings.repos.root_dir}/#{username}/#{repository}"
    payload = {:user => username, :path => repository_path}
    return self.post("/repositories/create", payload.to_json)
  end
  
  private
  def get(request)
    http_r = Net::HTTP.new(Settings.mercure_api.host, Settings.mercure_api.port)
    http_r.use_ssl = Settings.mercure_api.ssl
    response = nil
    http_r.start() do |http|
      req = Net::HTTP::Get.new(request)
      req.add_field("USERNAME", Settings.mercure_api.username)
      req.add_field("TOKEN", Settings.mercure_api.token)
      response = http.request(req)
    end
    return [response.code, response.body]
  end

  def post(request,json_payload)
    http_r = Net::HTTP.new(Settings.mercure_api.host, Settings.mercure_api.port)
    http_r.use_ssl = Settings.mercure_api.ssl
    response = nil
    http_r.start() do |http|
      req = Net::HTTP::Post.new(request, initheader = {'Content-Type' =>'application/json'})
      req.add_field("USERNAME", Settings.mercure_api.username)
      req.add_field("TOKEN", Settings.mercure_api.token)
      req.body = json_payload
      response = http.request(req)
    end
    return [response.code, response.body]
  end
end