# encoding: utf-8
ENV['RACK_ENV'] = "development" unless ENV['RACK_ENV'] != nil

require "rubygems"
require "bundler/setup"

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
	  require_relative 'lib/remote_syslog'
		set :haml, { :ugly=>true }
		set :clean_trace, true
		set :css_files, :blob
		set :js_files,  :blob
		MinifyResources.minify_all
		logger = RemoteSyslog.new(Settings.remote_log_host,Settings.remote_log_port)
		use Rack::CommonLogger, logger
	end

	configure :development do
	  set :server, %w[unicorn thin webrick]
    set :show_exceptions, true
		set :css_files, MinifyResources::CSS_FILES
		set :js_files,  MinifyResources::JS_FILES
	end

	helpers do
		include Rack::Utils
		alias_method :h, :escape_html
	end
end

require_relative 'helpers/init'
require_relative 'models/init'
require_relative 'routes/init'