
module LibMemcachedFFI
  module Lib

    def self.array_to_enum(arr)
      enum(arr.map{ |s| s.to_sym })
    end

    MemcachedBehaviorT = array_to_enum(%w{
      MEMCACHED_BEHAVIOR_NO_BLOCK
      MEMCACHED_BEHAVIOR_TCP_NODELAY
      MEMCACHED_BEHAVIOR_HASH
      MEMCACHED_BEHAVIOR_KETAMA
      MEMCACHED_BEHAVIOR_SOCKET_SEND_SIZE
      MEMCACHED_BEHAVIOR_SOCKET_RECV_SIZE
      MEMCACHED_BEHAVIOR_CACHE_LOOKUPS
      MEMCACHED_BEHAVIOR_SUPPORT_CAS
      MEMCACHED_BEHAVIOR_POLL_TIMEOUT
      MEMCACHED_BEHAVIOR_DISTRIBUTION
      MEMCACHED_BEHAVIOR_BUFFER_REQUESTS
      MEMCACHED_BEHAVIOR_USER_DATA
      MEMCACHED_BEHAVIOR_SORT_HOSTS
      MEMCACHED_BEHAVIOR_VERIFY_KEY
      MEMCACHED_BEHAVIOR_CONNECT_TIMEOUT
      MEMCACHED_BEHAVIOR_RETRY_TIMEOUT
      MEMCACHED_BEHAVIOR_KETAMA_WEIGHTED
      MEMCACHED_BEHAVIOR_KETAMA_HASH
      MEMCACHED_BEHAVIOR_BINARY_PROTOCOL
      MEMCACHED_BEHAVIOR_SND_TIMEOUT
      MEMCACHED_BEHAVIOR_RCV_TIMEOUT
      MEMCACHED_BEHAVIOR_SERVER_FAILURE_LIMIT
      MEMCACHED_BEHAVIOR_IO_MSG_WATERMARK
      MEMCACHED_BEHAVIOR_IO_BYTES_WATERMARK
      MEMCACHED_BEHAVIOR_IO_KEY_PREFETCH
      MEMCACHED_BEHAVIOR_HASH_WITH_PREFIX_KEY
      MEMCACHED_BEHAVIOR_NOREPLY
      MEMCACHED_BEHAVIOR_USE_UDP
      MEMCACHED_BEHAVIOR_AUTO_EJECT_HOSTS
      MEMCACHED_BEHAVIOR_NUMBER_OF_REPLICAS
      MEMCACHED_BEHAVIOR_RANDOMIZE_REPLICA_READ
      MEMCACHED_BEHAVIOR_CORK
      MEMCACHED_BEHAVIOR_TCP_KEEPALIVE
      MEMCACHED_BEHAVIOR_TCP_KEEPIDLE
      MEMCACHED_BEHAVIOR_LOAD_FROM_FILE
      MEMCACHED_BEHAVIOR_REMOVE_FAILED_SERVERS
      MEMCACHED_BEHAVIOR_DEAD_TIMEOUT
      MEMCACHED_BEHAVIOR_MAX
    })

    MemcachedCallbackT = enum(
      :MEMCACHED_CALLBACK_PREFIX_KEY, 0,
      :MEMCACHED_CALLBACK_USER_DATA, 1,
      :MEMCACHED_CALLBACK_CLEANUP_FUNCTION, 2,
      :MEMCACHED_CALLBACK_CLONE_FUNCTION, 3,
      :MEMCACHED_CALLBACK_GET_FAILURE, 7,
      :MEMCACHED_CALLBACK_DELETE_TRIGGER, 8,
      :MEMCACHED_CALLBACK_MAX,
      :MEMCACHED_CALLBACK_NAMESPACE
    )

    MemcachedConnectionT = array_to_enum(%w{
      MEMCACHED_CONNECTION_TCP
      MEMCACHED_CONNECTION_UDP
      MEMCACHED_CONNECTION_UNIX_SOCKET
    })

    MemcachedHashT = array_to_enum(%w{
      MEMCACHED_HASH_DEFAULT
      MEMCACHED_HASH_MD5
      MEMCACHED_HASH_CRC
      MEMCACHED_HASH_FNV1_64
      MEMCACHED_HASH_FNV1A_64
      MEMCACHED_HASH_FNV1_32
      MEMCACHED_HASH_FNV1A_32
      MEMCACHED_HASH_HSIEH
      MEMCACHED_HASH_MURMUR
      MEMCACHED_HASH_JENKINS
      MEMCACHED_HASH_CUSTOM
      MEMCACHED_HASH_MAX
    })

    MemcachedReturnT = array_to_enum(%w{
      MEMCACHED_SUCCESS
      MEMCACHED_FAILURE
      MEMCACHED_HOST_LOOKUP_FAILURE
      MEMCACHED_CONNECTION_FAILURE
      MEMCACHED_CONNECTION_BIND_FAILURE
      MEMCACHED_WRITE_FAILURE
      MEMCACHED_READ_FAILURE
      MEMCACHED_UNKNOWN_READ_FAILURE
      MEMCACHED_PROTOCOL_ERROR
      MEMCACHED_CLIENT_ERROR
      MEMCACHED_SERVER_ERROR
      MEMCACHED_ERROR
      MEMCACHED_DATA_EXISTS
      MEMCACHED_DATA_DOES_NOT_EXIST
      MEMCACHED_NOTSTORED
      MEMCACHED_STORED
      MEMCACHED_NOTFOUND
      MEMCACHED_MEMORY_ALLOCATION_FAILURE
      MEMCACHED_PARTIAL_READ
      MEMCACHED_SOME_ERRORS
      MEMCACHED_NO_SERVERS
      MEMCACHED_END
      MEMCACHED_DELETED
      MEMCACHED_VALUE
      MEMCACHED_STAT
      MEMCACHED_ITEM
      MEMCACHED_ERRNO
      MEMCACHED_FAIL_UNIX_SOCKET
      MEMCACHED_NOT_SUPPORTED
      MEMCACHED_NO_KEY_PROVIDED
      MEMCACHED_FETCH_NOTFINISHED
      MEMCACHED_TIMEOUT
      MEMCACHED_BUFFERED
      MEMCACHED_BAD_KEY_PROVIDED
      MEMCACHED_INVALID_HOST_PROTOCOL
      MEMCACHED_SERVER_MARKED_DEAD
      MEMCACHED_UNKNOWN_STAT_KEY
      MEMCACHED_E2BIG
      MEMCACHED_INVALID_ARGUMENTS
      MEMCACHED_KEY_TOO_BIG
      MEMCACHED_AUTH_PROBLEM
      MEMCACHED_AUTH_FAILURE
      MEMCACHED_AUTH_CONTINUE
      MEMCACHED_PARSE_ERROR
      MEMCACHED_PARSE_USER_ERROR
      MEMCACHED_DEPRECATED
      MEMCACHED_IN_PROGRESS
      MEMCACHED_SERVER_TEMPORARILY_DISABLED
      MEMCACHED_SERVER_MEMORY_ALLOCATION_FAILURE
      MEMCACHED_MAXIMUM_RETURN
      MEMCACHED_CONNECTION_SOCKET_CREATE_FAILURE
    })

    MemcachedServerDistributionT = array_to_enum(%w{
      MEMCACHED_DISTRIBUTION_MODULA
      MEMCACHED_DISTRIBUTION_CONSISTENT
      MEMCACHED_DISTRIBUTION_CONSISTENT_KETAMA
      MEMCACHED_DISTRIBUTION_RANDOM
      MEMCACHED_DISTRIBUTION_CONSISTENT_KETAMA_SPY
      MEMCACHED_DISTRIBUTION_CONSISTENT_WEIGHTED
      MEMCACHED_DISTRIBUTION_VIRTUAL_BUCKET
      MEMCACHED_DISTRIBUTION_CONSISTENT_MAX
    })

    MemcachedServerStateT = array_to_enum(%w{
      MEMCACHED_SERVER_STATE_NEW
      MEMCACHED_SERVER_STATE_ADDRINFO
      MEMCACHED_SERVER_STATE_IN_PROGRESS
      MEMCACHED_SERVER_STATE_CONNECTED
      MEMCACHED_SERVER_STATE_IN_TIMEOUT
      MEMCACHED_SERVER_STATE_DISABLED
    })

    MEMCACHED_NI_MAXHOST = 1025
    MEMCACHED_NI_MAXSERV = 32

  end # Lib
end # LibMemcachedFFI
