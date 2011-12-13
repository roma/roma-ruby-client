# -*- coding: utf-8 -*-
require 'rubygems'
require 'rake'
require 'rubygems/package_task'

if File.exist?(File.expand_path('Gemfile', File.dirname(__FILE__)))
  require 'bundler/setup'
end

begin
  require 'rdoc/task'
rescue LoadError
  require 'rake/rdoctask'
end

RDOC_OPTIONS = [
                '--line-numbers',
                '--inline-source',
                "--main", "README",
                "-c UTF-8",
               ]

# gem tasks
PKG_FILES = FileList[
  '[A-Z]*',
  'bin/**/*',
  'lib/**/*.rb',
  'test/**/*.rb',
  'spec/**/*.rb',
  'doc/**/*',
  'examples/**/*',
                    ]

require File.expand_path(File.join("lib", "roma", "client", "version"),
                         File.dirname(__FILE__))

VER_NUM = Roma::Client::VERSION::STRING

if VER_NUM =~ /([0-9.]+)$/
  CURRENT_VERSION = $1
else
  CURRENT_VERSION = "0.0.0"
end

begin
  require 'rspec/core'
  require 'rspec/core/rake_task'
rescue LoadError
  puts "no rspec"
else
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.ruby_opts=""
    t.rcov = false
  end
  task :default => :spec
end

SPEC = Gem::Specification.new do |s|
  s.authors = ["Muga Nishizawa", "Junji Torii"]
  s.name = "roma-client"
  s.version = CURRENT_VERSION
  s.summary = "ROMA client library"
  s.description = <<-EOF
    ROMA client library
  EOF
  s.files = PKG_FILES.to_a

  s.require_path = 'lib'                         # Use these for libraries.

  s.has_rdoc = true
  s.rdoc_options.concat RDOC_OPTIONS
  s.extra_rdoc_files = ["README", "CHANGELOG"]
end

package_task = Gem::PackageTask.new(SPEC) do |pkg|
end


Rake::RDocTask.new("doc") { |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title = "ROMA documents"
  rdoc.options.concat RDOC_OPTIONS
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.include("README")
  rdoc.rdoc_files.include("CHANGELOG")
}

