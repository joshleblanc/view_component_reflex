module ViewComponentReflex
    class NullBroadcaster < StimulusReflex::Broadcaster
      def broadcast(_, data)
        nil
      end
  
      def nothing?
        true
      end
  
      def to_sym
        :nothing
      end
  
      def to_s
        "Nothing"
      end
    end
  end