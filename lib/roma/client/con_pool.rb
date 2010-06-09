require 'thread'
require 'socket'
require 'singleton'

module Roma
  module Client
    
    class ConPool
      include Singleton

      attr_accessor :maxlength
      attr_accessor :expire_time

      def initialize(maxlength = 10, expire_time = 60)
        @pool = {}
        @maxlength = maxlength
        @expire_time = expire_time
        @lock = Mutex.new
      end

      def get_connection(ap)
        ret,last = @pool[ap].shift if @pool.key?(ap) && @pool[ap].length > 0
        if ret && last < Time.now - @expire_time
          ret.close
          ret = nil
        end
        ret = create_connection(ap) unless ret
        ret
      rescue
        nil
      end

      def return_connection(ap, con)
        if @pool.key?(ap) && @pool[ap].length > 0
          if @pool[ap].length > @maxlength
            con.close
          else
            @pool[ap] << [con, Time.now]
          end
        else
          @pool[ap] = [[con, Time.now]]
        end
      rescue
      end

      def create_connection(ap)
        addr, port = ap.split(/[:_]/)
        TCPSocket.new(addr, port)
      end

      def delete_connection(ap)
        @pool.delete(ap)
      end

      def close_all
        @pool.each_key{|ap| close_at(ap) }
      end

      def close_same_host(ap)
        host,port = ap.split(/[:_]/)
        @pool.each_key{|eap|
          close_at(eap) if eap.split(/[:_]/)[0] == host
        }
      end
      
      def close_at(ap)
        return unless @pool.key?(ap)
        @lock.synchronize {
          while(@pool[ap].length > 0)
            begin
              @pool[ap].shift.close
            rescue =>e
            end
          end
          @pool.delete(ap)
        }
      end

    end # class ConPool

  end # module Client
end # module Roma
