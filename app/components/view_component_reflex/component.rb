module ViewComponentReflex
  class Component < ViewComponent::Base
    class << self
      def init_stimulus_reflex
        factory = ViewComponentReflex::ReflexFactory.new(self)
        @stimulus_reflex ||= factory.reflex
        wire_up_callbacks if factory.new?
      end

      def reflex_base_class(new_base_class = nil)
        if new_base_class.nil?
          @reflex_base_class ||= ViewComponentReflex::Reflex
        else
          if new_base_class <= ViewComponentReflex::Reflex
            @reflex_base_class = new_base_class
          else
            raise StandardError.new("The reflex base class must inherit from ViewComponentReflex::Reflex")
          end
        end
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
      name.chomp("Component").underscore.dasherize
    end

    def stimulus_reflex?
      helpers.controller.instance_variable_get(:@stimulus_reflex)
    end

    def component_controller(opts_or_tag = :div, opts = {}, &blk)
      init_key

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

    # key is required if you're using state
    # We can't initialize the session state in the initial method
    # because it doesn't have a view_context yet
    # This is the next best place to do it
    def init_key
      # we want the erb file that renders the component. `caller` gives the file name,
      # and line number, which should be unique. We hash it to make it a nice number
      erb_file = caller.select { |p| p.match? /.\.html\.(haml|erb|slim)/ }[1]
      key = if erb_file
        Digest::SHA2.hexdigest(erb_file)
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

    def key
      # initialize session state
      if !stimulus_reflex? || ViewComponentReflex::Engine.state_adapter.state(request, @key).empty?

        new_state = create_safe_state

        ViewComponentReflex::Engine.state_adapter.store_state(request, @key, new_state)
        ViewComponentReflex::Engine.state_adapter.store_state(request, "#{@key}_initial", new_state)
      else
        initial_state = ViewComponentReflex::Engine.state_adapter.state(request, "#{@key}_initial")
        ViewComponentReflex::Engine.state_adapter.state(request, @key).each do |k, v|
          instance_value = instance_variable_get(k)
          if permit_parameter?(initial_state[k], instance_value)
            ViewComponentReflex::Engine.state_adapter.set_state(request, controller, "#{@key}_initial", {k => instance_value})
            ViewComponentReflex::Engine.state_adapter.set_state(request, controller, @key, {k => instance_value})
          else
            instance_variable_set(k, v)
          end
        end
      end
      @key
    end

    def safe_instance_variables
      instance_variables - unsafe_instance_variables
    end

    private

    def unsafe_instance_variables
      [
        :@view_context, :@lookup_context, :@view_renderer, :@view_flow,
        :@virtual_path, :@variant, :@current_template, :@output_buffer, :@key,
        :@helpers, :@controller, :@request, :@tag_builder
      ]
    end

    def create_safe_state
      new_state = {}

      # this will almost certainly break
      safe_instance_variables.each do |k|
        new_state[k] = instance_variable_get(k) unless omitted_from_state.include?(k)
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
