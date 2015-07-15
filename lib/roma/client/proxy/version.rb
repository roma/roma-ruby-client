#
# = roma/client/proxy/version.rb
# This file is derived from roma client proxy daemon.
#
module Roma #:nodoc:
  module Client #:nodoc:
    # == What Is This Library?
    # ROMA client proxy daemon's version module
    #
    module VERSION
      # MAJOR version
      MAJOR = 0

      # MINOR version
      MINOR = 1

      # TINY version
      TINY  = 0

      # Version string
      STRING = [MAJOR, MINOR, TINY].join('.')
    end
  end
end
