module ViewComponentReflex
  class Engine < ::Rails::Engine
    class << self
      mattr_accessor :state_adapter

      self.state_adapter = StateAdapter::Memory
    end

    def self.configure
      yield self if block_given?
    end
  end
end
