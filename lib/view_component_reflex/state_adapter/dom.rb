##
# This adapter exists solely to allow switching to dom-based state storage, even
# though dom-based state storage doesn't abide by the same standards as the other adapters
#
# The dom-based state storage is handled by the Dom::Component and Dom::Reflex modules that are prepended
# to Component and Reflex in Engine, if the dom adapter is selected
#
# These modules override various methods to inject state into the dom, as well as encoding/decoding the state from the dom

class CurrentState < ActiveSupport::CurrentAttributes
  attribute :state
end

module ViewComponentReflex
  module StateAdapter
    class Dom < Base
      def self.state(request, key)
        id = extract_id(request)

        CurrentState.state ||= {}
        CurrentState.state[id] ||= {}
        CurrentState.state[id][key] ||= {}
      end

      def self.set_state(request, _, key, new_state)
        new_state.each do |k, v|
          state(request, key)[k] = v
        end
      end

      def self.store_state(request, key, new_state = {})
        id = extract_id(request)

        CurrentState.state ||= {}
        CurrentState.state[id] ||= {}
        CurrentState.state[id][key] = {}

        new_state.each do |k, v|
          CurrentState.state[id][key][k] = v
        end
      end

      def self.wrap_write_async
        yield
      end
    end
  end
end
