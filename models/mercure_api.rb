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

  def post(request,payload)
    #head = "http"
    #head = "https" if Settings.mercure_api.ssl
    
    #response = RestClient.post "#{head}://#{Settings.mercure_api.host}:#{Settings.mercure_api.port}/#{request}", {:data => json_payload}, {:content_type => :json, :accept => :json}
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

  def other_post(username, rpath)
    @post_ws = "/repositories/create"

    @payload ={"user" => username, "path" => rpath}.to_json
    req = Net::HTTP::Post.new(@post_ws, initheader = {'Content-Type' =>'application/json'})
    req.body = @payload
    req.add_field("USERNAME", Settings.mercure_api.username)
    req.add_field("TOKEN", Settings.mercure_api.token)
    response = Net::HTTP.new(Settings.mercure_api.host, Settings.mercure_api.port).start {|http| http.request(req) }
    return response
  end
end