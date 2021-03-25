module ViewComponentReflex
  module Dom
    class Verifier
      class << self
        attr_reader :verifier

        delegate :generate, :verified, :verify, :valid_message?, to: :verifier

        def key
          @key ||= "123"
        end

        def verifier
          Rails.application.message_verifier(:view_component_reflex)
        end
      end
    end
  end
end
