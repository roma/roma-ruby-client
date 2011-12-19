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

      attr_accessor :servers
      attr_accessor :default_hash_name
      attr_accessor :start_sync_routing_proc

      @@client_pools = {}

      # get ClientPool instance
      # type:: identifier for client groups.
      def self.instance(type = :default)
        @@client_pools[type] ||= new
        @@client_pools[type]
      end

      # get all pool
      def self.client_pools
        @@client_pools
      end

      # release all pool
      def self.release_all
        @@client_pools = {}
      end

      # get RomaClient instance
      #
      # type:: RomaClient instance group.
      # return:: RomaClient instance
      def client
        c = nil
        if @clients.empty?
          client = Roma::Client::RomaClient.new(servers,
                                                plugin_modules,
                                                start_sync_routing_proc)
          client.default_hash_name = default_hash_name
          c = client
        else
          c = @clients.pop
        end

        return c unless block_given?

        begin
          yield c
        ensure
          push_client(c)
        end
      end

      # get pool count of clients
      def pool_count
        @clients.size
      end

      # release all pool clients
      def release
        @clients.clear
        true
      end

      # push RomaClient instance
      def push_client(client)
        if @clients.size < max_pool_size
          @clients.push(client)
        end
      end

      # get max pool size
      def max_pool_size
        @max_pool_size
      end

      # set max_pool_size
      def max_pool_size=(count)
        @max_pool_size = count
      end

      # get all clients
      def clients
        @clients
      end

      # get plugin_modules
      def plugin_modules
        @plugin_modules
      end

      # add plugin module
      def add_plugin_module(m)
        @plugin_modules ||= []
        @plugin_modules.push(m)
      end

      # set plugin modules
      #
      # You can set class Array.
      def plugin_modules=(modules)
        @plugin_modules = modules
      end

      private
      def initialize
        @max_pool_size = 1
        @clients = []
        @plugin_modules = nil
        self.servers = nil
        self.default_hash_name = 'roma'
        self.start_sync_routing_proc = true
      end
    end
  end
end
