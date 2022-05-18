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

        data = {
          "#{key}_state" => Verifier.generate(state(key)),
          "#{key}_initial" => Verifier.generate(state("#{key}_initial")),
        }

        options[:data] = {
          controller: self.class.stimulus_controller,
          key: key,
          **(options[:data] || {})
        }

        content_tag tag, options do
          concat(content_tag(:span, nil, { data: data, style: "display: none;" }))
          concat(capture(&blk))
        end
      end

      def reflex_data_attributes(reflex)
        super(reflex).tap do |attr|
          attr["reflex-dataset"] = "*"
        end
      end
    end
  end
end
