# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

# resque
require 'resque/tasks'
task "resque:preload" => :environment

task "resque:setup" do
  ENV['QUEUE'] = '*'
end

task "jobs:work" => "resque:work"

# back to our regularly scheduled Rakefile...
PlatformDashboard::Application.load_tasks
