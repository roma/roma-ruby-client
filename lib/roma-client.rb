require File.expand_path(File.join('roma', 'client'),
                         File.dirname(__FILE__))
require File.expand_path(File.join('roma', 'client', 'version'),
                         File.dirname(__FILE__))

if defined?(Rails)
  require File.join(File.dirname(__FILE__),
                    'action_dispatch', 'middleware',
                    'session', 'roma_store')
end
