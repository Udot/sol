require ::File.join( ::File.dirname(__FILE__), 'app' )
if ENV['RACK_ENV'] == "production"
  require_relative 'lib/remote_syslog'

  logger = RemoteSyslogLogger.new(Settings.remote_log_host,Settings.remote_log_port)
  use Rack::CommonLogger, logger
else
  logger = Logger.new("log/#{ENV['RACK_ENV']}.log")
	use Rack::CommonLogger, logger
end
run MyApp.new