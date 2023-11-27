# frozen_string_literal: true

require_relative "lib/djb2/version"

Gem::Specification.new do |spec|
  spec.name = "djb2"
  spec.version = DJB2::VERSION
  spec.authors = ["Jean Boussier"]
  spec.email = ["jean.boussier@gmail.com"]

  spec.summary = "Native djb2 hash implementation"
  spec.homepage = "https://github.com/Shopify/djb2"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/Shopify/djb2/issues",
    "source_code_uri" => "https://github.com/Shopify/djb2",
    "allowed_push_host" => "https://rubygems.org",
  }

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.extensions = ["ext/djb2/extconf.rb"]
end
