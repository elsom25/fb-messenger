worker_processes Integer(ENV['WEB_CONCURRENCY'] || 3)
timeout 15
preload_app true

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!

  @resque_pid ||= spawn('bundle exec sidekiq -c 2')
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection

  ENV['REDISCLOUD_URL'] ||= 'redis://localhost:6379'
  Sidekiq.configure_client do |config|
    config.redis = { size: 1, namespace: 'sidekiq', url: ENV['REDISCLOUD_URL'] }
  end
  Sidekiq.configure_server do |config|
    config.redis = { size: 5, namespace: 'sidekiq', url: ENV['REDISCLOUD_URL'] }
  end

end
