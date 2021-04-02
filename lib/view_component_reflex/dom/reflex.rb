module ViewComponentReflex
  module Dom
    module Reflex
      def state
        @state ||= if element.dataset[:"#{key}_state"]
          Verifier.verify(element.dataset[:"#{key}_state"])
        else
          {}
        end
      end

      def inject_key_into_component
        super
        states = element.dataset.to_h.inject({}) do |memo, (k, v)|
          if k.to_s.end_with?("-state") || k.to_s.end_with?("-initial")
            memo[k] = v
          end
          memo
        end
        component.tap do |k|
          k.instance_variable_set(:@states, states)
        end
      end

      def set_state(new_state = {})
        @state = new_state
      end

      def initial_state
        @state ||= if element.dataset[:initial_state]
          Verifier.verify(element.dataset[:initial_state])
        else
          {}
        end
      end
    end
  end
end
