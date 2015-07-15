module Roma
  module Client
    # TODO: Implement accessors and return values with correct type
    # Now: client.stats["routing.redundant"] #=> "2"
    # Better: client.stats.routing.redundant #=> 2
    class Stats < Hash
      def initialize(stats_str)
        stats_str.each_line do |line|
          line =~ /^(.+?)\s(.+)/
          key = Regexp.last_match(1)
          value = Regexp.last_match(2).chomp
          self[key] = value
        end
      end
    end
  end
end
