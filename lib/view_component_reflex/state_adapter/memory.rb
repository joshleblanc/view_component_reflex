VIEW_COMPONENT_REFLEX_MEMORY_STATE = {}
module ViewComponentReflex
  module StateAdapter
    class Memory < Base
      def self.state(request, key)
        id = extract_id(request)

        VIEW_COMPONENT_REFLEX_MEMORY_STATE[id] ||= {}
        VIEW_COMPONENT_REFLEX_MEMORY_STATE[id][key] ||= {}
      end

      def self.set_state(request, _, key, new_state)
        new_state.each do |k, v|
          state(request, key)[k] = v
        end
      end

      def self.store_state(request, key, new_state = {})
        id = extract_id(request)

        VIEW_COMPONENT_REFLEX_MEMORY_STATE[id] ||= {}
        VIEW_COMPONENT_REFLEX_MEMORY_STATE[id][key] = {}
        new_state.each do |k, v|
          VIEW_COMPONENT_REFLEX_MEMORY_STATE[id][key][k] = v
        end
      end

      def self.wrap_write_async
        yield
      end
    end
  end
end
