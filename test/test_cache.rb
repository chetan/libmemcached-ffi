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
    @cache.set("foo", "bar", 0, 0)
    val, flags = @cache.get("foo")
    assert val
    assert_equal "bar", val
  end


  private

end
