# -*- coding: utf-8 -*-
require File.expand_path(File.join('..', '..', 'spec_helper'), File.dirname(__FILE__))

describe Roma::Client::ClientPool do
  def get_nodes
    ['127.0.0.1:12001', '127.0.0.1:12002']
  end

  context "Singleton" do
    subject { Roma::Client::ClientPool.instance(:test) }
    it {
      subject.class.should == Roma::Client::ClientPool
    }

    it {
      subject.should be_equal Roma::Client::ClientPool.instance(:test)
    }

    it {
      subject.should_not be_equal Roma::Client::ClientPool.instance(:test2)
    }

    it {
      expect {
        Roma::Client::ClientPool.new
      }.to raise_error(NoMethodError,
                       "private method `new' called for Roma::Client::ClientPool:Class")
    }
  end

  context "max pool size of default" do
    subject{ Roma::Client::ClientPool.instance(:test) }
    its(:max_pool_size) {
      should == 1
    }
  end

  context "set max pool size " do
    it do
      pool = Roma::Client::ClientPool.instance(:test)
      pool.max_pool_size.should == 1
      pool.max_pool_size = 3
      pool.max_pool_size.should == 3

      pool2 = Roma::Client::ClientPool.instance(:test2)
      pool2.max_pool_size.should == 1
    end
  end

  context "servers default" do
    subject { Roma::Client::ClientPool.instance(:test) }
    its(:servers) { should be_nil }
  end

  context "servers set" do
    it {
      pool = Roma::Client::ClientPool.instance(:test_servers_set)
      pool.servers.should be_nil
      nodes = get_nodes
      pool.servers = nodes
      pool.servers.should == nodes

      Roma::Client::ClientPool.instance(:test_ini_nodes_set2).servers.should be_nil
    }
  end

  context "client" do
    subject do
      pool = Roma::Client::ClientPool.instance(:test_client)
      pool.servers = get_nodes
      pool
    end

    it { pending 'TODO: startup or mock roma server'}
    it { subject.pool_count.should == 0 }
    it {
      client = subject.client
      client.class.should == Roma::Client::RomaClient
      subject.push_client(client)
      subject.pool_count.should == 1
    }
    it { pending "TODO: check nodes" }
  end

  context "client multi pool" do
    subject do
      pool = Roma::Client::ClientPool.instance(:test_client2)
      pool.servers = get_nodes
      pool
    end

    it {
      subject.pool_count.should == 0
      client  = subject.client
      client.should_not be_nil

      client2 = subject.client
      client2.should_not be_nil

      subject.push_client(client)
      subject.pool_count.should == 1

      subject.push_client(client2)
      subject.pool_count.should == 1

      client.should be_equal subject.client
      subject.pool_count.should == 0
    }
  end

  context "plugin modules" do
    module TestPlugin
      def test_plugin
        "test_plugin"
      end
    end

     module TestPlugin2
      def test_plugin2
        "test_plugin2"
      end
    end

    it {
      pool = Roma::Client::ClientPool.instance(:pm_test)
      pool.plugin_modules.should be_nil

      pool.add_plugin_module(TestPlugin)
      pool.plugin_modules.should_not be_nil
      pool.plugin_modules.size.should == 1
      pool.plugin_modules[0] == TestPlugin
    }

    it {
      pool = Roma::Client::ClientPool.instance(:pms_test)
      pool.plugin_modules.should be_nil

      pool.plugin_modules = [TestPlugin, TestPlugin2]
      pool.plugin_modules.size.should == 2
      pool.plugin_modules[0] == TestPlugin
      pool.plugin_modules[1] == TestPlugin2
    }

    it {
      pool = Roma::Client::ClientPool.instance(:pms_test2)
      pool.servers = get_nodes
      pool.plugin_modules.should be_nil

      pool.plugin_modules = [TestPlugin, TestPlugin2]
      client = pool.client
      client.should_not be_nil
      client.test_plugin.should == "test_plugin"
      client.test_plugin2.should == "test_plugin2"
    }
  end

  context "default type" do
    subject { Roma::Client::ClientPool.instance }
    it { should_not be_nil }
    it { subject.class.should == Roma::Client::ClientPool }
    it { subject.should be_equal Roma::Client::ClientPool.instance(:default) }
  end

  context "support hash name" do
    after(:all) {
      Roma::Client::ClientPool.instance.default_hash_name = 'roma'
    }

    subject {
      pool = Roma::Client::ClientPool.instance
      pool.servers = get_nodes
      pool
    }

    it { subject.default_hash_name.should == 'roma' }
    it {
      subject.default_hash_name = 'new_name'
      subject.default_hash_name.should == 'new_name'
      Roma::Client::ClientPool.instance.default_hash_name.should == 'new_name'
      Roma::Client::ClientPool.instance(:other).default_hash_name.should == 'roma'

      client = subject.client
      client.default_hash_name.should == 'new_name'
    }
  end
end

