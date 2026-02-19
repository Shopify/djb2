# frozen_string_literal: true

# Re-exec with --yjit if YJIT is available but not yet enabled.
if defined?(RubyVM::YJIT) && !RubyVM::YJIT.enabled?
  exec(RbConfig.ruby, "--yjit", $0, *ARGV)
end

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "benchmark-ips"
  gem "djb2", "0.1.1"
end

# ── Load the C extension (released gem) ──────────────────────────────────────
require "djb2"
c_digest = DJB2.method(:digest)

# ── Pure Ruby implementation (this branch) ───────────────────────────────────
load File.expand_path("../lib/djb2.rb", __dir__)
ruby_digest = DJB2.method(:digest)

# ── Verify correctness ──────────────────────────────────────────────────────
test_strings = ["foo", "bar", "hello world", "x" * 100, Random.bytes(1000)]
test_strings.each do |s|
  c_result = c_digest.call(s)
  ruby_result = ruby_digest.call(s)
  unless c_result == ruby_result
    abort "MISMATCH on #{s.inspect[0..40]}: C=#{c_result} Ruby=#{ruby_result}"
  end
end
puts "Correctness verified: both implementations produce identical results."
puts

# ── Environment ──────────────────────────────────────────────────────────────
puts "Ruby:  #{RUBY_VERSION} (#{RUBY_PLATFORM})"
puts "YJIT:  #{RubyVM::YJIT.enabled? ? "enabled" : "DISABLED"}"
puts

# ── Warmup YJIT ─────────────────────────────────────────────────────────────
warmup_str = "warmup" * 50
20_000.times { c_digest.call(warmup_str) }
20_000.times { ruby_digest.call(warmup_str) }
puts "YJIT warmup complete (20k iterations each)."
puts

# ── Benchmark ────────────────────────────────────────────────────────────────
inputs = {
  "short (5B)"    => "hello",
  "realistic (134B)" => "{\"template_name\":\"customers\\/account.json\",\"section_id\":\"section-id\",\"block_id\":\"abc\\/\\/dc\\u0026f\",\"setting_id\":\"setting11111-id\"}",
  "medium (100B)" => "x" * 100,
  "long (1KB)"    => "y" * 1024,
  "long (10KB)"   => "z" * 10240,
}

inputs.each do |label, str|
  puts "=" * 60
  puts "  #{label}  (#{str.bytesize} bytes)"
  puts "=" * 60

  Benchmark.ips do |x|
    x.config(warmup: 2, time: 5)

    x.report("C extension") { c_digest.call(str) }
    x.report("Pure Ruby")   { ruby_digest.call(str) }

    x.compare!
  end
  puts
end
