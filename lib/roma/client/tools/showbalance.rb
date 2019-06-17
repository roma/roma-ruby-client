#!/usr/bin/env ruby

require 'roma/client/sender'

if ARGV.length < 1
  STDERR.puts "usage:#{$0} node-id"
  exit
end

sender = Roma::Client::Sender.new
rd = sender.send_routedump_command(ARGV[0])
hist = rd.get_histgram

# max length of node-id string
len_nid = 0
rd.nodes.each{|nid|
  len_nid = nid.length if nid.length > len_nid
}

csum = Array.new(rd.rn, 0)
rd.nodes.each{|nid|
  puts sprintf("%-#{len_nid}s %s %d",
               nid,
               hist[nid].inspect,
               hist[nid].inject{|r,n| r + n})
  hist[nid].each_with_index{|n,i|
    csum[i] += n
  }
}

puts sprintf("%#{len_nid}s %s","sum",csum.inspect)

