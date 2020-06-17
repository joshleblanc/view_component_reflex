module ViewComponentReflex
  class Component < ViewComponent::Base
    class << self
      def init_stimulus_reflex
        klass = self
        @stimulus_reflex ||= Object.const_set(name + "Reflex", Class.new(StimulusReflex::Reflex) {
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

          # SR's delegate_call_to_reflex in channel.rb
          # uses method to gather the method parameters, but since we're abusing
          # method_missing here, that'll always fail
          def method(name)
            name.to_sym.to_proc
          end

          def method_missing(name, *args)
            reflex = self
            exposed_methods = [:element, :refresh!, :refresh_all!]
            exposed_methods.each do |meth|
              component.define_singleton_method(meth) do |*a|
                reflex.send(meth, *a)
              end
            end
            state.each do |k, v|
              component.instance_variable_set(k, v)
            end
            name.to_proc.call(component, *args)
            refresh!
          end

          define_method :stimulus_controller do
            klass.name.chomp("Component").underscore.dasherize
          end

          define_method :component_class do
            @component_class ||= klass
          end

          private :component_class, :stimulus_controller
          private
          def component
            @component ||= component_class.allocate
          end

          def set_state(new_state = {}, primary_selector = nil, *selectors)
            ViewComponentReflex::Engine.state_adapter.set_state(self, element.dataset[:key], new_state)
          end

          def state
            ViewComponentReflex::Engine.state_adapter.state(request, element.dataset[:key])
          end

          def save_state
            new_state = {}
            component.instance_variables.each do |k|
              new_state[k] = component.instance_variable_get(k)
            end
            set_state(new_state)
          end
        })
      end
    end

    def stimulus_reflex?
      helpers.controller.instance_variable_get(:@stimulus_reflex)
    end

    # key is required if you're using state
    # We can't initialize the session state in the initial method
    # because it doesn't have a view_context yet
    # This is the next best place to do it
    def key
      self.class.init_stimulus_reflex
      # we want the erb file that renders the component. `caller` gives the file name,
      # and line number, which should be unique. We hash it to make it a nice number
      @key ||= caller.select { |p| p.include? ".html.erb" }[1]&.hash.to_s

      # initialize session state
      if !stimulus_reflex? || session[@key].nil?
        new_state = {}

        # this will almost certainly break
        blacklist = [
          :@view_context, :@lookup_context, :@view_renderer, :@view_flow,
          :@virtual_path, :@variant, :@current_template, :@output_buffer, :@key,
          :@helpers, :@controller, :@request
        ]
        instance_variables.reject { |k| blacklist.include?(k) }.each do |k|
          new_state[k] = instance_variable_get(k)
        end
        ViewComponentReflex::Engine.state_adapter.store_state(request, @key, new_state)
      else
        ViewComponentReflex::Engine.state_adapter.state(request, @key).each do |k, v|
          instance_variable_set(k, v)
        end
      end
      @key
    end
  end
end
