lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'rake'
require 'roma/client/version'

Gem::Specification.new do |s|
  s.name = 'roma-client'
  s.version = Roma::Client::VERSION::STRING
  s.authors = ['Muga Nishizawa', 'Junji Torii']
  s.summary = 'ROMA client library'
  s.description = 'ROMA client library'
  s.homepage = 'http://roma-kvs.org/'
  s.license = 'GPL-3.0'
  s.files = FileList[
    '[A-Z]*',
    'bin/**/*',
    'lib/**/*',
    'test/**/*.rb',
    'spec/**/*.rb',
    'doc/**/*',
    'examples/**/*',
  ]

  # Use these for libraries.
  s.require_path = 'lib'

  s.has_rdoc = true
  s.rdoc_options = [
    '--line-numbers',
    '--inline-source',
    '--main', 'README',
    '-c UTF-8',
  ]
  s.extra_rdoc_files = ['README', 'CHANGELOG']

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rdoc'
  s.add_development_dependency 'roma'
end
