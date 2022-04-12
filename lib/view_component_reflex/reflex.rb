module ViewComponentReflex
  class Reflex < StimulusReflex::Reflex
    class << self
      attr_accessor :component_class
    end

    # pretty sure I can't memoize this because we need
    # to re-render every time
    def controller_document
      controller.process(params[:action])
      Nokogiri::HTML(controller.response.body)
    end

    def refresh!(primary_selector = nil, *rest)
      save_state

      if primary_selector.nil? && !component.can_render_to_string?
        primary_selector = selector
      end
      if primary_selector
        prevent_refresh!
        
        document = controller_document
        [primary_selector, *rest].each do |s|
          html = document.css(s)
          if html.present?
            CableReady::Channels.instance[stream].morph(
              selector: s,
              html: html.inner_html,
              children_only: true,
              permanent_attribute_name: "data-reflex-permanent",
              reflex_id: reflex_id
            )
          end
        end
      else
        refresh_component!
      end
      CableReady::Channels.instance[stream].broadcast
    end

    def stream
      @stream ||= stream_name
    end

    def stream_to(channel)
      @stream = channel
    end

    def inject_key_into_component
      component.tap do |k|
        k.define_singleton_method(:initialize_component) do
          @key = element.dataset[:key]
        end
      end
    end

    def component_document
      Nokogiri::HTML(component.render_in(controller.view_context))
    end

    def refresh_component!
      CableReady::Channels.instance[stream].morph(
        selector: selector,
        children_only: true,
        html: component_document.css(selector).to_html,
        permanent_attribute_name: "data-reflex-permanent",
        reflex_id: reflex_id
      )
    end

    def default_morph
      save_state
      html = if component.can_render_to_string?
        component_document.css(selector).to_html
      else
        controller_document.css(selector).to_html
      end
      morph selector, html
    end

    def stimulus_reflex_data
      {
        reflex_id: reflex_id,
        xpath_controller: xpath_controller,
        xpath_element: xpath_element,
        target: target,
        reflex_controller: reflex_controller,
        url: url,
        morph: :page,
        attrs: {
          key: element.dataset[:key]
        }
      }
    end

    def target
      "#{component_class}##{method_name}"
    end

    def refresh_all!
      refresh!("body")
    end

    def selector
      "[data-controller~=\"#{stimulus_controller}\"][data-key=\"#{element.dataset[:key]}\"]"
    end

    # SR's delegate_call_to_reflex in channel.rb
    # uses method to gather the method parameters, but since we're abusing
    # method_missing here, that'll always fail
    def method(name)
      component.method(name.to_sym)
    end

    def respond_to_missing?(name, _ = false)
      !!name.to_proc
    end

    def method_missing(name, *args, &blk)
      super unless respond_to_missing?(name)

      state.each do |k, v|
        component.instance_variable_set(k, v)
      end

      component.send(name, *args, &blk)

      if @prevent_refresh
        morph :nothing
      else
        default_morph
      end
    end

    def prevent_refresh!
      @prevent_refresh = true
    end

    private

    def component_class
      self.class.component_class
    end

    def stimulus_controller
      component_class.stimulus_controller
    end

    def stimulate(target, data)
      data_to_receive = {
        "dataset" => {
          "datasetAll" => {},
          "dataset" => {}
        }
      }

      stimulus_reflex_data.each do |k, v|
        data_to_receive[k.to_s.camelize(:lower)] = v
      end

      data_to_receive["dataset"]["dataset"] = data.each_with_object({}) do |(k, v), o|
        o["data-#{k}"] = v
      end

      data_to_receive["attrs"] = element.attributes.to_h.symbolize_keys
      data_to_receive["target"] = target

      channel.receive data_to_receive
    end

    def component
      return @component if @component
      @component = component_class.allocate
      reflex = self
      exposed_methods = [
        :params,
        :request,
        :connection,
        :element,
        :refresh!,
        :refresh_all!,
        :stimulus_controller,
        :session,
        :prevent_refresh!,
        :selector,
        :stimulate,
        :stream_to
      ]
      exposed_methods.each do |meth|
        @component.define_singleton_method(meth) do |*a|
          reflex.send(meth, *a)
        end
      end

      @component.define_singleton_method(:reflex) do
        reflex
      end

      inject_key_into_component

      @component
    end

    def set_state(new_state = {})
      state_adapter.set_state(request, controller, key, new_state)
    end

    def key
      element.dataset[:key]
    end

    def state_adapter
      ViewComponentReflex::Engine.state_adapter
    end

    def state
      state_adapter.state(request, key)
    end

    def initial_state
      state_adapter.state(request, "#{key}_initial")
    end

    def save_state
      new_state = {}
      component.safe_instance_variables.each do |k|
        new_state[k] = component.instance_variable_get(k)
      end
      set_state(new_state)
    end
  end
end
