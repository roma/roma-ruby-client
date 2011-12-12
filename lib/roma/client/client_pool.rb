# -*- coding: utf-8 -*-
require 'singleton'

module Roma
  module Client
    # RomaClient Pool class
    #
    # This class is implemented as Singleton.
    # You can get RomaClient as follows.
    #
    #   client = Roma::Client::ClientPool.instance.client
    #
    # You can change pool size of RomaClient to call "max_pool_size=" method .
    # Default max pool size is 1.
    class ClientPool
      private_class_method :new

      attr_accessor :ini_nodes

      @@client_pools = {}

      # get ClientPool instance
      # type:: identifier for client groups.
      def self.instance(type)
        @@client_pools[type] ||= new
        @@client_pools[type]
      end

      # get RomaClient instance
      #
      # type:: RomaClient instance group.
      # return:: RomaClient instance
      def client
        if @clients.nil?
          Roma::Client::RomaClient.new
        else
          @clients.pop
        end
      end

      # push RomaClient instance
      def push_client=
        @clients ||= []
        @clients.push(client)
      end

      # get max pool size
      def max_pool_size
        @max_pool_size
      end

      # set max_pool_size
      def max_pool_size=(count)
        @max_pool_size = count
      end

      private
      def initialize
        @max_pool_size = 1
        @clients = []
        self.ini_nodes = nil
      end
    end
  end
end
