##
# State adapters assume that the data lives outside of the rendering pipeline
# By moving the state to the DOM, we need to "hydrate" the state when the reflex comes in with the data
# We're overriding `inject_key_into_component` for this purpose, since it's run once during a reflex,
# and _just_ after the component is initialized, but before it actually does anything.
# This ensures that any actions that the component is taking is going to be operating on the correct
# state

module ViewComponentReflex
  module Dom
    module Reflex
      def state
        if element.dataset[:"#{key}_state"]
          Verifier.verify(element.dataset[:"#{key}_state"])
        else
          {}
        end
      end

      def inject_key_into_component
        super

        p initial_state[:@count]
        state_adapter.store_state(request, key, state)
        state_adapter.store_state(request, "#{key}_initial", initial_state)
      end

      def initial_state
        if element.dataset[:"#{key}_initial"]
          Verifier.verify(element.dataset[:"#{key}_initial"])
        else
          {}
        end
      end
    end
  end
end
