require "view_component_reflex/engine"
require 'stimulus_reflex'

module ViewComponentReflex
  # Your code goes here...
end

class StimulusReflex::Channel < ActionCable::Channel::Base
  def render_page_and_broadcast_morph(reflex, selectors, data = {})
    html = render_page(reflex)
    if reflex.respond_to? :stimulus_controller
      selectors = ["[data-controller=\"#{reflex.stimulus_controller}\"]"]
    end
    broadcast_morphs selectors, data, html if html.present?
  end
end
