# frozen_string_literal: true

require_relative "djb2/version"

module DJB2
  class Error < StandardError; end

  # Computes the djb2 hash (xor variant) of the given string.
  #
  # The hash is computed using 64-bit arithmetic split into two 32-bit
  # halves to keep all intermediate values within Ruby's Fixnum range,
  # avoiding Bignum allocation in the hot loop. This makes the
  # implementation YJIT-friendly: the JIT can emit efficient native
  # code for the entire loop without any object allocations.
  #
  # @param string [String] the string to hash (binary-safe, operates on raw bytes)
  # @return [Integer] a 64-bit unsigned integer hash value
  # @raise [TypeError] if the argument is not a String
  def self.digest(string)
    raise TypeError, "no implicit conversion of #{string.class} into String" unless string.is_a?(String)

    hi = 0       # upper 32 bits of the hash
    lo = 5381    # lower 32 bits of the hash
    i = 0
    len = string.bytesize

    # Process 4 bytes at a time to reduce loop overhead.
    stop = len - (len & 3)
    while i < stop
      # Multiply (hi:lo) by 33 using: x * 33 = (x << 5) + x
      # lo half: must mask (lo << 5) to 32 bits BEFORE adding lo, so that
      # the carry into the hi half is correct (0 or 1, never more).
      t = ((lo << 5) & 0xFFFFFFFF) + lo
      # hi half: (hi << 5) can be up to 37 bits, but the total expression
      # still fits in a Fixnum (< 62 bits), so we only mask at the end.
      hi = ((hi << 5) + (lo >> 27) + hi + (t >> 32)) & 0xFFFFFFFF
      # XOR the current byte into the lo half.
      lo = (t & 0xFFFFFFFF) ^ string.getbyte(i)

      t = ((lo << 5) & 0xFFFFFFFF) + lo
      hi = ((hi << 5) + (lo >> 27) + hi + (t >> 32)) & 0xFFFFFFFF
      lo = (t & 0xFFFFFFFF) ^ string.getbyte(i + 1)

      t = ((lo << 5) & 0xFFFFFFFF) + lo
      hi = ((hi << 5) + (lo >> 27) + hi + (t >> 32)) & 0xFFFFFFFF
      lo = (t & 0xFFFFFFFF) ^ string.getbyte(i + 2)

      t = ((lo << 5) & 0xFFFFFFFF) + lo
      hi = ((hi << 5) + (lo >> 27) + hi + (t >> 32)) & 0xFFFFFFFF
      lo = (t & 0xFFFFFFFF) ^ string.getbyte(i + 3)

      i += 4
    end

    # Handle remaining 0-3 bytes.
    while i < len
      t = ((lo << 5) & 0xFFFFFFFF) + lo
      hi = ((hi << 5) + (lo >> 27) + hi + (t >> 32)) & 0xFFFFFFFF
      lo = (t & 0xFFFFFFFF) ^ string.getbyte(i)
      i += 1
    end

    # Combine the two halves into a 64-bit result. Using multiply instead
    # of (hi << 32) | lo avoids a YJIT side exit caused by left shift overflow.
    hi * 0x100000000 + lo
  end
end
