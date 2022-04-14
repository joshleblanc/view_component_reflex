module ViewComponentReflex
  class Engine < ::Rails::Engine

    mattr_accessor :state_adapter
    Engine.state_adapter = StateAdapter::Session

    config.to_prepare do
      StimulusReflex::Channel.class_eval do
        unless instance_methods.include?(:receive_original)
          alias_method :receive_original, :receive
          def receive(data)
            target = data["target"].to_s
            reflex_name, _ = target.split("#")
            reflex_name = reflex_name.camelize
            component_name = reflex_name.end_with?("Reflex") ? reflex_name[0...-6] : reflex_name
            component = begin
              component_name.constantize
            rescue
              # Since every reflex runs through this monkey patch, we're just going to ignore the ones that aren't for components
            end

            if component 
              if component.respond_to?(:init_stimulus_reflex)
                component.init_stimulus_reflex
              else
                Rails.logger.info "Tried to initialize view_component_reflex on #{component_name}, but it's not a view_component_reflex"
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
