require 'helper'

module LibMemcachedFFI
  class Cache
    def cache
      @cache
    end
  end
end

class TestCache < MiniTest::Unit::TestCase

  def setup
    @cache = LibMemcachedFFI::Cache.new("127.0.0.1")
  end

  def teardown
  end

  def test_init
    assert @cache
    assert @cache.cache
    assert_kind_of Fixnum, @cache.cache.address
    assert @cache.cache.address > 0
  end

  def test_get
    @cache.set("foo", "bar")
    val = @cache.get("foo")
    assert val
    assert_equal "bar", val
  end

  def test_mget
    @cache.set("foo", "bar")
    @cache.set("baz", "widget")

    ret = @cache.mget(%w{foo baz})
    assert ret
    assert_equal 2, ret.size
    assert ret.include? "foo"
    assert ret.include? "baz"
    assert_equal "bar", ret["foo"]
    assert_equal "widget", ret["baz"]
  end

  def test_incr
    @cache.set("count", "0", 0, false, 0)
    assert_equal 1, @cache.incr("count")
    assert_equal 2, @cache.incr("count")
    assert_equal 5, @cache.incr("count", 3)
    assert_equal "5", @cache.get("count", false)

    assert_equal 3, @cache.decr("count", 2)
    assert_equal 2, @cache.decr("count")
    assert_equal "2", @cache.get("count", false)
  end


  private

end
