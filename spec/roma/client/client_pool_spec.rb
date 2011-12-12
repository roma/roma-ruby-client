# -*- coding: utf-8 -*-
require File.expand_path(File.join('..', '..', 'spec_helper'), File.dirname(__FILE__))

describe Roma::Client::ClientPool do
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

  context "ini_nodes default" do
    subject { Roma::Client::ClientPool.instance(:test) }
    its(:ini_nodes) { should be_nil }
  end

  context "ini_nodes set" do
    it {
      pool = Roma::Client::ClientPool.instance(:test_ini_nodes_set)
      pool.ini_nodes.should be_nil
      nodes = ['127.0.0.1:11211', '127.0.0.1:11212']
      pool.ini_nodes = nodes
      pool.ini_nodes.should == nodes

      Roma::Client::ClientPool.instance(:test_ini_nodes_set2).ini_nodes.should be_nil
    }
  end

  context "client" do
    it { pending "implement test for client/push_client later" }
  end
end

