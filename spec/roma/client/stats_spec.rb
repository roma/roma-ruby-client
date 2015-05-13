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
      expect(@stats['routing.redundant']).to eq('2')
    end
  end

  context 'third level' do
    it 'accessible to routing.nodes.length' do
      expect(@stats['routing.vnodes.length']).to eq('512')
    end
  end

  context 'filter argument' do
    it 'responce only stats.run_recover' do
      keyword = 'stats.run_recover'
      stat = @client.stats(filter: keyword)
      expect(stat.keys.size).to eq(1)
      expect(stat[keyword]).to eq('false')
    end
  end

  context 'node argument' do
    it 'responce from accessed port' do
      DEFAULT_PORTS.each do |port|
        stat = @client.stats(node: "#{DEFAULT_HOST}:#{port}")
        expect(stat['stats.address']).to eq(DEFAULT_HOST)
        expect(stat['stats.port']).to eq(port)
      end
    end
  end

  context 'filter and node arguments' do
    it 'responce only stats.address and stats.port from accessed port' do
      DEFAULT_PORTS.each do |port|
        keywords = %w(address port)
        stat = @client.stats(filter: keywords.join('|'), node: "#{DEFAULT_HOST}:#{port}")
        expect(stat.keys.size).to eq(2)
        expect(stat['stats.address']).to eq(DEFAULT_HOST)
        expect(stat['stats.port']).to eq(port)
      end
    end
  end
end
