module ViewComponentReflex
  class Component < ViewComponent::Base
    class_attribute :reflex_base_class, default: ViewComponentReflex::Reflex
    attr_reader :key

    class << self
      def init_stimulus_reflex
        factory = ViewComponentReflex::ReflexFactory.new(self)
        @stimulus_reflex ||= factory.reflex
        wire_up_callbacks if factory.new?
      end

      def queue_callback(key, args, blk)
        callbacks(key).push({
          args: args,
          blk: blk
        })
      end

      def callbacks(key)
        @callbacks ||= {}
        @callbacks[key] ||= []
      end

      def register_callbacks(key)
        callbacks(key).each do |cb|
          @stimulus_reflex.send("#{key}_reflex", *cb[:args], &cb[:blk])
        end
      end

      def before_reflex(*args, &blk)
        queue_callback(:before, args, blk)
      end

      def after_reflex(*args, &blk)
        queue_callback(:after, args, blk)
      end

      def around_reflex(*args, &blk)
        queue_callback(:around, args, blk)
      end

      def wire_up_callbacks
        register_callbacks(:before)
        register_callbacks(:after)
        register_callbacks(:around)
      end
    end

    def self.stimulus_controller
      name.chomp("Component").underscore.dasherize.gsub("/", "--")
    end

    def stimulus_reflex?
      helpers.controller.instance_variable_get(:@stimulus_reflex)
    end

    def component_controller(opts_or_tag = :div, opts = {}, &blk)
      initialize_component

      tag = :div
      options = if opts_or_tag.is_a? Hash
        opts_or_tag
      else
        tag = opts_or_tag
        opts
      end

      options[:data] = {
        controller: self.class.stimulus_controller,
        key: key,
        **(options[:data] || {})
      }
      content_tag tag, capture(&blk), options
    end

    def can_render_to_string?
      omitted_from_state.empty?
    end

    # We can't truly initialize the component without the view_context,
    # which isn't available in the `initialize` method. We require the 
    # developer to wrap components in `component_controller`, so this is where
    # we truly initialize the component.
    # This method is overridden in reflex.rb when the component is re-rendered. The 
    # override simply sets @key to element.dataset[:key]
    # We don't want it to initialize the state again, and since we're rendering the component
    # outside of the view, we need to skip the initialize_key method as well
    def initialize_component
      initialize_key
      initialize_state
    end

    # Note to self:
    # This has to be in the Component class because there are situations
    # where the controller is the one rendering the component
    # so we can't rely on the component created by the reflex
    def initialize_state
      return if state_initialized?
      adapter = ViewComponentReflex::Engine.state_adapter
      # initialize session state
      if !stimulus_reflex? || adapter.state(request, @key).empty?

        new_state = create_safe_state

        adapter.wrap_write_async do
          adapter.store_state(request, @key, new_state)
          adapter.store_state(request, "#{@key}_initial", new_state)
        end
      elsif !@initialized_state
        initial_state = adapter.state(request, "#{@key}_initial")

        parameters_changed = []
        adapter.state(request, @key).each do |k, v|
          instance_value = instance_variable_get(k)
          if permit_parameter?(initial_state[k], instance_value)
            parameters_changed << k
            adapter.wrap_write_async do
              adapter.set_state(request, controller, "#{@key}_initial", {k => instance_value})
              adapter.set_state(request, controller, @key, {k => instance_value})
            end
          else
            instance_variable_set(k, v)
          end
        end
        after_state_initialized(parameters_changed)
      end
      @state_initialized = true
    end

    def state_initialized?
      @state_initialized
    end

    def initialize_key
      # we want the erb file that renders the component. `caller` gives the file name,
      # and line number, which should be unique. We hash it to make it a nice number
      erb_file = caller.select { |p| p.match? /.\.html\.(haml|erb|slim)/ }[1]
      key = if erb_file
        Digest::SHA2.hexdigest(erb_file.split(":in")[0])
      else
        ""
      end
      key += collection_key.to_s if collection_key
      @key = key
    end

    # Helper to use to create the proper reflex data attributes for an element
    def reflex_data_attributes(reflex)
      action, method = reflex.to_s.split("->")
      if method.nil?
        method = action
        action = "click"
      end

      {
        reflex: "#{action}->#{self.class.name}##{method}",
        key: key
      }
    end

    def reflex_tag(reflex, name, content_or_options_with_block = {}, options = {}, escape = true, &block)
      if content_or_options_with_block.is_a?(Hash)
        merge_data_attributes(content_or_options_with_block, reflex_data_attributes(reflex))
      else
        merge_data_attributes(options, reflex_data_attributes(reflex))
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

    def after_state_initialized(parameters_changed)
      # called after state component has been hydrated
    end

    # def receive_params(old_state, params)
    #   # no op
    # end

    def safe_instance_variables
      instance_variables - unsafe_instance_variables - omitted_from_state
    end

    private

    def unsafe_instance_variables
      [
        :@view_context, :@lookup_context, :@view_renderer, :@view_flow,
        :@virtual_path, :@variant, :@current_template, :@output_buffer, :@key,
        :@helpers, :@controller, :@request, :@tag_builder, :@state_initialized
      ]
    end

    def create_safe_state
      new_state = {}

      # this will almost certainly break
      safe_instance_variables.each do |k|
        new_state[k] = instance_variable_get(k)
      end

      new_state
    end

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
