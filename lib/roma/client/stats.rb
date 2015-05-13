module Roma
  module Client
    # TODO: Implement accessors and return values with correct type
    # Now: client.stats["routing"]["redundant"] #=> "2"
    # Better: client.stats.routing.redundant #=> 2
    class Stats < Hash
      def initialize(stats_str)
        stats_str.each_line do |line|
          line =~ /^(.+?)\s(.+)/
          key = Regexp.last_match(1)
          value = Regexp.last_match(2).chomp
          return unless key || value
          names = key.split('.')
          set_value(self, names, value)
        end
      end

      def set_value(hash, names, value)
        if names.length == 1
          hash[names.first] = value
          return value
        end

        name = names.shift
        hash[name] = {} unless hash.key?(name)
        set_value(hash[name], names, value)
      end
      private :set_value
    end
  end
end
