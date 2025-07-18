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
      @reflex_instance ||= build_reflex_instance
    end

    ##
    # Beyond just creating the <Component>Reflex class, we need to define all the component methods on the reflex
    # class.
    # This replaces the old method_missing implementation, and passes more strict validation of recent SR versions
    def build_reflex_instance
      reflex_methods = @component.reflex_methods
      component_allocate = @component.allocate
      Class.new(@component.reflex_base_class).tap do |klass|
        klass.instance_variable_set(:@__method_parameters, {})

        reflex_methods.each do |m|
          klass.instance_variable_get(:@__method_parameters)[m.to_s] = component_allocate.method(m).parameters
          klass.define_method(m) do |*args, &blk|
            delegate_call_to_reflex(m, *args, &blk)
          end
        end

        # SR does validation of incoming arguments against method definitions
        # so we need to fake our method definitions call here
        klass.define_method(:method) do |name|
          method = super(name)
          params = self.class.instance_variable_get(:@__method_parameters)

          if params && params[name]
            method.define_singleton_method(:parameters) do
              params[name]
            end
          end

          method
        end
      end
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
