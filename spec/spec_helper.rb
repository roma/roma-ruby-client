# -*- coding: utf-8 -*-
require 'rspec'

$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
Dir[File.dirname(__FILE__) + "/supports/**/*.rb"].each {|f| require f}

require 'roma-client'

RSpec.configure do |config|
  config.mock_with :rr
end

