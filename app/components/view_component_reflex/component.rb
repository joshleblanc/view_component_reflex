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

    # key is required if you're using state
    # We can't initialize the session state in the initial method
    # because it doesn't have a view_context yet
    # This is the next best place to do it
    def key
      @key ||= caller.find { |p| p.include? ".html.erb" }&.hash.to_s

      # initialize session state
      if session[@key].nil?
        store_state(@key)
        store_state("#{@key}_initial")
      else
        reconcile_state
      end
      @key
    end

    def state
      session[key]
    end

    private

    # The passed state should always match the initial state of the component
    # if it doesn't, we need to reset the state to the passed value.
    #
    # This handles cases where your initialize_state param computes some value that changes
    # initialize_state({ transaction: @customer.transactions.first })
    # if you delete the first transaction, that ^ is no longer valid. We need to update the state.
    def reconcile_state
      session["#{@key}_initial"].each do |k, v|
        if @state[k] != v
          session[@key][k] = @state[k]
        end
      end
    end

    def store_state(a_key)
      session[a_key] = {}
      (@state ||= {}).each do |key, v|
        session[a_key][key] = v
      end
    end
  end
end
