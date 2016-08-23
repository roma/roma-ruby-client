require "bundler/gem_tasks"

begin
  require 'rdoc/task'
rescue LoadError
  require 'rake/rdoctask'
end

RDOC_OPTIONS = [
  '--line-numbers',
  '--inline-source',
  "--main", "README.md",
  "-c UTF-8",
]

begin
  require 'rspec/core'
  require 'rspec/core/rake_task'
rescue LoadError
  puts "no rspec"
else
  require 'rspec'
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.ruby_opts=""
    #t.rcov = false
  end
  task :default => :spec
end

Rake::RDocTask.new("doc") do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title = "ROMA documents"
  rdoc.options.concat RDOC_OPTIONS
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.include("README.md")
  rdoc.rdoc_files.include("CHANGELOG.md")
end
