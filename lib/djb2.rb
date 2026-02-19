# frozen_string_literal: true

require_relative "djb2/version"

begin
  # Load the precompiled version of the library
  ruby_version = /(\d+\.\d+)/.match(RUBY_VERSION)
  require "djb2/#{ruby_version}/djb2"
rescue LoadError
  # It's important to leave for users that can not or don't want to use the gem with precompiled binaries.
  require "djb2/djb2"
end

module DJB2
  class Error < StandardError; end
  # Your code goes here...
end
