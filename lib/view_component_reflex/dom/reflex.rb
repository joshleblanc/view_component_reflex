module ViewComponentReflex
  module Dom
    class Reflex < ViewComponentReflex::Reflex
      def state
        @state ||= if element.dataset[:state]
          Verifier.verify(element.dataset[:state])
        else
          {}
        end
      end

      def inject_key_into_component
        super
        component.tap do |k|
          k.instance_variable_set(:@states, {
            element.dataset[:key] => state,
            "#{element.dataset[:key]}_initial" => initial_state
          })
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
