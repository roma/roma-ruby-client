require 'rspec'
require 'open3'
require 'roma/romad'

$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
Dir[File.dirname(__FILE__) + '/supports/**/*.rb'].each { |f| require f }

require 'roma-client'

DEFAULT_HOST = '127.0.0.1'
DEFAULT_PORTS = %w(12001 12002)

def start_roma(host: DEFAULT_HOST, ports: DEFAULT_PORTS)
  nodes = ports.map{ |port| "#{host}_#{port}" }

  nodes.each do |node|
    FileUtils.rm(Dir.glob(["#{node}.log*", "#{node}.route*"]))
  end

  Open3.capture3("mkroute #{nodes.join(' ')} --replication_in_host")

  ports.each do |port|
    Open3.capture3("romad #{host} -p #{port} -d --replication_in_host --disabled_cmd_protect")
  end
end

def stop_roma(host: DEFAULT_HOST, port: DEFAULT_PORTS[0])
  conn = Roma::Messaging::ConPool.instance.get_connection("#{host}_#{port}")
  if conn
    conn.write "balse\r\n"
    conn.gets
    conn.write "yes\r\n"
    conn.gets
    conn.close
  end
  Roma::Client::ConPool.instance.close_all
rescue => e
  puts "#{e} #{ $ERROR_POSITION}"
end
