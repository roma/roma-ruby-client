require File.expand_path(File.join('..', '..', 'spec_helper'), File.dirname(__FILE__))

describe Roma::Client::ClientPool do
  before(:all) do
    start_roma
  end

  after(:all) do
    stop_roma
  end

  def get_nodes
    DEFAULT_PORTS.map { |port| "#{DEFAULT_HOST}:#{port}" }
  end

  context 'Singleton' do
    subject { Roma::Client::ClientPool.instance(:test) }
    it { expect(subject.class).to eq(Roma::Client::ClientPool) }

    it { expect(subject).to be_equal Roma::Client::ClientPool.instance(:test) }

    it { expect(subject).not_to be_equal Roma::Client::ClientPool.instance(:test2) }

    it do
      expect { Roma::Client::ClientPool.new }.to raise_error(NoMethodError,
        "private method `new' called for Roma::Client::ClientPool:Class")
    end
  end

  context 'max pool size of default' do
    subject { Roma::Client::ClientPool.instance(:test) }

    describe '#max_pool_size' do
      subject { super().max_pool_size }
      it { is_expected.to eq(1) }
    end
  end

  context 'set max pool size ' do
    it do
      pool = Roma::Client::ClientPool.instance(:test)
      expect(pool.max_pool_size).to eq(1)
      pool.max_pool_size = 3
      expect(pool.max_pool_size).to eq(3)

      pool2 = Roma::Client::ClientPool.instance(:test2)
      expect(pool2.max_pool_size).to eq(1)
    end
  end

  context 'servers default' do
    subject { Roma::Client::ClientPool.instance(:test) }

    describe '#servers' do
      subject { super().servers }
      it { is_expected.to be_nil }
    end
  end

  context 'servers set' do
    it do
      pool = Roma::Client::ClientPool.instance(:test_servers_set)
      expect(pool.servers).to be_nil
      nodes = get_nodes
      pool.servers = nodes
      expect(pool.servers).to eq(nodes)

      expect(Roma::Client::ClientPool.instance(:test_ini_nodes_set2).servers).to be_nil
    end
  end

  context 'client' do
    subject do
      pool = Roma::Client::ClientPool.instance(:test_client)
      pool.servers = get_nodes
      pool
    end

    it { expect(subject.pool_count).to eq(0) }
    it do
      client = subject.client
      expect(client.class).to eq(Roma::Client::RomaClient)
      subject.push_client(client)
      expect(subject.pool_count).to eq(1)
    end
    it { expect(subject.servers).to eq(get_nodes) }
  end

  context 'client multi pool' do
    subject do
      pool = Roma::Client::ClientPool.instance(:test_client2)
      pool.servers = get_nodes
      pool
    end

    it do
      expect(subject.pool_count).to eq(0)
      client  = subject.client
      expect(client).not_to be_nil

      client2 = subject.client
      expect(client2).not_to be_nil

      subject.push_client(client)
      expect(subject.pool_count).to eq(1)

      subject.push_client(client2)
      expect(subject.pool_count).to eq(1)

      expect(client).to be_equal subject.client
      expect(subject.pool_count).to eq(0)
    end
  end

  context 'plugin modules' do
    module TestPlugin
      def test_plugin
        'test_plugin'
      end
    end

    module TestPlugin2
      def test_plugin2
        'test_plugin2'
      end
    end

    it do
      pool = Roma::Client::ClientPool.instance(:pm_test)
      expect(pool.plugin_modules).to be_nil

      pool.add_plugin_module(TestPlugin)
      expect(pool.plugin_modules).not_to be_nil
      expect(pool.plugin_modules.size).to eq(1)
      pool.plugin_modules[0] == TestPlugin
    end

    it do
      pool = Roma::Client::ClientPool.instance(:pms_test)
      expect(pool.plugin_modules).to be_nil

      pool.plugin_modules = [TestPlugin, TestPlugin2]
      expect(pool.plugin_modules.size).to eq(2)
      pool.plugin_modules[0] == TestPlugin
      pool.plugin_modules[1] == TestPlugin2
    end

    it do
      pool = Roma::Client::ClientPool.instance(:pms_test2)
      pool.servers = get_nodes
      expect(pool.plugin_modules).to be_nil

      pool.plugin_modules = [TestPlugin, TestPlugin2]
      client = pool.client
      expect(client).not_to be_nil
      expect(client.test_plugin).to eq('test_plugin')
      expect(client.test_plugin2).to eq('test_plugin2')
    end
  end

  context 'default type' do
    subject { Roma::Client::ClientPool.instance }
    it { is_expected.not_to be_nil }
    it { expect(subject.class).to eq(Roma::Client::ClientPool) }
    it { expect(subject).to be_equal Roma::Client::ClientPool.instance(:default) }
  end

  context 'support hash name' do
    after(:all) { Roma::Client::ClientPool.instance.default_hash_name = 'roma' }

    subject do
      pool = Roma::Client::ClientPool.instance
      pool.servers = get_nodes
      pool
    end

    it { expect(subject.default_hash_name).to eq('roma') }
    it do
      subject.default_hash_name = 'new_name'
      expect(subject.default_hash_name).to eq('new_name')
      expect(Roma::Client::ClientPool.instance.default_hash_name).to eq('new_name')
      expect(Roma::Client::ClientPool.instance(:other).default_hash_name).to eq('roma')

      client = subject.client
      expect(client.default_hash_name).to eq('new_name')
    end
  end

  context 'release' do
    subject do
      pool = Roma::Client::ClientPool.instance(:release_test)
      pool.servers = get_nodes
      pool
    end

    it do
      expect(subject.pool_count).to eq(0)
      subject.client do |client|
      end

      expect(subject.pool_count).to eq(1)
      expect(subject.release).to be_truthy
      expect(subject.pool_count).to eq(0)
    end
  end

  context 'client block' do
    before(:each) do
      pool = Roma::Client::ClientPool.instance(:client_block)
      pool.release
    end

    subject do
      pool = Roma::Client::ClientPool.instance(:client_block)
      pool.servers = get_nodes
      pool
    end

    it 'use block'do
      expect(subject.pool_count).to eq(0)
      subject.client do |client|
        expect(client.set('test', 'value')).to eq('STORED')
      end
      expect(subject.pool_count).to eq(1)
    end

    it 'raise exception in block, but pool certainly' do
      expect(subject.pool_count).to eq(0)
      subject.client do |client|
        expect(client.set('test', 'value')).to eq('STORED')
      end
      expect(subject.pool_count).to eq(1)

      expect do
        subject.client do |client|
          raise 'test error'
        end
      end.to raise_error RuntimeError, 'test error'

      expect(subject.pool_count).to eq(1)
    end
  end

  context 'start sync routing proc' do
    it do
      pool = Roma::Client::ClientPool.instance(:sync_test)
      pool.servers = get_nodes
      old_thread_count = Thread.list.length
      pool.client do |c|
      end

      expect(pool.pool_count).to eq(1)
      expect(Thread.list.length).to eq(old_thread_count + 1)
    end

    it do
      pool = Roma::Client::ClientPool.instance(:no_sync_test)
      pool.servers = get_nodes
      pool.start_sync_routing_proc = false
      old_thread_count = Thread.list.length
      pool.client do |c|
      end

      expect(pool.pool_count).to eq(1)
      expect(Thread.list.length).to eq(old_thread_count)
    end
  end

  context 'release all' do
    it do
      pool = Roma::Client::ClientPool.instance(:release_all_1)
      pool.servers = get_nodes
      pool.client do |c|
      end
      expect(Roma::Client::ClientPool.instance(:release_all_1).pool_count).to eq(1)

      pool = Roma::Client::ClientPool.instance(:release_all_2)
      pool.servers = get_nodes
      pool.client do |c|
      end
      expect(pool.pool_count).to eq(1)
      expect(Roma::Client::ClientPool.instance(:release_all_2).pool_count).to eq(1)

      Roma::Client::ClientPool.release_all
      expect(Roma::Client::ClientPool.instance(:release_all_1).pool_count).to eq(0)
      expect(Roma::Client::ClientPool.instance(:release_all_2).pool_count).to eq(0)

      expect(Roma::Client::ClientPool.instance(:release_all_1).servers).to eq(get_nodes)
      expect(Roma::Client::ClientPool.instance(:release_all_2).servers).to eq(get_nodes)
    end
  end
end
