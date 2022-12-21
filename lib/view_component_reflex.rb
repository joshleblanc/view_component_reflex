require "stimulus_reflex"
require "active_support/dependencies/autoload"
require "view_component_reflex/state_adapter/base"
require "view_component_reflex/state_adapter/session"
require "view_component_reflex/state_adapter/memory"
require "view_component_reflex/state_adapter/dom"
require "view_component_reflex/state_adapter/redis"
require "view_component_reflex/dom/verifier"
require "view_component_reflex/dom/reflex"
require "view_component_reflex/dom/component"



module ViewComponentReflex
  extend ActiveSupport::Autoload 

  autoload :ReflexFactory
  autoload :Reflex
  autoload :Component
end

require "view_component_reflex/engine"
