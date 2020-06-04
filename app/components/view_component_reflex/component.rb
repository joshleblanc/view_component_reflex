module ViewComponentReflex
  class Component < ViewComponent::Base
    class << self
      def reflex(name, &blk)
        stimulus_reflex.reflex(name, &blk)
      end

      def stimulus_reflex
        klass = self
        @stimulus_reflex ||= Object.const_set(name + "Reflex", Class.new(StimulusReflex::Reflex) {
          def state
            session[element.dataset[:key]] ||= {}
          end

          define_method :stimulus_controller do
            klass.name.chomp("Component").underscore.dasherize
          end

          define_singleton_method(:reflex) do |name, &blk|
            define_method(name) do |*args|
              instance_exec(*args, &blk)
            end
          end
        })
      end
    end

    def initialize_state(obj)
      @state = obj
    end

    def key
      @key ||= caller.find { |p| p.include? ".html.erb" }&.hash.to_s

      # initialize session state
      if session[@key].nil?
        session[@key] = {}
        (@state ||= {}).each do |key, v|
          session[@key][key] = v
        end
      end
      @key
    end

    def state
      session[key]
    end
  end
end
