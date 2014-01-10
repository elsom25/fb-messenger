ENV['REDISCLOUD_URL'] ||= 'redis://localhost:6379'

Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDISCLOUD_URL'], namespace: 'sidekiq' }
end

unless Rails.env.production?
  Sidekiq.configure_client do |config|
    config.redis = { url: ENV['REDISCLOUD_URL'], namespace: 'sidekiq'  }
  end
end
