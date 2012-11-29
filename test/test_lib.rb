require 'helper'

class TestLibMemcachedFFI_Lib < MiniTest::Unit::TestCase

  include LibMemcachedFFI
  include FFI

  def setup
    @key = "testkey"
    @port = 11211
    conf = "--SERVER=127.0.0.1:#{@port}"
    @mc = Lib.memcached(conf, conf.length)
  end

  def teardown
    Lib.memcached_free(@mc) if @mc
  end

  def test_version
    ver = Lib.memcached_lib_version
    assert ver
    assert_kind_of String, ver
    assert ver =~ /^\d.\d+.\d+$/

    ret = Lib.memcached_version(@mc)
    assert_equal :MEMCACHED_SUCCESS, ret

    m = Lib::MemcachedSt.new(@mc)
    assert_equal 1, m[:number_of_hosts]

    s = Lib::MemcachedServerSt.new(m[:servers])
    assert_equal @port, s[:port]
  end

  def test_create
    assert @mc
    assert @mc.address > 0
  end

  def test_get

    # seed data
    s = Time.new.to_s
    ret = Lib.memcached_set(@mc, @key, 7, s, s.length, 3600, 0)

    # try to read back
    string_length = MemoryPointer.new :size_t
    flags = MemoryPointer.new :uint32
    error = MemoryPointer.new :pointer
    ret = Lib.memcached_get(@mc, @key, 7, string_length, flags, error)

    assert ret
    assert_equal s, ret
    assert_equal s.length, string_length.read_int
    assert_equal 0, error.read_int
    assert_equal :MEMCACHED_SUCCESS, Lib::MemcachedReturnT[error.read_int]
  end

  def test_set
    ret = Lib.memcached_set(@mc, @key, @key.length, 'testval', 7, 3600, 0)
    assert_equal :MEMCACHED_SUCCESS, ret
  end

  def test_incr
    ret = Lib.memcached_set(@mc, @key, @key.length, "0", 1, 3600, 0)
    assert_equal :MEMCACHED_SUCCESS, ret

    value_ptr = MemoryPointer.new :uint64
    ret = Lib.memcached_increment(@mc, @key, @key.length, 1, value_ptr)
    assert_equal :MEMCACHED_SUCCESS, ret

    assert_equal 1, read(@key).to_i
    assert_equal 1, value_ptr.read_int

    value_ptr = MemoryPointer.new :uint64
    ret = Lib.memcached_increment(@mc, @key, @key.length, 10, value_ptr)
    assert_equal :MEMCACHED_SUCCESS, ret

    assert_equal 11, read(@key).to_i
    assert_equal 11, value_ptr.read_int

    value_ptr = MemoryPointer.new :uint64
    ret = Lib.memcached_decrement(@mc, @key, @key.length, 3, value_ptr)
    assert_equal :MEMCACHED_SUCCESS, ret

    assert_equal 8, read(@key).to_i
    assert_equal 8, value_ptr.read_int
  end

  def test_flush
    create_test_key()

    ret = Lib.memcached_flush(@mc, 0)
    assert_equal :MEMCACHED_SUCCESS, ret

    test_key_is_missing()
  end

  def test_delete
    create_test_key()

    ret = Lib.memcached_delete(@mc, @key, @key.length, 0)
    assert_equal :MEMCACHED_SUCCESS, ret

    test_key_is_missing()
  end

  def test_exist
    create_test_key()

    ret = Lib.memcached_exist(@mc, @key, @key.length)
    assert_equal :MEMCACHED_SUCCESS, ret
  end

  def test_mget
    # create test data
    create_test_key()
    key2 = "bar"
    ret = Lib.memcached_set(@mc, key2, key2.length, 'baz', 3, 0, 50)
    assert_equal :MEMCACHED_SUCCESS, ret
    assert_equal "baz", read(key2)

    # create ptr args
    keys_ptr = FFIUtil.string_ptrs([@key, key2])
    keylen_ptr = FFIUtil.ptrs_of_type(:size_t, [@key.length, key2.length])

    # mget
    ret = Lib.memcached_mget(@mc, keys_ptr, keylen_ptr, 2)
    if ret != :MEMCACHED_SUCCESS then
      puts Lib.memcached_last_error_message(@mc)
    end
    assert_equal :MEMCACHED_SUCCESS, ret

    # fetch first result - get result from passed pointer
    result_ptr = MemoryPointer.new(Lib::MemcachedResultSt)
    error_ptr = MemoryPointer.new(:pointer)
    Lib.memcached_fetch_result(@mc, result_ptr, error_ptr)
    assert_equal :MEMCACHED_SUCCESS, Lib::MemcachedReturnT[error_ptr.read_int]
    assert_equal "testval", Lib.memcached_result_value(result_ptr)

    # fetch second result - get result from return val
    error_ptr = MemoryPointer.new(:pointer)
    res = Lib.memcached_fetch_result(@mc, nil, error_ptr)
    assert_equal :MEMCACHED_SUCCESS, Lib::MemcachedReturnT[error_ptr.read_int]
    assert_equal "baz", Lib.memcached_result_value(res)
    assert_equal 50, Lib.memcached_result_flags(res)
  end


  private

  def create_test_key
    ret = Lib.memcached_set(@mc, @key, @key.length, 'testval', 7, 3600, 0)
    assert_equal :MEMCACHED_SUCCESS, ret
    assert_equal "testval", read(@key)
  end

  def test_key_is_missing
    # key should be missing
    string_length = MemoryPointer.new :size_t
    flags = MemoryPointer.new :uint32
    error = MemoryPointer.new :pointer
    ret = Lib.memcached_get(@mc, @key, @key.length, string_length, flags, error)
    assert_equal :MEMCACHED_NOTFOUND, Lib::MemcachedReturnT[error.read_int]
  end

  def read(key)
    string_length = MemoryPointer.new :size_t
    flags = MemoryPointer.new :uint32
    error = MemoryPointer.new :pointer
    ret = Lib.memcached_get(@mc, key, key.length, string_length, flags, error)
    assert_equal :MEMCACHED_SUCCESS, Lib::MemcachedReturnT[error.read_int]

    return ret
  end


  def dump_struct(s)
    puts
    puts
    s.members.each do |f|
      # next if f == :hostname
      if f == :hostname then
        h = s[f]
        puts h.to_ptr
        puts sprintf("%s: %s", f, h.to_ptr.read_string.dump)
      else
        puts sprintf("%s: %s", f, s[f].to_s)
      end
    end
  end

end
