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
    end
  end
end
