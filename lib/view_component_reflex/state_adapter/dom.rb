##
# This adapter exists solely to allow switching to dom-based state storage, even
# though dom-based state storage doesn't abide by the same standards as the other adapters
#
# The dom-based state storage is handled by the Dom::Component and Dom::Reflex modules that are prepended
# to Component and Reflex in Engine, if the dom adapter is selected
#
# These modules override various methods to inject state into the dom, as well as encoding/decoding the state from the dom

module ViewComponentReflex
  module StateAdapter
    class Dom < Base
      # this exists as a stub
    end
  end
end
