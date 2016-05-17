require 'timeout'
require 'yaml'
require 'roma/client/con_pool'
require 'roma/client/stats'

module Roma
  module Client
    class Sender
      def initialize
      end

      def send_route_mklhash_command(node_id)
        Timeout.timeout(1) do
          conn = ConPool.instance.get_connection(node_id)
          conn.write "mklhash 0\r\n"
          ret = conn.gets
          ConPool.instance.return_connection(node_id, conn)
          return ret.chomp if ret
        end
      rescue => e
        STDERR.puts "#{node_id} #{e.inspect}"
        return nil
      end

      def send_routedump_command(node_id)
        Timeout.timeout(1) do
          buf = RUBY_VERSION.split('.')
          if buf[0].to_i == 1 && buf[1].to_i == 8
            return send_routedump_yaml_command(node_id)
          end
          conn = ConPool.instance.get_connection(node_id)
          conn.write "routingdump\r\n"
          routes_length = conn.gets.to_i
          if (routes_length <= 0)
            conn.close
            return :error if routes_length < 0
            return nil
          end

          routes = ''
          while (routes.length != routes_length)
            routes = routes + conn.read(routes_length - routes.length)
          end
          conn.read(2) # "\r\n"
          conn.gets
          rd = Marshal.load(routes)
          ConPool.instance.return_connection(node_id, conn)
          return rd
        end
      rescue => e
        STDERR.puts "#{node_id} #{e.inspect}"
        nil
      end

      def send_routedump_yaml_command(node_id)
        conn = ConPool.instance.get_connection(node_id)
        conn.write "routingdump yaml\r\n"

        yaml = ''
        while ((line = conn.gets) != "END\r\n")
          yaml << line
        end

        rd = YAML.load(yaml)
        ConPool.instance.return_connection(node_id, conn)
        rd
      end

      def send_stats_command(filter, node_id)
        conn = ConPool.instance.get_connection(node_id)
        cmd = 'stats'
        cmd += " #{filter}" if filter
        conn.write "#{cmd}\r\n"

        stats_str = ''
        while ((line = conn.gets) != "END\r\n")
          stats_str << line
        end

        stats = Roma::Client::Stats.new(stats_str)
        ConPool.instance.return_connection(node_id, conn)
        stats
      end

      def send_version_command(ap)
        conn = ConPool.instance.get_connection(ap)
        conn.write("version\r\n")
        res = conn.gets.chomp
        ConPool.instance.return_connection(ap, conn)
        fail unless res
        res
      end

      def send_verbosity_command(ap)
        conn = ConPool.instance.get_connection(ap)
        # TODO
        ConPool.instance.return_connection(ap, conn)
      end

      def send_command(nid, cmd, value = nil, receiver = :oneline_receiver)
        con = ConPool.instance.get_connection(nid)
        fail unless con
        if value
          con.write "#{cmd}\r\n#{value}\r\n"
        else
          con.write "#{cmd}\r\n"
        end
        ret = send(receiver, con)
        ConPool.instance.return_connection(nid, con)
        if ret && ret.instance_of?(String) &&
           (ret =~ /^SERVER_ERROR/ || ret =~ /^CLIENT_ERROR/)
          fail ret
        end
        ret
      end

      private

      def oneline_receiver(con)
        ret = con.gets
        fail 'connection closed' if ret.nil?
        ret.chomp
      end

      def value_list_receiver(con)
        ret = []
        while (line = con.gets) != "END\r\n"
          s = line.split(' ')
          return line.chomp if s[0] == 'SERVER_ERROR' || s[0] == 'CLIENT_ERROR'
          ret << read_bytes(con, s[3].to_i)
          read_bytes(con, 2)
        end
        ret
      end

      def value_hash_receiver(con)
        ret = {}
        while (line = con.gets) != "END\r\n"
          s = line.split(' ')
          return line.chomp if s[0] == 'SERVER_ERROR' || s[0] == 'CLIENT_ERROR'
          ret[s[1]] = read_bytes(con, s[3].to_i)
          read_bytes(con, 2)
        end
        ret
      end

      def value_casid_receiver(con)
        ret = []
        while (line = con.gets) != "END\r\n"
          s = line.split(' ')
          return line.chomp if s[0] == 'SERVER_ERROR' || s[0] == 'CLIENT_ERROR'
          ret << read_bytes(con, s[3].to_i)
          ret << s[4]
          read_bytes(con, 2)
        end
        ret
      end

      def multiplelines_receiver(con)
        ret = []
        while (line = con.gets) != "END\r\n"
          ret << line.chomp
        end
        ret
      end

      def read_bytes(con, len)
        ret = ''
        until (ret.length == len)
          ret = ret + con.read(len - ret.length)
        end
        ret
      end
    end
  end
end
