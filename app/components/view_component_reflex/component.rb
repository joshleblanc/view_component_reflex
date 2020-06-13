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

          def refresh!(primary_selector = "[data-controller=\"#{stimulus_controller}\"]", *selectors)
            @channel.send :render_page_and_broadcast_morph, self, [primary_selector, *selectors], {
              dataset: element.dataset.to_h,
              args: [],
              attrs: element.attributes.to_h,
              selectors: ['body'],
              target: "#{self.class.name}##{method_name}",
              url: request.url,
              permanentAttributeName: "data-reflex-permanent"
            }
          end

          def refresh_all!
            refresh!('body')
          end

          def set_state(new_state = {})
            ViewComponentReflex::Engine.state_adapter.set_state(self, element.dataset[:key], new_state)
            refresh!
          end

          before_reflex do |reflex, *args|
            instance_exec(*args, &self.class.callbacks[self.method_name.to_sym]) if self.class.callbacks.include?(self.method_name.to_sym)
            throw :abort
          end

          def self.callbacks
            @callbacks ||= {}
          end

          define_method :stimulus_controller do
            klass.name.chomp("Component").underscore.dasherize
          end

          define_singleton_method(:reflex) do |name, &blk|
            callbacks[name] = blk
            define_method(name) do |*args|
            end
          end
        })
      end
    end

    def initialize_state(obj)
      @state = obj
    end

    def stimulus_reflex?
      helpers.controller.instance_variable_get(:@stimulus_reflex)
    end

    # key is required if you're using state
    # We can't initialize the session state in the initial method
    # because it doesn't have a view_context yet
    # This is the next best place to do it
    def key
      @key ||= caller.find { |p| p.include? ".html.erb" }&.hash.to_s

      # initialize session state
      if !stimulus_reflex? || session[@key].nil?
        ViewComponentReflex::Engine.state_adapter.store_state(request, @key, @state)
        ViewComponentReflex::Engine.state_adapter.store_state(request, "#{@key}_initial", @state)
      else
        # ViewComponentReflex::Engine.state_adapter.reconcile_state(request, @key, @state)
      end
      @key
    end

    def state
      ViewComponentReflex::Engine.state_adapter.state(request, key)
    end
  end
end
