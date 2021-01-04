module ViewComponentReflex
  module StateAdapter
    class Session < Base
      def self.state(request, key)
        request.session[key] ||= {}
      end

      def self.set_state(request, controller, key, new_state)
        new_state.each do |k, v|
          state(request, key)[k] = v
        end
        store = request.session.instance_variable_get("@by")
        store.commit_session request, controller.response
      end

      def self.store_state(request, key, new_state = {})
        request.session[key] = {}
        new_state.each do |k, v|
          request.session[key][k] = v
        end
      end

      def self.wrap_write_async
        yield
      end
    end
  end
end
