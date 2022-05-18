module ViewComponentReflex
  module StateAdapter
    class Base

      def self.state(request, key)
        # stub
      end

      def self.set_state(request, controller, key, new_state)
        # stub
      end

      def self.store_state(request, key, new_state = {})
        # stub
      end

      def self.wrap_write_async
        yield
      end

      def self.extend_component(component)
        # stub
      end

      def self.extend_reflex(component)
        # stub
      end

      private

      def self.extract_id(request)
        session = request&.session
        if session.respond_to? :id
          session.id.to_s
        else
          nil
        end
      end

    end
  end
end
