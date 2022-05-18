# A redis based adapter for component_reflex
#
# ViewComponentReflex::Engine.configure do |config|
#   config.state_adapter = ViewComponentReflex::StateAdapter::Redis.new(
#       redis_opts: {
#           url: "redis://localhost:6379/1", driver: :hiredis
#       },
#       ttl: 3600)
# end

module ViewComponentReflex
  module StateAdapter
    class Redis < Base
      attr_reader :ttl
      attr_accessor :client

      def initialize(redis_opts:, ttl: 3600)
        @client = ::Redis.new(redis_opts)
        @ttl = ttl
      end

      def state(request, key)
        cache_key = get_key(request, key)
        value = client.hgetall(cache_key)

        return {} if value.nil?

        value.map do |k, v|
          [k, Marshal.load(v)]
        end.to_h
      end

      def set_state(request, _, key, new_state)
        cache_key = get_key(request, key)
        save_to_redis(cache_key, new_state)
      end

      def store_state(request, key, new_state = {})
        cache_key = get_key(request, key)
        optimized_store_to_redis(cache_key, new_state, request)
      end

      def wrap_write_async
        client.pipelined  do |pipeline|
          original_client = client
          @client = pipeline
          yield
          @client = original_client
        end
      end

      def extend_component(_)
        #stub
      end

      def extend_reflex(_)
        #stub
      end

      private

      # Reduce number of calls coming from #store_state to save Redis
      # when it's first rendered
      def optimized_store_to_redis(cache_key, new_state, request)
        request.env["CACHE_REDIS_REFLEX"] ||= []
        return if request.env["CACHE_REDIS_REFLEX"].include?(cache_key)
        request.env["CACHE_REDIS_REFLEX"].push(cache_key)

        save_to_redis(cache_key, new_state)
      end

      def save_to_redis(cache_key, new_state)
        new_state_json = new_state.map do |k, v|
          [k, Marshal.dump(v)]
        end

        client.hmset(cache_key, new_state_json.flatten)
        client.expire(cache_key, ttl)
      end

      def get_key(request, key)
        id = Redis.extract_id(request)
        "#{id}_#{key}_session_reflex_redis"
      end
    end
  end
end
