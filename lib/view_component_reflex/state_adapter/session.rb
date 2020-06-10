module ViewComponentReflex
  module StateAdapter
    class Session
      def self.state(request, key)
        request.session[key] ||= {}
      end

      def self.set_state(reflex, key, new_state)
        new_state.each do |k, v|
          state(reflex.request, key)[k] = v
        end
        store = reflex.request.session.instance_variable_get("@by")
        store.commit_session reflex.request, reflex.controller.response
      end

      def self.store_state(request, key, new_state = {})
        request.session[key] = {}
        new_state.each do |k, v|
          request.session[key][k] = v
        end
      end

      # The passed state should always match the initial state of the component
      # if it doesn't, we need to reset the state to the passed value.
      #
      # This handles cases where your initialize_state param computes some value that changes
      # initialize_state({ transaction: @customer.transactions.first })
      # if you delete the first transaction, that ^ is no longer valid. We need to update the state.
      def self.reconcile_state(request, key, new_state)
        request.session["#{key}_initial"].each do |k, v|
          if new_state[k] != v
            request.session[key][k] = new_state[k]
          end
        end
      end
    end
  end
end
