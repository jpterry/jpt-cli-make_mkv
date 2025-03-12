# JPT::CLI::MakeMkv

This is a simple gem for encapsulating MakeMKV's `makemkvcon` command line interface in ruby.

It's useful for parsing the output of `makemkvcon` and can be used to build simple async remux jobs.

## Installation

Most likely you'll want to add this gem to your gemfile.

`jpt-cli-make_mkv` is available on rubygems.org.

## Usage

See [`examples/`](examples/) for some ruby examples on usage.

The `JPT::CLI::MakeMkv::Parser` class is the main entry point for parsing the output of `makemkvcon`.

The `JPT::CLI::MakeMkv::Runner` class is the main entry point for running `makemkvcon` and wrapping it in async patterns.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jpterry/jpt-cli-make_mkv.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
