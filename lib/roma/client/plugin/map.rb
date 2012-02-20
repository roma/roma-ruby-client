module Roma
  module Client
    module Plugin
      module Map
      
        def map_set(key, mapkey, value, expt = 0)
          value_validator(value)
          sender(:oneline_receiver, key, value, "map_set %s #{mapkey} 0 #{expt} #{value.length}")
        end

        def map_get(key, mapkey)
          ret = sender(:value_list_receiver, key, nil, "map_get %s #{mapkey}")
          return nil if ret==nil || ret.length == 0
          ret[0]
        end

        def map_delete(key, mapkey)
          sender(:oneline_receiver, key, nil, "map_delete %s #{mapkey}")
        end

        def map_clear(key)
          sender(:oneline_receiver, key, nil, "map_clear %s")
        end

        def map_size(key)
          ret = sender(:oneline_receiver, key, nil, "map_size %s")
          return ret.to_i if ret =~ /\d+/
          ret
        end

        def map_key?(key, mapkey)
          ret = sender(:oneline_receiver, key, nil, "map_key? %s #{mapkey}")
          if ret == 'true'
            true
          elsif ret == 'false'
            false
          else
            ret
          end
        end

        def map_value?(key, value)
          value_validator(value)
          ret = sender(:oneline_receiver, key, value, "map_value? %s #{value.length}")
          if ret == 'true'
            true
          elsif ret == 'false'
            false
          else
            ret
          end        
        end

        def map_empty?(key)
          ret = sender(:oneline_receiver, key, nil, "map_empty? %s")
          if ret == 'true'
            true
          elsif ret == 'false'
            false
          else
            ret
          end
        end

        def map_keys(key)
          ret = sender(:value_list_receiver, key, nil, "map_keys %s")
          return nil if ret.length == 0
          ret[0] = ret[0].to_i
          ret
        end
        
        def map_values(key)
          ret = sender(:value_list_receiver, key, nil, "map_values %s")
          return nil if ret.length == 0
          ret[0] = ret[0].to_i
          ret
        end
        
        def map_to_s(key)
          ret = sender(:value_list_receiver, key, nil, "map_to_s %s")
          return nil if ret.length == 0
          ret[0]
        end
        
        private
        
        def value_validator(value)
          if value == nil || !value.instance_of?(String)
            raise "value must be a String object."
          end
        end
        
      end # module Map
    end # module Plugin
  end # module Client
end # module Roma
