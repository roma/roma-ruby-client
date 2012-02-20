module Roma
  module Client
    module Plugin
      module Alist

        def alist_at(key, index)
          ret = sender(:value_list_receiver, key, nil, "alist_at %s #{index}")
          return nil if ret.length == 0
          ret[0]
        end

        def alist_clear(key)
          sender(:oneline_receiver, key, nil, "alist_clear %s")
        end

        def alist_delete(key, value)
          value_validator(value)
          sender(:oneline_receiver, key, value, "alist_delete %s #{value.length}")
        end

        def alist_delete_at(key, index)
          sender(:oneline_receiver, key, nil, "alist_delete_at %s #{index}")
        end

        def alist_empty?(key)
          sender(:oneline_receiver, key, nil, "alist_empty? %s")
        end

        def alist_first(key)
          ret = sender(:value_list_receiver, key, nil, "alist_first %s")
          return nil if ret.length == 0
          ret[0]
        end

        def alist_gets(key, range=nil)
          if range
            ret = sender(:value_list_receiver, key, nil, "alist_gets %s #{range}")
          else
            ret = sender(:value_list_receiver, key, nil, "alist_gets %s")
          end
          return nil if ret.length == 0
          ret[0] = ret[0].to_i
          ret
        end

        def alist_gets_with_time(key, range=nil)
          if range
            ret = sender(:value_list_receiver, key, nil, "alist_gets_with_time %s #{range}")
          else
            ret = sender(:value_list_receiver, key, nil, "alist_gets_with_time %s")
          end
          return nil if ret.length == 0
          ret[0] = ret[0].to_i
          ret
        end

        def alist_include?(key, value)
          sender(:oneline_receiver, key, value, "alist_include? %s #{value.length}")
        end
        
        def alist_index(key, value)
          value_validator(value)
          ret = sender(:oneline_receiver, key, value, "alist_index %s #{value.length}")
          return ret.to_i if ret =~ /\d+/
          return nil if ret=='nil'
          ret
        end

        def alist_insert(key, index, value)
          value_validator(value)
          sender(:oneline_receiver, key, value, "alist_insert %s #{index} #{value.length}")
        end

        def alist_sized_insert(key, array_size, value)
          sender(:oneline_receiver, key, value, "alist_sized_insert %s #{array_size} #{value.length}")
        end
        
        def alist_swap_and_insert(key, value)
          sender(:oneline_receiver, key, value, "alist_swap_and_insert %s #{value.length}")
        end

        def alist_swap_and_sized_insert(key, array_size, value)
          value_validator(value)
          sender(:oneline_receiver, key, value, "alist_swap_and_sized_insert %s #{array_size} #{value.length}")
        end

        def alist_expired_swap_and_insert(key, expt, value)
          value_validator(value)
          sender(:oneline_receiver, key, value,
                 "alist_expired_swap_and_insert %s #{expt} #{value.length}")
        end

        def alist_expired_swap_and_sized_insert(key, expt, array_size, value)
          value_validator(value)
          sender(:oneline_receiver, key, value,
                 "alist_expired_swap_and_sized_insert %s #{expt} #{array_size} #{value.length}")
        end

        def alist_join(key, sep, range=nil)
          if range
            ret = sender(:value_list_receiver, key, sep, "alist_join %s #{sep.length} #{range}")
          else
            ret = sender(:value_list_receiver, key, sep, "alist_join %s #{sep.length}")
          end
          return nil if ret.length == 0
          ret[0] = ret[0].to_i
          ret
        end

        def alist_join_with_time(key, sep, range=nil)
          if range
            ret = sender(:value_list_receiver, key, sep,
                         "alist_join_with_time %s #{sep.length} #{range}")
          else
            ret = sender(:value_list_receiver, key, sep,
                         "alist_join_with_time %s #{sep.length}")
          end
          return nil if ret.length == 0
          ret[0] = ret[0].to_i
          ret
        end

        def alist_to_json(key, range=nil)
          if range
            ret = sender(:value_list_receiver, key, nil, "alist_to_json %s #{range}")
          else
            ret = sender(:value_list_receiver, key, nil, "alist_to_json %s")
          end
          return nil if ret.length == 0
          ret[0]
        end

        def alist_last(key)
          ret = sender(:value_list_receiver, key, nil, "alist_last %s")
          return nil if ret.length == 0
          ret[0]
        end

        def alist_length(key)
          ret = sender(:oneline_receiver, key, nil, "alist_length %s")
          return ret.to_i if ret =~ /\d+/
          ret
        end

        def alist_pop(key)
          ret = sender(:value_list_receiver, key, nil, "alist_pop %s")
          return nil if ret.length == 0
          ret[0]
        end

        def alist_push(key, value)
          value_validator(value)
          sender(:oneline_receiver, key, value, "alist_push %s #{value.length}")
        end

        def alist_sized_push(key, array_size, value)
          value_validator(value)
          sender(:oneline_receiver, key, value,
                 "alist_sized_push %s #{array_size} #{value.length}")
        end

        def alist_swap_and_push(key, value)
          value_validator(value)
          sender(:oneline_receiver, key, value, "alist_swap_and_push %s #{value.length}")
        end

        def alist_swap_and_sized_push(key, array_size, value)
          value_validator(value)
          sender(:oneline_receiver, key, value,
                 "alist_swap_and_sized_push %s #{array_size} #{value.length}")
        end

        def alist_expired_swap_and_push(key, expt, value)
          value_validator(value)
          sender(:oneline_receiver, key, value,
                 "alist_expired_swap_and_push %s #{expt} #{value.length}")
        end

        def alist_expired_swap_and_sized_push(key, expt, array_size, value)
          value_validator(value)
          sender(:oneline_receiver, key, value,
                 "alist_expired_swap_and_sized_push %s #{expt} #{array_size} #{value.length}")
        end

        def alist_update_at(key, index, value)
          value_validator(value)
          sender(:oneline_receiver, key, value,
                 "alist_update_at %s #{index} #{value.length}")
        end

        def alist_shift(key)
          ret = sender(:value_list_receiver, key, nil, "alist_shift %s")
          return nil if ret.length == 0
          ret[0]
        end

        def alist_to_s(key, range=nil)
          if range
            ret = sender(:value_list_receiver, key, nil, "alist_to_s %s #{range}")
          else
            ret = sender(:value_list_receiver, key, nil, "alist_to_s %s")
          end
          return ret if ret.instance_of?(String)
          return nil if ret.length == 0
          ret[0] = ret[0].to_i
          ret[1] = eval(ret[1])
          ret
        end

        private

        def value_validator(value)
          if value == nil || !value.instance_of?(String)
            raise "value must be a String object."
          end
        end

      end # module Alist
    end # module Plugin
  end # module Client
end # module Roma
