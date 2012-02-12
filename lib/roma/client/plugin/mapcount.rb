require 'json'
require 'time'

module Roma #:nodoc
  module Client #:nodoc
    module Plugin #:nodoc

      # MapCount plugin module for ROMA client
      module MapCount
        # get mapcount (for JSON value)
        #
        # key:: key to get mapcount data
        # sub_keys:: array to get mapcount data subkeys.
        #            subkey can't include "," and ":"
        # return:: result values hash.
        #          If data is not set, return empty hash.
        def mapcount_get(key, sub_keys = nil)
          sub_keys_str = sub_keys_to_req_str(sub_keys)

          ret = sender(:value_list_receiver, key, nil,
                       "mapcount_get %s 0 %d\r\n%s\r\n",
                       sub_keys_str.length, sub_keys_str)
          convert_ret_to_result(ret, :json)
        end

        # get mapcount (for Marshal value)
        #
        # key:: key to get mapcount data
        # sub_keys:: array to get mapcount data subkeys.
        #            subkey can't include "," and ":"
        # return:: result values hash.
        #          If data is not set, return empty hash.
        def mapcount_get_ms(key, sub_keys = nil)
          sub_keys_str = sub_keys_to_req_str(sub_keys)

          ret = sender(:value_list_receiver, key, nil,
                       "mapcount_get_ms %s 0 %d\r\n%s\r\n",
                       sub_keys_str.length, sub_keys_str)
          convert_ret_to_result(ret, :marshal)
        end

        # countup (for JSON value)
        #
        # key:: key to count up data
        # sub_keys:: sub keys to count up.
        #            You can set String 'sk',
        #            or Array ['sk1','sk2','sk3'],
        #            or Hash {'sk1' => 1, 'sk2' => 3} .
        # expt:: expire seconds. This param format is same as RomaClient.set .
        # return:: result values. It is Marshal format string.
        def mapcount_countup(key, sub_keys, expt = 0)
          sub_keys_str = sub_keys_to_req_str(sub_keys)
          ret = sender(:value_list_receiver, key, nil,
                       "mapcount_countup %s %d %d\r\n%s\r\n",
                       expt.to_i, sub_keys_str.length, sub_keys_str)
          convert_ret_to_result(ret, :json)
        end

        # countup (for Marshal value)
        #
        # key:: key to count up data
        # sub_keys:: sub keys to count up.
        #            You can set String 'sk',
        #            or Array ['sk1','sk2','sk3'],
        #            or Hash {'sk1' => 1, 'sk2' => 3} .
        # expt:: expire seconds. This param format is same as RomaClient.set .
        # return:: result values. It is Marshal format string.
        def mapcount_countup_ms(key, sub_keys, expt = 0)
          sub_keys_str = sub_keys_to_req_str(sub_keys)
          ret = sender(:value_list_receiver, key, nil,
                       "mapcount_countup_ms %s %d %d\r\n%s\r\n",
                       expt.to_i, sub_keys_str.length, sub_keys_str)
          convert_ret_to_result(ret, :marshal)
        end

        # update key expire (for JSON value)
        def mapcount_update(key, sub_keys = nil, expt = 0)
          sub_keys_str = sub_keys_to_req_str(sub_keys)
          ret = sender(:value_list_receiver, key, nil,
                       "mapcount_update %s %d %d\r\n%s\r\n",
                       expt.to_i, sub_keys_str.length, sub_keys_str)
          convert_ret_to_result(ret, :json)
        end

        # update key expire (for Marshal value)
        def mapcount_update_ms(key, sub_keys = nil, expt = 0)
          sub_keys_str = sub_keys_to_req_str(sub_keys)
          ret = sender(:value_list_receiver, key, nil,
                       "mapcount_update_ms %s %d %d\r\n%s\r\n",
                       expt.to_i, sub_keys_str.length, sub_keys_str)
          convert_ret_to_result(ret, :marshal)
        end

        private
        def convert_ret_to_result(ret, stype)
          if ret.empty?
            return nil
          end

          if stype == :marshal
            res = Marshal.load(ret[0])
          else
            res = JSON.parse(ret[0])
          end

          if res["last_updated_date"]
            res["last_updated_date"] = Time.parse(res["last_updated_date"])
          end
          res
        end

        def sub_keys_to_req_str(sub_keys)
          sub_keys_str = ''
          if sub_keys.is_a?(String)
            sub_keys_str = sub_keys
          elsif sub_keys.is_a?(Array)
            sub_keys_str = sub_keys.join(',')
          elsif sub_keys.is_a?(Hash)
            sub_keys_str = sub_keys.map{|k,v| "#{k}:#{v}"}.join(",")
          end
          sub_keys_str
        end
      end
    end
  end
end
