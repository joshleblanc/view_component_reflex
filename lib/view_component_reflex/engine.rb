module ViewComponentReflex
  class Engine < ::Rails::Engine
    config.to_prepare do
      class StimulusReflex::Channel < ActionCable::Channel::Base
        def render_page_and_broadcast_morph(reflex, selectors, data = {})
          html = render_page(reflex)
          if reflex.respond_to? :stimulus_controller
            selectors = ["[data-controller=\"#{reflex.stimulus_controller}\"]"]
          end
          broadcast_morphs selectors, data, html if html.present?
        end
      end

    end
  end
end
