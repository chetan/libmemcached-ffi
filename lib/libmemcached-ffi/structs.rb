
module LibMemcachedFFI
  module Lib

    class State < FFI::Struct
      layout(
        :is_purging, :bool,
        :is_processing_input, :bool,
        :is_time_for_rebuild, :bool,
        :is_parsing, :bool
      )
    end

    class Flags < FFI::Struct
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

    class HashkitFunctionST < FFI::Struct
    end

    class HashkitST < FFI::Struct
      layout(
      )
    end

    class MemcachedST < FFI::Struct
      layout(
        :state, State.ptr,
        :flags, Flags.ptr,
        :distribution, ServerDistributionT
      )
    end

  end # Lib
end # LibMemcachedFFI
