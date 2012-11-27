
module LibMemcachedFFI
  class Cache

    include FFI

    DEFAULTS = {
      :hash                  => :fnv1_32,
      :no_block              => false,
      :noreply               => false,
      :distribution          => :consistent_ketama,
      :ketama_weighted       => true,
      :buffer_requests       => false,
      :cache_lookups         => true,
      :support_cas           => false,
      :tcp_nodelay           => false,
      :show_backtraces       => false,
      :retry_timeout         => 30,
      :timeout               => 0.25,
      :rcv_timeout           => nil,
      :poll_timeout          => nil,
      :connect_timeout       => 4,
      :prefix_key            => '',
      :prefix_delimiter      => '',
      :hash_with_prefix_key  => true,
      :default_ttl           => 604800,
      :default_weight        => 8,
      :sort_hosts            => false,
      :auto_eject_hosts      => true,
      :server_failure_limit  => 2,
      :verify_key            => true,
      :use_udp               => false,
      :binary_protocol       => false,
      :credentials           => nil,
      :experimental_features => false,
      :exception_retry_limit => 5,
      # :exceptions_to_retry => [
      #     Memcached::ServerIsMarkedDead,
      #     Memcached::ATimeoutOccurred,
      #     Memcached::ConnectionBindFailure,
      #     Memcached::ConnectionFailure,
      #     Memcached::Error,
      #     Memcached::Failure,
      #     Memcached::MemoryAllocationFailure,
      #     Memcached::ReadFailure,
      #     Memcached::ServerError,
      #     Memcached::SystemError,
      #     Memcached::UnknownReadFailure,
      #     Memcached::WriteFailure]
    }

    FLAGS = 0x0
    attr_accessor :default_ttl, :options

    def initialize(servers, opts={})
      # Merge option defaults and discard meaningless keys
      @options = DEFAULTS.merge(opts)
      @options.delete_if { |k,v| not DEFAULTS.keys.include? k }
      @default_ttl = options[:default_ttl]

      servers = [ servers ] if not servers.kind_of? Array
      config = []
      servers.each{ |s| config << "--SERVER=#{s}" }

      config = config.join(" ")
      @cache = Lib.memcached(config, config.length)
    end

    def set(key, val, ttl=@default_ttl, flags=FLAGS)
      ret = Lib.memcached_set(@cache, key, key.length, val, val.length, ttl, flags)
    end
    alias_method :put, :set

    # Retrieve data for given key
    #
    # @param [String] key
    #
    # @return [Array<String, Fixnum>] data, flags
    def get(key)
      string_length = MemoryPointer.new :size_t
      flags = MemoryPointer.new :uint32
      error = MemoryPointer.new :pointer
      ret = Lib.memcached_get(@cache, key, key.length, string_length, flags, error)

      if Lib::MemcachedReturnT[error.read_int] != :MEMCACHED_SUCCESS then
        # TODO
      end

      return ret, flags
    end

  end # Cache
end # LibMemcachedFFI
