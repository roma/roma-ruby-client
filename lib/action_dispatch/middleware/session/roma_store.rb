# -*- coding: utf-8 -*-

require 'active_support/cache'
require 'action_dispatch/middleware/session/abstract_store'

module ActionDispatch
  module Session
    # RomaStore class for Rails cache
    class RomaStore < AbstractStore
      # RomaStore constractor .
      #
      # If :cache option is set, :cache value will be used by cache client.
      # If :cache option is not set, 
      def initialize(app, options = {})
        options[:expire_after] ||= options[:expires]
        super

        @pool = options[:cache] || Roma::Client::RomaClient.new(@default_options[:roma_servers],
                                                          @default_options[:roma_plugin_modules])
        unless @pool.servers.any? { |s| s.alive? }
          raise "#{self} unable to find server during initialization."
        end
      end

      private
      # get current session id
      #
      # Overwrite AbstractStore for security reason.
      # Check session id is correct value.
      def current_session_id(env)
        if env[ENV_SESSION_OPTIONS_KEY][:id]
          if env[ENV_SESSION_OPTIONS_KEY][:id] =~ SID_VALIDATE
            return env[ENV_SESSION_OPTIONS_KEY][:id]
          else
            env[ENV_SESSION_OPTIONS_KEY][:id] = nil
            return nil
          end
        end
      end

      def get_session(env, sid)
        sid ||= generate_sid
        begin
          session = @pool.get(sid) || {}
        rescue Exception
          session = {}
        end
        [sid, session]
      end

      def set_session(env, sid, session_data)
        options = env['rack.session.options']
        expiry  = options[:expire_after] || 0
        @pool.set(sid, session_data, expiry)
        sid
      rescue Exception
        false
      end

      def destroy(env)
        if sid = current_session_id(env)
          @pool.delete(sid)
        end
      rescue Exception
        false
      end

      SID_VALIDATE = /[0-9a-zA-Z]{32}/
    end
  end
end
