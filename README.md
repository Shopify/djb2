# DJB2

Native djb2 hash implementation

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add djb2

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install djb2

## Usage

```ruby
require "djb2"

DJB2.digest("Some String") # => 13838202372652591140
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Shopify/djb2.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
