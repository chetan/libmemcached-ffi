
module LibMemcachedFFI
  class Cache

    include FFI

    DIRECT_VALUE_BEHAVIORS = [:retry_timeout, :connect_timeout, :rcv_timeout,
                              :snd_timeout, :socket_recv_size, :poll_timeout,
                              :socket_send_size, :server_failure_limit]

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
      :snd_timeout           => nil,
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

    # Create a new Cache client
    #
    # @param [Array<String>] servers      List of servers to connect to
    # @param [Hash] opts
    def initialize(servers, opts={})
      # Merge option defaults and discard meaningless keys
      @options = DEFAULTS.merge(opts)
      @options.delete_if { |k,v| not DEFAULTS.keys.include? k }
      @default_ttl = options[:default_ttl]

      # Force :buffer_requests to use :no_block
      # XXX Deleting the :no_block key should also work, but libmemcached doesn't seem to set it
      # consistently
      @options[:no_block] = true if @options[:buffer_requests]

      servers = [ servers ] if not servers.kind_of? Array
      config = []
      servers.each{ |s| config << "--SERVER=#{s}" }

      config = config.join(" ")
      @cache = Lib.memcached(config, config.length)

      set_behaviors()
    end

    def set(key, val, ttl=@default_ttl, marshal=true, flags=FLAGS)
      val = marshal ? Marshal.dump(val) : val
      ret = Lib.memcached_set(@cache, key, key.length, val, val.length, ttl, flags)
    end
    alias_method :put, :set

    # Retrieve data for given key
    #
    # @param [String] key
    # @param [Boolean] unmarshal          Whether or not to unmarshall data (default: true)
    #
    # @return [Object] data
    def get(key, unmarshal=true)
      string_length = MemoryPointer.new(:size_t)
      flags = MemoryPointer.new(:uint32)
      error = MemoryPointer.new(:pointer)
      ret = Lib.memcached_get(@cache, key, key.length, string_length, flags, error)

      if Lib::MemcachedReturnT[error.read_int] != :MEMCACHED_SUCCESS then
        # TODO
      end

      return (unmarshal ? Marshal.load(ret) : ret) # TODO flags
    end

    # Retrieve data for the given keys
    #
    # @param [Array<String>] keys
    # @param [Boolean] unmarshal          Whether or not to unmarshall data (default: true)
    #
    # @return [Hash] key/value pairs
    def mget(keys, unmarshal=true)
      keys = [ keys ] if not keys.kind_of? Array

      keys_ptr = FFIUtil.string_ptrs(keys)
      keylen_ptr = FFIUtil.ptrs_of_type(:size_t, keys.map{ |k| k.size })

      ret = Lib.memcached_mget(@cache, keys_ptr, keylen_ptr, keys.size)
      if ret != :MEMCACHED_SUCCESS then
        # TODO
        # Lib.memcached_last_error_message(@mc)
      end

      results = {}
      res_ptr = MemoryPointer.new(Lib::MemcachedResultSt)
      error_ptr = MemoryPointer.new(:pointer)
      1.upto(keys.size) do |i|
        Lib.memcached_fetch_result(@cache, res_ptr, error_ptr)
        if Lib::MemcachedReturnT[error_ptr.read_int] != :MEMCACHED_SUCCESS then
          # TODO
        end

        k = Lib.memcached_result_key_value(res_ptr)
        v = Lib.memcached_result_value(res_ptr)
        results[k] = (unmarshal ? Marshal.load(v) : v)
      end

      return results

    ensure
      Lib.memcached_result_free(res_ptr) if res_ptr
    end

    # Increment a key's value
    #
    # @param [String] key
    # @param [Fixnum] offset    Amount to increment by (default: 1)
    #
    # @return [Fixnum] new value of key
    #
    # Note that the key must be initialized to an unmarshalled integer first,
    # via #set, #add, or #replace with *marshal* set to *false*.
    def increment(key, offset=1)
      value_ptr = MemoryPointer.new(:uint64)
      ret = Lib.memcached_increment(@cache, key, key.length, offset, value_ptr)
      return value_ptr.read_int
    end
    alias_method :incr, :increment

    # Decrement a key's value
    #
    # @param [String] key
    # @param [Fixnum] offset    Amount to decrement by (default: 1)
    #
    # @return [Fixnum] new value of key
    #
    # Note that the key must be initialized to an unmarshalled integer first,
    # via #set, #add, or #replace with *marshal* set to *false*.
    def decrement(key, offset=1)
      value_ptr = MemoryPointer.new(:uint64)
      ret = Lib.memcached_decrement(@cache, key, key.length, offset, value_ptr)
      return value_ptr.read_int
    end
    alias_method :decr, :decrement



    private

    # Process the @options hash and set behaviors accordingly
    def set_behaviors
      # configure behaviors/options
      @options.each do |opt, val|
        next if opt == :hash
        set_behavior(opt, val)
      end

      # BUG Hash must be last due to the weird Libmemcached multi-behaviors
      # (as per the memcached gem)
      set_behavior(:hash, @options[:hash])
    end

    # Set the given behavior on the cache pointer
    #
    # @param [Symbol] opt     option name
    # @param [Object] val     option value
    def set_behavior(opt, val)

      flag = "MEMCACHED_BEHAVIOR_#{opt.upcase}".to_sym
      if not Lib::MemcachedBehaviorT.symbols.include? flag then
        return # not a valid behavior
      end

      if opt == :hash then
        key = "MEMCACHED_HASH_#{val.to_s.upcase}".to_sym
        val = Lib::MemcachedHashT[key]
        raise(ArgumentError, "invalid hash type: #{val}") if val.nil?

      elsif opt == :distribution then
        key = "MEMCACHED_DISTRIBUTION_#{val.to_s.upcase}".to_sym
        val = Lib::MemcachedServerDistributionT[key]
        raise(ArgumentError, "invalid distribution type: #{val}") if val.nil?

      elsif DIRECT_VALUE_BEHAVIORS.include? opt then
        return if val.nil? # don't need to do anything, probably

      else
        # TODO raise?
      end

      if val == false then
        val = 0
      elsif val == true then
        val = 1
      end

      Lib.memcached_behavior_set(@cache, Lib::MemcachedBehaviorT[flag], val)
    end

  end # Cache
end # LibMemcachedFFI
