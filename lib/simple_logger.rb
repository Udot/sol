require "syslog"

class SimpleLogger
  attr_accessor :file
  def initialize(file_path = nil)
    @file = file_path
    self.info("Starting")
  end

  def info(msg)
    log_write("info",msg)
  end
  def warn(msg)
    log_write("warn",msg)
  end
  def error(msg)
    log_write("error",msg)
  end
  def log_write(level, msg)
    # crit CRITICAL system level events (like “System is going down…”)
    #emerg emergency
    #alert
    #err
    #warning
    #notice
    #info
    #debug
    if (file == nil)
      case level
      when "info"
        Syslog.open($0, Syslog::LOG_PID | Syslog::LOG_CONS) { |s| s.info msg }
      when "err" || "error"
        Syslog.open($0, Syslog::LOG_PID | Syslog::LOG_CONS) { |s| s.err msg }
      when "warn" || "warning"
        Syslog.open($0, Syslog::LOG_PID | Syslog::LOG_CONS) { |s| s.warning msg }
      when "debug"
        Syslog.open($0, Syslog::LOG_PID | Syslog::LOG_CONS) { |s| s.debug msg }
      when "notice"
        Syslog.open($0, Syslog::LOG_PID | Syslog::LOG_CONS) { |s| s.notice msg }
      when "alert"
        Syslog.open($0, Syslog::LOG_PID | Syslog::LOG_CONS) { |s| s.alert msg }
      end
    else
      File.open(file, "a") { |f| f.puts "#{level[0].capitalize} :: #{$0} :: #{level} : #{msg}" }
    end
  end
  def write(msg)
    log_write("info", msg)
  end
end

