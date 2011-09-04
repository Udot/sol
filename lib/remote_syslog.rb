class RemoteSyslog
  def initialize(host, port)
    @logger = RemoteSyslogLogger.new(host, port, {:program => 'git_front'})
  end

  def write(str)
    @logger.info(str)
  end
end