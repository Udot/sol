require 'rack/test'

begin 
  require_relative '../app.rb'
rescue NameError
  require File.expand_path('../app.rb', __FILE__)
end

module RSpecMixin
  include Rack::Test::Methods
  def app() MyApp.new end
end

RSpec.configure { |c| c.include RSpecMixin }


class Logger
  def write(message)

  end  
end