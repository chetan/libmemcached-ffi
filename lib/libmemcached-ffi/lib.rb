
require 'ffi'

module LibMemcachedFFI
  module Lib
    extend FFI::Library

    #
    # find lib

    paths = Array(ENV['LIBMEMCACHED_LIB'] || %w{
      /opt/local/lib/libmemcached.dylib
      /usr/local/lib/libmemcached.dylib
      /usr/local/lib/libmemcached.so
    })

    paths.each do |path|
      begin
        ffi_lib(paths.find { |path| File.exist?(path) })
      rescue LoadError => ex
        ffi_lib("memcached")
      end
    end

  end
end

require 'libmemcached-ffi/types'
require 'libmemcached-ffi/structs'

module LibMemcachedFFI
  module Lib

    # BASIC

    # const char * memcached_lib_version(void)
    attach_function :memcached_lib_version, [ ], :string

    # memcached_return_t memcached_version(memcached_st *ptr)
    attach_function :memcached_version, [ :pointer ], MemcachedReturnT

    # memcached_st *memcached(const char *string, size_t string_length)
    attach_function :memcached, [ :string, :size_t ], :pointer

    # void memcached_free(memcached_st *ptr)
    attach_function :memcached_free, [ :pointer ], :void

    # const char *memcached_last_error_message(memcached_st *)
    attach_function :memcached_last_error_message, [ :pointer ], :string

    # uint64_t memcached_behavior_get(memcached_st *ptr, memcached_behavior_t flag)
    attach_function :memcached_behavior_get, [ :pointer, MemcachedBehaviorT ], :uint64

    # memcached_return_t memcached_behavior_set(memcached_st *ptr, memcached_behavior_t flag, uint64_t data)
    attach_function :memcached_behavior_set, [ :pointer, MemcachedBehaviorT, :uint64 ], MemcachedReturnT


    # RETRIEVAL

    # char * memcached_get(memcached_st *ptr, const char *key, size_t key_length, size_t *value_length, uint32_t *flags, memcached_return_t *error)
    attach_function :memcached_get, [ :pointer, :string, :size_t, :pointer, :pointer, :pointer ], :string

    # memcached_return_t memcached_mget(memcached_st *ptr, const char * const *keys, const size_t *key_length, size_t number_of_keys)
    attach_function :memcached_mget, [ :pointer, :pointer, :pointer, :size_t ], MemcachedReturnT

    # memcached_result_st * memcached_fetch_result(memcached_st *ptr, memcached_result_st *result, memcached_return_t *error)
    attach_function :memcached_fetch_result, [ :pointer, :pointer, :pointer ], :pointer # MemcachedResultSt

    # const char * memcached_result_key_value(memcached_result_st *result)
    attach_function :memcached_result_key_value, [ :pointer ], :string

    # const char *memcached_result_value(memcached_result_st *ptr)
    attach_function :memcached_result_value, [ :pointer ], :string

    # uint32_t memcached_result_flags(const memcached_result_st *result)
    attach_function :memcached_result_flags, [ :pointer ], :uint32

    # void memcached_result_free(memcached_result_st *result)
    attach_function :memcached_result_free, [ :pointer ], :void


    # STORAGE

    # memcached_return_t memcached_set(memcached_st *ptr, const char *key, size_t key_length, const char *value, size_t value_length, time_t expiration, uint32_t flags)
    attach_function :memcached_set, [ :pointer, :string, :size_t, :string, :size_t, :time_t, :uint32 ], MemcachedReturnT

    # memcached_return_t memcached_add(memcached_st *ptr, const char *key, size_t key_length, const char *value, size_t value_length, time_t expiration, uint32_t flags)
    attach_function :memcached_add, [ :pointer, :string, :size_t, :string, :size_t, :time_t, :uint32 ], MemcachedReturnT

    # memcached_return_t memcached_replace(memcached_st *ptr, const char *key, size_t key_length, const char *value, size_t value_length, time_t expiration, uint32_t flags)
    attach_function :memcached_replace, [ :pointer, :string, :size_t, :string, :size_t, :time_t, :uint32 ], MemcachedReturnT

    # memcached_return_t memcached_cas(memcached_st *ptr, const char *key, size_t key_length, const char *value, size_t value_length, time_t expiration, uint32_t flags, uint64_t cas)
    attach_function :memcached_cas, [ :pointer, :string, :size_t, :string, :size_t, :time_t, :uint32, :uint32 ], MemcachedReturnT


    # COUNTERS

    # memcached_return_t memcached_increment(memcached_st *ptr, const char *key, size_t key_length, uint32_t offset, uint64_t *value)
    attach_function :memcached_increment, [ :pointer, :string, :size_t, :uint32, :pointer ], MemcachedReturnT

    # memcached_return_t memcached_decrement(memcached_st *ptr, const char *key, size_t key_length, uint32_t offset, uint64_t *value)
    attach_function :memcached_decrement, [ :pointer, :string, :size_t, :uint32, :pointer ], MemcachedReturnT


    # MISC

    # memcached_return_t memcached_flush(memcached_st *ptr, time_t expiration)
    attach_function :memcached_flush, [ :pointer, :time_t ], MemcachedReturnT

    # memcached_return_t memcached_delete(memcached_st *ptr, const char *key, size_t key_length, time_t expiration)
    attach_function :memcached_delete, [ :pointer, :string, :size_t, :time_t ], MemcachedReturnT

    # memcached_return_t memcached_exist(memcached_st *ptr, char *key, size_t *key_length)
    attach_function :memcached_exist, [ :pointer, :string, :size_t ], MemcachedReturnT

  end

end
