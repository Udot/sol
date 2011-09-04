require ::File.join( ::File.dirname(__FILE__), 'app' )
require "remote_syslog_logger"
if ENV['RACK_ENV'] == "production"
  @current_path = File.expand_path(File.dirname(__FILE__))
  require "#{@current_path}/lib/remote_syslog"

  use Rack::CommonLogger, RemoteSyslogLogger.new(Settings.remote_log_host,Settings.remote_log_port)
else
  logger = Logger.new("log/#{ENV['RACK_ENV']}.log")
	use Rack::CommonLogger, logger
end
run MyApp.new