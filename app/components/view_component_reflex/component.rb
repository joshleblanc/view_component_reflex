module ViewComponentReflex
  class Component < ViewComponent::Base
    class << self
      def init_stimulus_reflex
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

          def set_state(new_state = {}, primary_selector = nil, *selectors)
            ViewComponentReflex::Engine.state_adapter.set_state(self, element.dataset[:key], new_state)
            refresh!(primary_selector, *selectors)
          end

          define_method :method_missing do |name, *args|
            instance = klass.allocate
            state.each do |k, v|
              instance.instance_variable_set(k, v)
            end
            name.to_proc.call(instance, *args)
            new_state = {}
            instance.instance_variables.each do |k|
              new_state[k] = instance.instance_variable_get(k)
            end
            set_state(new_state)
          end

          define_method :stimulus_controller do
            klass.name.chomp("Component").underscore.dasherize
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
      @key ||= caller.select { |p| p.include? ".html.erb" }.last&.hash.to_s

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
