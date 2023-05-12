# FedexApis

Ruby wrapper for Fedex RESTful APIs.

## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

    $ bundle add UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

## Usage

TODO: Write usage instructions here

## Development

FedEx API configs are stored in `.env` file. Create one with `cp .env.sample .env`. That's enough for running tests since requests are already recorded with VCR, but you will have to update this file with real credentials in case you need to create or update VCR cassettes. Be careful to not commit real credentials. It's also important to remove credentials from VCR cassettes before committing it.

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Docker

You can you docker compose for development:

 - `docker compose up`
 - `docker compose run gem bundle exec rake test`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fishisfast/fedex_apis.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
