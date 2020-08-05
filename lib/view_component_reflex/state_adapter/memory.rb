VIEW_COMPONENT_REFLEX_MEMORY_STATE = {}
module ViewComponentReflex
  module StateAdapter
    class Memory
      def self.state(request, key)
        VIEW_COMPONENT_REFLEX_MEMORY_STATE[request.session.id.to_s] ||= {}
        VIEW_COMPONENT_REFLEX_MEMORY_STATE[request.session.id.to_s][key] ||= {}
      end

      def self.set_state(request, _, key, new_state)
        new_state.each do |k, v|
          state(request, key)[k] = v
        end
      end

      def self.store_state(request, key, new_state = {})
        VIEW_COMPONENT_REFLEX_MEMORY_STATE[request.session.id.to_s] ||= {}
        VIEW_COMPONENT_REFLEX_MEMORY_STATE[request.session.id.to_s][key] = {}
        new_state.each do |k, v|
          VIEW_COMPONENT_REFLEX_MEMORY_STATE[request.session.id.to_s][key][k] = v
        end
      end
    end
  end
end
