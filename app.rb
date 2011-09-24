# encoding: utf-8
ENV['RACK_ENV'] = "development" unless ENV['RACK_ENV'] != nil

require "rubygems"
require "bundler/setup"
require_relative "lib/simple_logger"

# get all the gems in
Bundler.require(:default)

require 'rack-flash'
require 'sinatra/redirect_with_flash'
require_relative 'minify_resources'

class MyApp < Sinatra::Application
  use Rack::Flash
  enable :sessions
  enable :logging
  set :haml, :format => :html5

  RailsConfig.load_and_set_settings("./config/settings.yml", "./config/settings/#{settings.environment.to_s}.yml")

  configure :production do
    set :haml, { :ugly=>true }
    set :clean_trace, true
    set :css_files, :blob
    set :js_files,  :blob
    MinifyResources.minify_all
    LOGGER = SimpleLogger.new
    use Rack::CommonLogger, LOGGER

    helpers do
      def logger
        LOGGER
      end
    end
    LOGGER.info("Starting")
  end

  configure :development, :test do
    set :server, %w[unicorn thin webrick]
    set :show_exceptions, true
    set :css_files, MinifyResources::CSS_FILES
    set :js_files,  MinifyResources::JS_FILES
    LOGGER = SimpleLogger.new("log/#{ENV['RACK_ENV']}.log")
    use Rack::CommonLogger, LOGGER

    helpers do
      def logger
        LOGGER
      end
    end
    LOGGER.info("Starting")
  end

  helpers do
    include Rack::Utils
    alias_method :h, :escape_html
  end
end

require_relative 'helpers/init'
require_relative 'models/init'
require_relative 'routes/init'
