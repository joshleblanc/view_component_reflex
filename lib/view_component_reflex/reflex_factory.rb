module ViewComponentReflex
  class ReflexFactory
    def initialize(component)
      @component = component
      @new = false
      reflex.component_class = component

      Rails.logger.info "initialized reflex factory"
      Rails.logger.info component
    end

    def nested?
      @nested ||= @component.name.include?("::")
    end

    def reflex_name
      @reflex_name ||= if nested?
        @component.name.split("::").last
      else
        @component.name
      end + "Reflex"
    end

    def new?
      @new
    end

    def reflex
      @reflex ||= if nested?
        reflex_from_nested_component
      else
        reflex_from_component
      end
    end

    def reflex_instance
      @reflex_instance ||= Class.new(@component.reflex_base_class)
    end

    def reflex_from_nested_component
      if @component.module_parent.const_defined?(reflex_name)
        @component.module_parent.const_get(reflex_name)
      else
        @new = true
        @component.module_parent.const_set(reflex_name, reflex_instance)
      end
    end

    def reflex_from_component
      Rails.logger.info "Getting reflex from component"
      Rails.logger.info reflex_name
      if Object.const_defined?(reflex_name)
        Rails.logger.info "Reflex exists"
        Object.const_get(reflex_name)
      else
        @new = true
        Rails.logger.info "reflex doesn't exist"
        val = Object.const_set(reflex_name, reflex_instance)
        Rails.logger.info val
        val
      end
    end
  end
end
