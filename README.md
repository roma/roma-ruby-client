# ROMA Client for Ruby

[![Build Status](https://travis-ci.org/roma/roma-ruby-client.svg?branch=master)](https://travis-ci.org/roma/roma-ruby-client)
[![Gem Version](https://badge.fury.io/rb/roma-client.svg)](https://badge.fury.io/rb/roma-client)

ROMA is one of the data storing systems for distributed key-value stores in Ruby.
The gem `roma-client` is Ruby client to talk with ROMA severs.


## Install

Add this line to your application's Gemfile:

```ruby
  gem 'roma-client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install roma-client


## Usage

```ruby
  require 'roma/client'

  nodes = ['host1:11211', 'host2:11211']
  client = Roma::Client::RomaClient.new(nodes)

  key = 'key'
  res = client.set(key, 'valie')
  puts "put:#{res}"

  puts "get:#{client.get key}"

  res = client.delete key
  puts "del:#{res}"
  puts "get:#{client.get key}"
```

## Development

  1. Fork it
  2. Create your feature branch (`git checkout -b my-new-feature`)
  3. Commit your changes (`git commit -am 'Add some feature'`)
  4. Push to the branch (`git push origin my-new-feature`)
  5. Create new Pull Request


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/roma/roma-ruby-client. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

GPL v3

---
Copyright (C) 2009 Rakuten, Inc. 
