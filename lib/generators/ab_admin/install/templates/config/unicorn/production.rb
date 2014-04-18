APP_ROOT = File.expand_path('../../..', __FILE__)

require 'redis'
worker_processes 4

#user "unprivileged_user", "unprivileged_group"

working_directory APP_ROOT

listen "#{APP_ROOT}/tmp/sockets/unicorn.sock", backlog: 64
#listen 8080, tcp_nopush: true

timeout 90

pid "#{APP_ROOT}/tmp/pids/unicorn.pid"

stderr_path "#{APP_ROOT}/log/unicorn.stderr.log"
stdout_path "#{APP_ROOT}/log/unicorn.stdout.log"

preload_app true
GC.respond_to?(:copy_on_write_friendly=) and
    GC.copy_on_write_friendly = true

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and
      ActiveRecord::Base.connection.disconnect!

  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end

  sleep 1
end

after_fork do |server, worker|
  # per-process listener ports for debugging/admin/migrations
  # addr = "127.0.0.1:#{9293 + worker.nr}"
  # server.listen(addr, tries: -1, delay: 5, tcp_nopush: true)

  ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)
  Resque.redis.client.reconnect if defined?(Resque)

  $redis = Redis.connect
end
