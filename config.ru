require ::File.join( ::File.dirname(__FILE__), 'app' )
log = File.new("log/#{ENV['RACK_ENV']}.log", "a+")
$stdout.reopen(log)
$stderr.reopen(log)
run MyApp.new