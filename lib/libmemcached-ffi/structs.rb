
module LibMemcachedFFI
  module Lib

    class MemcachedStState < FFI::Struct
      layout(
        :is_purging, :bool,
        :is_processing_input, :bool,
        :is_time_for_rebuild, :bool,
        :is_parsing, :bool
      )
    end

    class MemcachedStFlags < FFI::Struct
      layout(
        :auto_eject_hosts, :bool,
        :binary_protocol, :bool,
        :buffer_requests, :bool,
        :hash_with_namespace, :bool,
        :no_block, :bool,
        :reply, :bool,
        :randomize_replica_read, :bool,
        :support_cas, :bool,
        :tcp_nodelay, :bool,
        :use_sort_hosts, :bool,
        :use_udp, :bool,
        :verify_key, :bool,
        :tcp_keepalive, :bool,
        :is_aes, :bool,
        :is_fetching_version, :bool,
        :not_used, :bool
      )
    end

    class MemcachedStServerInfo < FFI::Struct
      layout(
        :version, :uint
      )
    end

    class MemcachedStKetama < FFI::Struct
      layout(
        :weighted_, :bool,
        :continuum_count, :uint32,
        :continuum_points_counter, :uint32,
        :next_distribution_rebuild, :time_t,
        :continuum, :pointer
      )
    end

    callback(:hashkit_hash_fn, [ :string, :uint, :pointer ], :uint32)

    class MemcachedStConfigure < FFI::Struct
      layout(
        :initial_pool_size, :uint32,
        :max_pool_size, :uint32,
        :version, :int32,
        :filename, :pointer
      )
    end

    class MemcachedStOptions < FFI::Struct
      layout(
        :is_allocated, :bool
      )
    end

    class HashkitFunctionSt < FFI::Struct
      layout(
             :function, :hashkit_hash_fn,
             :context, :pointer
      )
    end

    class HashkitStFlags < FFI::Struct
      layout(
             :is_base_same_distributed, :bool
      )
    end

    class HashkitStOptions < FFI::Struct
      layout(
             :is_allocated, :bool
      )
    end

    class HashkitSt < FFI::Struct
      layout(
        :_key, :pointer,
        :base_hash, HashkitFunctionSt,
        :distribution_hash, HashkitFunctionSt,
        :flags, HashkitStFlags,
        :options, HashkitStOptions
       )
    end


    class MemcachedStringStOptions < FFI::Struct
      layout(
             :is_allocated, :bool,
             :is_initialized, :bool
      )
    end

    class MemcachedStringSt < FFI::Struct
      layout(
             :end, :pointer,
             :string, :pointer,
             :current_size, :uint,
             :root, :pointer,
             :options, MemcachedStringStOptions
      )
      def end=(str)
        @end = FFI::MemoryPointer.from_string(str)
        self[:end] = @end
      end
      def end
        @end.get_string(0)
      end
      def string=(str)
        @string = FFI::MemoryPointer.from_string(str)
        self[:string] = @string
      end
      def string
        @string.get_string(0)
      end

    end

    class MemcachedResultStOptions < FFI::Struct
      layout(
             :is_allocated, :bool,
             :is_initialized, :bool
      )
    end

    class MemcachedResultSt < FFI::Struct
      layout(
             :item_flags, :uint32,
             :item_expiration, :time_t,
             :key_length, :uint,
             :item_cas, :uint64,
             :root, :pointer,
             :value, MemcachedStringSt,
             :numeric_value, :uint64,
             :count, :uint64,
             :item_key, :char,
             :options, MemcachedResultStOptions
      )
    end

    callback(:memcached_free_fn, [ :pointer, :pointer, :pointer ], :void)
    callback(:memcached_malloc_fn, [ :pointer, :uint, :pointer ], :pointer)
    callback(:memcached_realloc_fn, [ :pointer, :pointer, :uint, :pointer ], :pointer)
    callback(:memcached_calloc_fn, [ :pointer, :uint, :uint, :pointer ], :pointer)

    class MemcachedAllocatorT < FFI::Struct
      layout(
             :calloc, :memcached_calloc_fn,
             :free, :memcached_free_fn,
             :malloc, :memcached_malloc_fn,
             :realloc, :memcached_realloc_fn,
             :context, :pointer
      )
    end

    callback(:memcached_clone_fn, [ :pointer, :pointer ], MemcachedReturnT)
    callback(:memcached_cleanup_fn, [ :pointer ], MemcachedReturnT)
    callback(:memcached_trigger_key_fn, [ :pointer, :string, :uint, :pointer ], MemcachedReturnT)
    callback(:memcached_trigger_delete_key_fn, [ :pointer, :string, :uint ], MemcachedReturnT)
    callback(:memcached_dump_fn, [ :pointer, :string, :uint, :pointer ], MemcachedReturnT)

    class MemcachedSaslSt < FFI::Struct
      layout(
        :callbacks, :pointer,
        :is_allocated, :bool
      )
    end

    class MemcachedServerStOptions < FFI::Struct
      layout(
        :is_allocated, :bool,
        :is_initialized, :bool,
        :is_shutting_down, :bool,
        :is_dead, :bool
        )
    end

    class MemcachedServerStIoWaitCount < FFI::Struct
      layout(
        :read, :uint32,
        :write, :uint32,
        :timeouts, :uint32,
        :_bytes_read, :uint
        )
    end

    class MemcachedErrorT < FFI::Struct
      layout(
        :root, :pointer,
        :query_id, :uint64,
        :next, :pointer,
        :rc, MemcachedReturnT,
        :local_errno, :int,
        :size, :uint,
        :message, [:char, 2048]
        )
    end

    class MemcachedServerSt < FFI::Struct
      layout(
        :number_of_hosts, :uint32,
        :cursor_active, :uint32,
        :port, :in_port_t, # in_port_t -> short -> int16_t
        :io_bytes_sent, :uint32,
        :request_id, :uint32,
        :server_failure_counter, :uint32,
        :server_failure_counter_query_id, :uint64,
        :weight, :uint32,
        :version, :uint32,
        :state, MemcachedServerStateT,
        :major_version, :u_int8_t, #:u_int8_t,
        :micro_version, :u_int8_t, #:u_int8_t,
        :minor_version, :u_int8_t, #:u_int8_t,
        :type, MemcachedConnectionT,
        :next_retry, :time_t,
        :root, :pointer,        # MemcachedSt
        :limit_maxbytes, :uint64,
        :error_messages, :pointer, # MemcachedErrorT
        :hostname, [:uchar, 1025],
        :options, MemcachedServerStOptions,
        :io_wait_count, MemcachedServerStIoWaitCount,
        )
    end

    class MemcachedSt < FFI::Struct
      layout(
        :distribution, MemcachedServerDistributionT,
        :hashkit, HashkitSt,
        :number_of_hosts, :uint32,
        :servers, :pointer, # MemcachedServerSt
        :last_disconnected_server, :pointer,
        :snd_timeout, :int32,
        :rcv_timeout, :int32,
        :server_failure_limit, :uint32,
        :io_msg_watermark, :uint32,
        :io_bytes_watermark, :uint32,
        :io_key_prefetch, :uint32,
        :tcp_keepidle, :uint32,
        :poll_timeout, :int32,
        :connect_timeout, :int32,
        :retry_timeout, :int32,
        :dead_timeout, :int32,
        :send_size, :int,
        :recv_size, :int,
        :user_data, :pointer,
        :query_id, :uint64,
        :number_of_replicas, :uint32,
        :result, MemcachedResultSt,
        :virtual_bucket, :pointer,
        :allocators, MemcachedAllocatorT,
        :on_clone, :memcached_clone_fn,
        :on_cleanup, :memcached_cleanup_fn,
        :get_key_failure, :memcached_trigger_key_fn,
        :delete_trigger, :memcached_trigger_delete_key_fn,
        :callbacks, :pointer,
        :sasl, MemcachedSaslSt,
        :error_messages, :pointer, # MemcachedErrorT
        :_namespace, :pointer,
        :state, MemcachedStState,
        :flags, MemcachedStFlags,
        :server_info, MemcachedStServerInfo,
        :ketama, MemcachedStKetama,
        :configure, MemcachedStConfigure,
        :options, MemcachedStOptions
       )
    end

  end # Lib
end # LibMemcachedFFI
