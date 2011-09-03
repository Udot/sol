require 'uri'

class RemoteSyslog
  def initialize(uri)
    uri = URI.parse(uri)
    @logger = RemoteSyslogLogger.
      new(uri.host, uri.port,
          :local_hostname => "#{ENV['APP_NAME']}-#{ENV['PS']}")
  end

  def write(str)
    @logger.info(str)
  end
end