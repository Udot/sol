# encoding: utf-8
require "rubygems"
require "bundler/setup"

# get all the gems in
Bundler.require(:default)
DataMapper::Logger.new($stdout, :debug)

require './models/init'

RailsConfig.load_and_set_settings("./config/settings.yml")

class SshKeys < Thor
  include Thor::Actions
  desc "export", "export_keys to a file"
  method_options :file => :string, :required => true
  def export
		File.open(options[:file], "w") { |f| f.write SshKey.export }
  end
end