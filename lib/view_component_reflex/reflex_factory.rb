module ViewComponentReflex
  class ReflexFactory
    def initialize(component)
      @component = component
      @new = false
      reflex.component_class = component
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
      parent = if @component.respond_to? :module_parent
        @component.module_parent
      else
        @component.parent
      end

      if parent.const_defined?(reflex_name)
        parent.const_get(reflex_name)
      else
        @new = true
        parent.const_set(reflex_name, reflex_instance)
      end
    end

    def reflex_from_component
      if Object.const_defined?(reflex_name)
        Object.const_get(reflex_name)
      else
        @new = true
        Object.const_set(reflex_name, reflex_instance)
      end
    end
  end
end
