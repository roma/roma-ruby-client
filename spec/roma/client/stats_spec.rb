require File.expand_path(File.join('..', '..', 'spec_helper'), File.dirname(__FILE__))

describe Roma::Client::Stats do
  before(:all) do
    start_roma
    nodes = DEFAULT_PORTS.map { |port| "#{DEFAULT_HOST}:#{port}" }
    @client = Roma::Client::RomaClient.new(nodes)
    @stats = @client.stats
  end

  after(:all) do
    stop_roma
  end

  context 'first level' do
    it 'accessible to version' do
      expect(@stats['version']).to match(/\d+\.\d+\.\d+.*/)
    end
  end

  context 'second level' do
    it 'accessible to routing.redundant' do
      expect(@stats['routing']['redundant']).to eq('2')
    end
  end

  context 'third level' do
    it 'accessible to routing.nodes.length' do
      expect(@stats['routing']['vnodes']['length']).to eq('512')
    end
  end
end
