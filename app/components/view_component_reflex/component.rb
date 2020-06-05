module ViewComponentReflex
  class Component < ViewComponent::Base
    class << self
      def reflex(name, &blk)
        stimulus_reflex.reflex(name, &blk)
      end

      def stimulus_reflex
        klass = self
        @stimulus_reflex ||= Object.const_set(name + "Reflex", Class.new(StimulusReflex::Reflex) {
          def state
            ViewComponentReflex::Engine.state_adapter.state(request, element.dataset[:key])
          end

          define_method :stimulus_controller do
            klass.name.chomp("Component").underscore.dasherize
          end

          define_singleton_method(:reflex) do |name, &blk|
            define_method(name) do |*args|
              instance_exec(*args, &blk)
            end
          end
        })
      end
    end

    def initialize_state(obj)
      @state = obj
    end

    # key is required if you're using state
    # We can't initialize the session state in the initial method
    # because it doesn't have a view_context yet
    # This is the next best place to do it
    def key
      @key ||= caller.find { |p| p.include? ".html.erb" }&.hash.to_s

      # initialize session state
      if session[@key].nil?
        ViewComponentReflex::Engine.state_adapter.store_state(request, @key, @state)
        ViewComponentReflex::Engine.state_adapter.store_state(request, "#{@key}_initial", @state)
      else
        ViewComponentReflex::Engine.state_adapter.reconcile_state(request, @key, @state)
      end
      @key
    end

    def state
      ViewComponentReflex::Engine.state_adapter.state(request, key)
    end
  end
end
