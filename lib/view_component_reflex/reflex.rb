module ViewComponentReflex
  class Reflex < StimulusReflex::Reflex
    include CableReady::Broadcaster

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

        controller.process(url_params[:action])
        document = Nokogiri::HTML(controller.response.body)
        [primary_selector, *rest].each do |s|
          html = document.css(s)
          if html.present?
            cable_ready[channel.stream_name].morph(
              selector: s,
              html: html.inner_html,
              children_only: true,
              permanent_attribute_name: "data-reflex-permanent",
              stimulus_reflex: {
                reflex_id: reflex_id,
                url: url,
                morph: :page,
                reflex_controller: stimulus_controller,
                attrs: {key: element.dataset[:key]}
              }
            )
          end
        end
      else
        refresh_component!
      end
      cable_ready.broadcast
    end

    def refresh_component!
      component.tap do |k|
        k.define_singleton_method(:key) do
          element.dataset[:key]
        end
      end
      document = Nokogiri::HTML(component.render_in(controller.view_context))
      cable_ready[channel.stream_name].morph(
        selector: selector,
        children_only: true,
        html: document.css(selector).inner_html,
        permanent_attribute_name: "data-reflex-permanent",
        stimulus_reflex: {
          reflex_id: reflex_id,
          url: url,
          morph: :page,
          reflex_controller: stimulus_controller,
          attrs: {key: element.dataset[:key]}
        }
      )
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
      dataset = {}
      data.each do |k, v|
        dataset["data-#{k}"] = v.to_s
      end
      channel.receive({
        "target" => target,
        "attrs" => element.attributes.to_h.symbolize_keys,
        "dataset" => dataset
      })
    end

    def component
      return @component if @component
      @component = component_class.allocate
      reflex = self
      exposed_methods = [:params, :request, :connection, :element, :refresh!, :refresh_all!, :stimulus_controller, :session, :prevent_refresh!, :selector, :stimulate]
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
      component.safe_instance_variables.each do |k|
        new_state[k] = component.instance_variable_get(k)
      end
      set_state(new_state)
    end
  end
end
