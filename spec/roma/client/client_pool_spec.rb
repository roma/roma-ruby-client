require 'spec_helper'

describe Roma::Client::ClientPool do

  let(:test_nodes) do
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

  describe '#max_pool_size' do
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
  end

  describe '#servers' do
    subject { Roma::Client::ClientPool.instance(:test).servers }

    it { is_expected.to be_nil }

    context 'servers set' do
      it do
        pool = Roma::Client::ClientPool.instance(:test_servers_set)
        expect(pool.servers).to be_nil
        nodes = test_nodes
        pool.servers = nodes
        expect(pool.servers).to eq(nodes)

        expect(Roma::Client::ClientPool.instance(:test_ini_nodes_set2).servers).to be_nil
      end
    end
  end

  describe '#client' do
    subject do
      pool = Roma::Client::ClientPool.instance(:test_client)
      pool.max_pool_size = 1
      pool.servers = test_nodes
      pool
    end

    before do
      subject.release
    end

    context 'When the pool is empty' do
      it 'should generate client instance' do
        dummy_client = double(:client).as_null_object
        expect(Roma::Client::RomaClient).to receive(:new).and_return(dummy_client)

        subject.client
      end

      context 'When the pool is full' do
        let(:pushed_client) { double('pushed_client') }
        let(:ignored_client) { double('new dummy client to be ignored') }

        before do
          subject.push_client(pushed_client)
          subject.push_client(ignored_client)
        end

        it 'the last pushed client is ignored' do
          expect(subject.pool_count).to eq(1)
          expect(subject.clients).to include(pushed_client)
          expect(subject.clients).to_not include(ignored_client)
        end
      end
    end

    context 'client multi pool' do
      subject do
        pool = Roma::Client::ClientPool.instance(:test_client2)
        pool.servers = test_nodes
        pool
      end

      it do
        dummy_client = double(:client).as_null_object
        expect(Roma::Client::RomaClient).to receive(:new).and_return(dummy_client).twice

        expect(subject.pool_count).to eq(0)
        client = subject.client
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

    context 'When block is given' do
      it do
        dummy_client = double(:client).as_null_object
        expect(Roma::Client::RomaClient).to receive(:new).and_return(dummy_client)

        expect { |b| subject.client(&b) }.to yield_with_args(dummy_client)
      end
    end
  end

  describe '#plugin_modules' do
    before do
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
    end

    it do
      pool = Roma::Client::ClientPool.instance(:pm_test)
      expect(pool.plugin_modules).to be_nil

      pool.add_plugin_module(TestPlugin)
      expect(pool.plugin_modules).not_to be_nil
      expect(pool.plugin_modules.size).to eq(1)
      expect(pool.plugin_modules[0]).to eq(TestPlugin)
    end

    context 'the pool has some plugin moudles' do
      let(:pool) { Roma::Client::ClientPool.instance(:pms_test) }

      before do
        pool.plugin_modules = [TestPlugin, TestPlugin2]
      end

      it do
        expect(pool.plugin_modules.size).to eq(2)
        expect(pool.plugin_modules).to contain_exactly(TestPlugin, TestPlugin2)
      end

      it 'pool.client generates roma client with pool.plugin_modules' do
        client = double('roma client').as_null_object
        expect(Roma::Client::RomaClient).to receive(:new).
          with(pool.servers, pool.plugin_modules, pool.start_sync_routing_proc).and_return(client)

        pool.client
      end
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
      pool.servers = test_nodes
      pool
    end

    it { expect(subject.default_hash_name).to eq('roma') }
    it do
      subject.default_hash_name = 'new_name'
      expect(subject.default_hash_name).to eq('new_name')
      expect(Roma::Client::ClientPool.instance.default_hash_name).to eq('new_name')
      expect(Roma::Client::ClientPool.instance(:other).default_hash_name).to eq('roma')

      client = double('roma client').as_null_object
      expect(client).to receive(:default_hash_name=).with('new_name')
      expect(Roma::Client::RomaClient).to receive(:new).and_return(client)
      subject.client
    end
  end

  context 'release' do
    subject do
      pool = Roma::Client::ClientPool.instance(:release_test)
      pool.servers = test_nodes
      pool
    end

    it do
      subject.push_client(double('dummy client'))
      expect(subject.pool_count).to eq(1)
      expect(subject.release).to be_truthy
      expect(subject.pool_count).to eq(0)
    end
  end

  context 'release all' do
    it do
      pool = Roma::Client::ClientPool.instance(:release_all_1)
      pool.servers = test_nodes
      pool.push_client(double('dummy client 1'))
      expect(Roma::Client::ClientPool.instance(:release_all_1).pool_count).to eq(1)

      pool = Roma::Client::ClientPool.instance(:release_all_2)
      pool.servers = test_nodes
      pool.push_client(double('dummy client 1'))
      expect(pool.pool_count).to eq(1)
      expect(Roma::Client::ClientPool.instance(:release_all_2).pool_count).to eq(1)

      Roma::Client::ClientPool.release_all
      expect(Roma::Client::ClientPool.instance(:release_all_1).pool_count).to eq(0)
      expect(Roma::Client::ClientPool.instance(:release_all_2).pool_count).to eq(0)
      expect(Roma::Client::ClientPool.instance(:release_all_1).servers).to eq(test_nodes)
      expect(Roma::Client::ClientPool.instance(:release_all_2).servers).to eq(test_nodes)
    end
  end
end
