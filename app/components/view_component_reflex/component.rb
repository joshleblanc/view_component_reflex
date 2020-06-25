module ViewComponentReflex
  class Component < ViewComponent::Base
    class << self
      def init_stimulus_reflex
        klass = self
        @stimulus_reflex ||= Object.const_set(name + "Reflex", Class.new(StimulusReflex::Reflex) {
          def refresh!(primary_selector = "[data-controller~=\"#{stimulus_controller}\"][data-key=\"#{element.dataset[:key]}\"]", *selectors)
            save_state
            @channel.send :render_page_and_broadcast_morph, self, [primary_selector, *selectors], {
              "dataset" => element.dataset.to_h,
              "args" => [],
              "attrs" => element.attributes.to_h,
              "selectors" => ["body"],
              "target" => "#{self.class.name}##{method_name}",
              "url" => request.url,
              "permanent_attribute_name" => "data-reflex-permanent"
            }
          end

          def refresh_all!
            refresh!("body")
          end

          # SR's delegate_call_to_reflex in channel.rb
          # uses method to gather the method parameters, but since we're abusing
          # method_missing here, that'll always fail
          def method(name)
            name.to_sym.to_proc
          end

          def respond_to_missing?(name, _ = false)
            !!name.to_proc
          end

          before_reflex do |a|
            a.send a.method_name
            throw :abort
          end

          def method_missing(name, *args)
            super unless respond_to_missing?(name)
            state.each do |k, v|
              component.instance_variable_set(k, v)
            end
            name.to_proc.call(component, *args)
            refresh! unless @prevent_refresh
          end

          def prevent_refresh!
            @prevent_refresh = true
          end

          define_method :component_class do
            @component_class ||= klass
          end

          private :component_class

          private

          def stimulus_controller
            component_class.stimulus_controller
          end

          def component
            return @component if @component
            @component = component_class.allocate
            reflex = self
            exposed_methods = [:params, :request, :element, :refresh!, :refresh_all!, :stimulus_controller, :session, :prevent_refresh!]
            exposed_methods.each do |meth|
              @component.define_singleton_method(meth) do |*a|
                reflex.send(meth, *a)
              end
            end
            @component
          end

          def set_state(new_state = {})
            ViewComponentReflex::Engine.state_adapter.set_state(request, controller, element.dataset[:key], new_state)
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

    def self.stimulus_controller
      name.chomp("Component").underscore.dasherize
    end

    def stimulus_reflex?
      helpers.controller.instance_variable_get(:@stimulus_reflex)
    end

    def component_controller(opts_or_tag = :div, opts = {}, &blk)
      self.class.init_stimulus_reflex
      init_key

      tag = :div
      if opts_or_tag.is_a? Hash
        options = opts_or_tag
      else
        tag = opts_or_tag
        options = opts
      end
      options[:data] = {
        controller: self.class.stimulus_controller,
        key: key,
        **(options[:data] || {})
      }
      content_tag tag, capture(&blk), options
    end

    # key is required if you're using state
    # We can't initialize the session state in the initial method
    # because it doesn't have a view_context yet
    # This is the next best place to do it
    def init_key
      # we want the erb file that renders the component. `caller` gives the file name,
      # and line number, which should be unique. We hash it to make it a nice number
      key = caller.select { |p| p.include? ".html.erb" }[1]&.hash.to_s
      key += collection_key.to_s if collection_key
      @key = key
    end

    def reflex_tag(reflex, name, content_or_options_with_block = nil, options = nil, escape = true, &block)
      action, method = reflex.to_s.split("->")
      if method.nil?
        method = action
        action = "click"
      end
      data_attributes = {
        reflex: "#{action}->#{self.class.name}##{method}",
        key: key
      }
      if content_or_options_with_block.is_a?(Hash)
        merge_data_attributes(content_or_options_with_block, data_attributes)
      else
        merge_data_attributes(options, data_attributes)
      end
      content_tag(name, content_or_options_with_block, options, escape, &block)
    end

    def collection_key
      nil
    end

    def permit_parameter?(initial_param, new_param)
      initial_param != new_param
    end

    def omitted_from_state
      []
    end

    def key
      # initialize session state
      if !stimulus_reflex? || session[@key].nil?
        new_state = {}

        # this will almost certainly break
        blacklist = [
          :@view_context, :@lookup_context, :@view_renderer, :@view_flow,
          :@virtual_path, :@variant, :@current_template, :@output_buffer, :@key,
          :@helpers, :@controller, :@request, :@content
        ]
        instance_variables.reject { |k| blacklist.include?(k) }.each do |k|
          new_state[k] = instance_variable_get(k) unless omitted_from_state.include?(k)
        end
        ViewComponentReflex::Engine.state_adapter.store_state(request, @key, new_state)
        ViewComponentReflex::Engine.state_adapter.store_state(request, "#{@key}_initial", new_state)
      else
        initial_state = ViewComponentReflex::Engine.state_adapter.state(request, "#{@key}_initial")
        ViewComponentReflex::Engine.state_adapter.state(request, @key).each do |k, v|
          unless permit_parameter?(initial_state[k], instance_variable_get(k))
            instance_variable_set(k, v)
          end
        end
      end
      @key
    end

    private

    def merge_data_attributes(options, attributes)
      data = options[:data]
      if data.nil?
        options[:data] = attributes
      else
        options[:data].merge! attributes
      end
    end
  end
end
