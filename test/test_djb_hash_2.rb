# frozen_string_literal: true

require "test_helper"

class TestDjbHash2 < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::DjbHash2::VERSION
  end

  def test_works
    ["foo", "bar", Random.bytes(100), Random.bytes(1000)].each do |str|
      assert_equal ruby_djb_hash2(str), DjbHash2.digest(str), "#{str.inspect} didn't match"
    end
  end

  private

  MAX_64 = 2**64
  def ruby_djb_hash2(str)
    str.bytes.reduce(5381) { |hash, char| ((hash * 33) % MAX_64) ^ char } % MAX_64
  end
end
