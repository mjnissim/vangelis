# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Vangelis::Application.load_tasks

Rake::Task["doc:app"].clear
Rake::Task["doc/app"].clear
Rake::Task["doc/app/index.html"].clear

namespace :doc do
  desc "Generate documentation for the application. Set custom template with TEMPLATE=/path/to/rdoc/template.rb or title with TITLE=\"Custom Title\""
  Rake::RDocTask.new("app") { |rdoc|
    rdoc.rdoc_dir = 'doc/app'
    rdoc.template = ENV['template'] if ENV['template']
    rdoc.title    = ENV['title'] || "Rails Application Documentation"
    rdoc.options << '--line-numbers' << '--inline-source'
    rdoc.options << '--charset' << 'utf-8'
    rdoc.rdoc_files.include('app/**/*.rb')
    rdoc.rdoc_files.include('lib/**/*.rb')
    rdoc.main = 'README'
  }
end