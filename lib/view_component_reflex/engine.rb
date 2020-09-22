module ViewComponentReflex
  class Engine < ::Rails::Engine
    class << self
      mattr_accessor :state_adapter

      self.state_adapter = StateAdapter::Memory
    end

    config.to_prepare do
      StimulusReflex::Channel.class_eval do
        unless instance_methods.include?(:receive_original)
          alias_method :receive_original, :receive
          def receive(data)
            target = data["target"].to_s
            reflex_name, _ = target.split("#")
            reflex_name = reflex_name.camelize
            component_name = reflex_name.end_with?("Reflex") ? reflex_name[0...-6] : reflex_name
            if component_name.end_with?("Component")
              begin
                component_name.constantize.init_stimulus_reflex
              rescue
                p "Tried to initialize view_component_reflex on #{component_name}, but it's not a view_component_reflex"
              end

            end
            receive_original(data)
          end
        end
      end
    end

    def self.configure
      yield self if block_given?
    end
  end
end
