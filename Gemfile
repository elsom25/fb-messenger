source 'https://rubygems.org'
ruby '2.0.0'

gem 'rails',                '4.0.0'           # Rails
gem 'sqlite3', group: [:development, :test]   # Dev & Test DB
gem 'pg',      group: :production             # Production DB

# Servers
gem 'puma'
gem 'unicorn'

# Auth
gem 'omniauth'                                # OmniAuth
gem 'omniauth-facebook'                       # Facebook hook
gem 'koala'                                   # Facebook api
gem 'xmpp4r_facebook'                         # Facebook chat api

# Security
gem 'secure_headers'

# Javascript
gem 'jquery-rails'                            # jQuery
gem 'jquery-turbolinks'                       # jQuery compatibility with Rails 4
gem 'modernizr-rails'                         # Modernizr
gem 'gon'                                     # Rails vars in JS
gem 'i18n-js'                                 # I18n in JS

# Assets
gem 'sass-rails',           '~> 4.0.0'
gem 'coffee-rails',         '~> 4.0.0'
gem 'slim-rails'
gem 'compass-rails',        '~> 2.0.alpha.0'
gem 'font-awesome-rails'
gem 'zurb-foundation'

gem 'turbolinks'                              # Makes page loads faster
gem 'uglifier',             '>= 1.3.0'

group :development, :test do
  gem 'debugger'
  gem 'delorean'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'pry'
  gem 'pry-rails'
end

group :development do
  gem 'bullet'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
end

group :test do
  gem 'capybara'
  gem 'coveralls', require: false
  gem 'database_cleaner'
  gem 'email_spec'
  gem 'launchy'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  gem 'webmock', require: false
end

group :staging, :production do
  gem 'rails_12factor'
end
