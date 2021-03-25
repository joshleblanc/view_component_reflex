module ViewComponentReflex
  module Dom
    module Component

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

        data = {
          state: Verifier.generate(state(key)),
          initial_state: Verifier.generate(state("#{key}_initial")),
        }

        content_tag tag, options do
          concat(content_tag(:span, nil,{ data: data, style: "display: block;" }))
          concat(capture(&blk))
        end
      end

      def reflex_data_attributes(reflex)
        super(reflex).tap do |attr|
          attr["reflex-dataset"] = "combined"
        end
      end

      def set_state(key, new_state = {})
        @states ||= {}
        @states[key] ||= {}
        new_state.each do |k, v|
          @states[key][k] = v
        end
      end

      def wrap_write_async(&blk)
        blk.call
      end

      def state(key)
        @states[key]
      end

      def store_state(key, new_state = {})
        @states ||= {}
        @states[key] = new_state
      end
    end
  end
end
