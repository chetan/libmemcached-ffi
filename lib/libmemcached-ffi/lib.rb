
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

    # const char * memcached_lib_version(void)
    attach_function :memcached_lib_version, [ ], :string

    # memcached_return_t memcached_version(memcached_st *ptr)
    attach_function :memcached_version, [ :pointer ], MemcachedReturnT

    # memcached_st *memcached(const char *string, size_t string_length)
    attach_function :memcached, [ :string, :size_t ], :pointer

    # void memcached_free(memcached_st *ptr)
    attach_function :memcached_free, [ :pointer ], :void

    # char * memcached_get(memcached_st *ptr, const char *key, size_t key_length, size_t *value_length, uint32_t *flags, memcached_return_t *error)
    attach_function :memcached_get, [ :pointer, :string, :size_t, :pointer, :pointer, :pointer ], :string

    # memcached_return_t memcached_set(memcached_st *ptr, const char *key, size_t key_length, const char *value, size_t value_length, time_t expiration, uint32_t flags)
    attach_function :memcached_set, [ :pointer, :string, :size_t, :string, :size_t, :time_t, :uint32 ], MemcachedReturnT

    # memcached_return_t memcached_increment(memcached_st *ptr, const char *key, size_t key_length, uint32_t offset, uint64_t *value)
    attach_function :memcached_increment, [ :pointer, :string, :size_t, :uint32, :pointer ], MemcachedReturnT

    # memcached_return_t memcached_decrement(memcached_st *ptr, const char *key, size_t key_length, uint32_t offset, uint64_t *value)
    attach_function :memcached_decrement, [ :pointer, :string, :size_t, :uint32, :pointer ], MemcachedReturnT

    # memcached_return_t memcached_flush(memcached_st *ptr, time_t expiration)
    attach_function :memcached_flush, [ :pointer, :time_t ], MemcachedReturnT

    # memcached_return_t memcached_delete(memcached_st *ptr, const char *key, size_t key_length, time_t expiration)
    attach_function :memcached_delete, [ :pointer, :string, :size_t, :time_t ], MemcachedReturnT

    # memcached_return_t memcached_exist(memcached_st *ptr, char *key, size_t *key_length)
    attach_function :memcached_exist, [ :pointer, :string, :size_t ], MemcachedReturnT

  end

end
