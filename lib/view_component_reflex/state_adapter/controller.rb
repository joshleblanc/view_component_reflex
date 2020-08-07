module ViewComponentReflex
  module StateAdapter
    class Controller

      KEY = :@__view_component_reflex_state

      def self.state(_, controller, key)
        unless controller.instance_variable_defined?(KEY)
          controller.instance_variable_set(KEY, {})
        end
        s = controller.instance_variable_get(KEY)
        s[key] ||= {}
      end

      def self.set_state(request, controller, key, new_state)
        new_state.each do |k, v|
          state(request, controller, key)[k] = v
        end
      end

      def self.store_state(request, controller, key, new_state = {})
        unless controller.instance_variable_defined?(KEY)
          controller.instance_variable_set(KEY, {})
        end
        s = controller.instance_variable_get(KEY)
        s[key] = {}
        new_state.each do |k, v|
          s[key][k] = v
        end
      end
    end
  end
end
