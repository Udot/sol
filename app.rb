# encoding: utf-8
require "rubygems"
require "bundler/setup"

# get all the gems in
Bundler.require(:default)


require_relative 'minify_resources'
class MyApp < Sinatra::Application
	enable :sessions

	configure :production do
		set :haml, { :ugly=>true }
		set :clean_trace, true
		set :css_files, :blob
		set :js_files,  :blob
		MinifyResources.minify_all
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