module ViewComponentReflex
  module StateAdapter
    class Base

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
