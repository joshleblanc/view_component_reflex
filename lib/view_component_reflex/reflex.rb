module ViewComponentReflex
  class Reflex < StimulusReflex::Reflex

    class << self
      attr_accessor :component_class
    end

    def refresh!(primary_selector = nil, *rest)
      save_state

      if primary_selector.nil? && !component.can_render_to_string?
        primary_selector = selector
      end
      if primary_selector
        prevent_refresh!

        controller.process(params[:action])
        document = Nokogiri::HTML(controller.response.body)
        [primary_selector, *rest].each do |s|
          html = document.css(s)
          if html.present?
            CableReady::Channels.instance[stream].morph(
              selector: s,
              html: html.inner_html,
              children_only: true,
              permanent_attribute_name: "data-reflex-permanent",
              stimulus_reflex: stimulus_reflex_data
            )
          end
        end
      else
        refresh_component!
      end
      cable_ready.broadcast
    end

    def stream
      @stream ||= stream_name
    end

    def stream_to(channel)
      @stream = channel
    end

    def refresh_component!
      component.tap do |k|
        k.define_singleton_method(:key) do
          element.dataset[:key]
        end
      end
      document = Nokogiri::HTML(component.render_in(controller.view_context))
      CableReady::Channels.instance[stream].morph(
        selector: selector,
        children_only: true,
        html: document.css(selector).inner_html,
        permanent_attribute_name: "data-reflex-permanent",
        stimulus_reflex: stimulus_reflex_data
      )
    end

    def stimulus_reflex_data
      {
        reflex_id: reflex_id,
        xpath: xpath,
        target: target,
        c_xpath: c_xpath,
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

    # this is copied out of stimulus_reflex/reflex.rb and modified
    def morph(selectors, html = "")
      case selectors
      when :nothing
        @broadcaster = StimulusReflex::NothingBroadcaster.new(self)
      else
        @broadcaster = StimulusReflex::SelectorBroadcaster.new(self) unless broadcaster.selector?
        broadcaster.morphs << [selectors, html]
      end
    end

    def method_missing(name, *args)
      morph :nothing
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

    private

    def component_class
      self.class.component_class
    end

    def stimulus_controller
      component_class.stimulus_controller
    end

    def stimulate(target, data)
      data_to_receive = {}

      stimulus_reflex_data.each do |k, v|
        data_to_receive[k.to_s.camelize(:lower)] = v
      end

      data_to_receive["dataset"] = data.each_with_object({}) do |(k, v), o|
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
      component.safe_instance_variables.each do |k|
        new_state[k] = component.instance_variable_get(k)
      end
      set_state(new_state)
    end
  end
end
