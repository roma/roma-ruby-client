# -*- coding: utf-8 -*-
require File.expand_path(File.join('..', '..', 'spec_helper'), File.dirname(__FILE__))

describe Roma::Client::ClientPool do
  context "Singleton" do
    it { Roma::Client::ClientPool.instance.class.should == Roma::Client::ClientPool }
    it {
      expect {
        Roma::Client::ClientPool.new
      }.to raise_error(NoMethodError,
                       "private method `new' called for Roma::Client::ClientPool:Class")
    }
  end
end

