module ViewComponentReflex
  class Component < ViewComponent::Base
    class_attribute :reflex_base_class, default: ViewComponentReflex::Reflex
    attr_reader :key

    class << self
      attr_reader :_state_adapter

      def init_stimulus_reflex
        factory = ViewComponentReflex::ReflexFactory.new(self)
        @stimulus_reflex ||= factory.reflex

        # Always wire up new callbacks in development
        if Rails.env.development?
          reset_callbacks
          wire_up_callbacks
        elsif factory.new? # only wire up callbacks in production if they haven't been wired up yet
          wire_up_callbacks
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
        ancestors.each do |klass|
          next unless klass.respond_to?(:callbacks)
          break if klass == ViewComponentReflex::Component
          klass.callbacks(key).each do |cb|
            @stimulus_reflex.send("#{key}_reflex", *cb[:args], &cb[:blk])
          end
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

      def reset_callbacks
        # SR uses :process as the underlying callback key
        @stimulus_reflex.reset_callbacks(:process)
      end

      def wire_up_callbacks
        register_callbacks(:before)
        register_callbacks(:after)
        register_callbacks(:around)
      end

      def state_adapter(what)
        if what.is_a?(Symbol) || what.is_a?(String)
          class_name = what.to_s.camelize
          @_state_adapter = StateAdapter.const_get class_name
        else
          @_state_adapter = what
        end
      end
    end

    def self.stimulus_controller
      name.chomp("Component").underscore.dasherize.gsub("/", "--")
    end

    def self.reflex_methods
      public_instance_methods - ViewComponentReflex::Component.instance_methods - [:call, :"_call_#{name.underscore}"]
    end

    def stimulus_reflex?
      helpers.controller.instance_variable_get(:@stimulus_reflex)
    end

    def before_render
      adapter.extend_component(self)
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

      adapter.extend_component(self)

      # newly mounted
      if !stimulus_reflex? || state(@key).empty?

        new_state = create_safe_state

        wrap_write_async do
          store_state(@key, new_state)
          store_state("#{@key}_initial", new_state)
        end

      # updating a mounted component
      else
        initial_state = state("#{@key}_initial")

        parameters_changed = []
        state(@key).each do |k, v|
          instance_value = instance_variable_get(k)
          if permit_parameter?(initial_state[k], instance_value)
            parameters_changed << k
            wrap_write_async do
              set_state("#{@key}_initial", { k => instance_value })
              set_state(@key, { k => instance_value })
            end
          else
            instance_variable_set(k, v)
          end
        end
        after_state_initialized(parameters_changed)
      end
      @state_initialized = true
    end

    def adapter
      self.class._state_adapter || ViewComponentReflex::Engine.state_adapter
    end

    def wrap_write_async(&blk)
      adapter.wrap_write_async(&blk)
    end

    def set_state(key, new_state)
      adapter.set_state(request, controller, key, new_state)
    end

    def state(key)
      adapter.state(request, key)
    end

    def store_state(key, new_state = {})
      adapter.store_state(request, key, new_state)
    end

    def state_initialized?
      @state_initialized
    end

    def initialize_key
      # we want the erb file that renders the component. `caller` gives the file name,
      # and line number, which should be unique. We hash it to make it a nice number
      key = caller.select { |p| p.match? /.\.html\.(haml|erb|slim)/ }.map do |erb_file|
        if erb_file
          erb_file.split(":in")[0]
        else
          ""
        end
      end.join("+")

      key += collection_key.to_s if collection_key
      @key = Digest::SHA2.hexdigest(key)
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
      instance_variables.reject { |ivar| ivar.start_with?("@__vc") } - unsafe_instance_variables - omitted_from_state
    end

    private

    def unsafe_instance_variables
      [
        :@view_context, :@lookup_context, :@view_renderer, :@view_flow,
        :@virtual_path, :@variant, :@current_template, :@output_buffer, :@key,
        :@helpers, :@controller, :@request, :@tag_builder, :@state_initialized,
        :@_content_evaluated, :@_render_in_block, :@__cached_content,
        :@original_view_context, :@compiler,
      ]
    end

    def content
      if cached_content && !@_render_in_block
        cached_content
      else
        super
      end
    end

    def cached_content
      @__cached_content__
    end

    def create_safe_state
      new_state = {}

      # this will almost certainly break
      safe_instance_variables.each do |k|
        new_state[k] = instance_variable_get(k)
      end

      new_state[:@__cached_content__] = content

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
