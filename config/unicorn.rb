# workers
worker_processes 2

# Help ensure your application will always spawn in the symlinked
# "current" directory that Capistrano sets up.
working_directory "/var/www/hosts/git_front/current"
shared_dir = "/var/www/hosts/git_front/shared"
# listen on both a Unix domain socket and a TCP port,
# we use a shorter backlog for quicker failover when busy
listen 8080, :tcp_nopush => true

# nuke workers after 30 seconds instead of 60 seconds (the default)
timeout 30

# feel free to point this anywhere accessible on the filesystem
pid "#{shared_dir}/pids/unicorn-git_front.pid"

# By default, the Unicorn logger will write to stderr.
# Additionally, ome applications/frameworks log to stderr or stdout,
# so prevent them from going to /dev/null when daemonized here:
stderr_path "#{shared_dir}/log/unicorn-git_front.stderr.log"
stdout_path "#{shared_dir}/log/unicorn-git_front.stdout.log"
