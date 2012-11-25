require 'helper'

class TestLibMemcachedFFI_Lib < MiniTest::Unit::TestCase

  include LibMemcachedFFI
  include FFI

  def setup
    create()
  end

  def teardown
    Lib.memcached_free(@mc) if @mc
  end

  def test_version
    ver = Lib.memcached_lib_version
    assert ver
    assert_kind_of String, ver
    assert ver =~ /^\d.\d+.\d+$/
  end

  def test_create
    assert @mc
    assert @mc.address > 0
  end

  def test_get

    # seed data
    s = Time.new.to_s
    ret = Lib.memcached_set(@mc, 'testkey', 7, s, s.length, 3600, 0)

    # try to read back
    string_length = MemoryPointer.new :size_t
    flags = MemoryPointer.new :uint32
    error = MemoryPointer.new :pointer
    ret = Lib.memcached_get(@mc, 'testkey', 7, string_length, flags, error)

    assert ret
    assert_equal s, ret
    assert_equal s.length, string_length.read_int
    assert_equal 0, error.read_int
    assert_equal :MEMCACHED_SUCCESS, Lib::ReturnT[error.read_int]
  end

  def test_set
    ret = Lib.memcached_set(@mc, 'testkey', 7, 'testval', 7, 3600, 0)
    assert_equal :MEMCACHED_SUCCESS, ret
  end


  private

  def create
    conf = "--SERVER=127.0.0.1:11211"
    @mc = Lib.memcached(conf, conf.length)
  end

end
