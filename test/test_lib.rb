require 'helper'

class TestLibMemcachedFFI_Lib < MiniTest::Unit::TestCase

  include LibMemcachedFFI
  include FFI

  def setup
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
    assert_equal :MEMCACHED_SUCCESS, Lib::MemcachedReturnT[error.read_int]
  end

  def test_set
    ret = Lib.memcached_set(@mc, 'testkey', 7, 'testval', 7, 3600, 0)
    assert_equal :MEMCACHED_SUCCESS, ret
  end


  private

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
