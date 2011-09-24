require "fileutils"
require ::File.join( ::File.dirname(__FILE__), 'app' )
if ENV['RACK_ENV'] == "production"
  @current_path = File.expand_path(File.dirname(__FILE__))
  require "#{@current_path}/lib/simple_logger"
  use Rack::CommonLogger, SimpleLogger.new
  logger.info("Starting RACK")
else
  FileUtils.mkdir("log") unless File.exist?("log")
  logger = SimpleLogger.new("log/#{ENV['RACK_ENV']}.log")
  use Rack::CommonLogger, logger
  logger.info("Starting RACK")
end
run MyApp.new
