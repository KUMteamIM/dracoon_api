# DracoonApi
https://github.com/KUMteamIM/dracoon_api
 
DracoonApi provides Ruby methods to interact with the Dracoon file services platform API (https://www.dracoon.com/en/home). DracoonApi saves you the time of hand rolling your own Ruby code for the aforementioned purpose. 

You are free to copy, modify, and distribute <PROJECT NAME> with attribution under the terms of the MIT license. See the LICENSE file for details
 

## Installation

Before installing DracoonApi you need:

Ruby 2.6.6 or later

Add this line to your application's Gemfile:

```
gem 'dracoon_api'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install dracoon_api

## Usage

Set login, password and basic_url* using dotenv, see https://github.com/bkeepers/dotenv .
*basic_url refers to your individual Dracoon domain, go through the sign up process on https://www.dracoon.com/ .

```DracoonApi.login = ENV[YOUR LOGIN]
   DracoonApi.password = ENV[YOUR PASSWORD]
   DracoonApi.basic_url = ENV[YOUR BASIC_URL]
```


# Dracoon API documentation: 
https://dracoon.team/api/swagger-ui/index.html?configUrl=/api/spec_v4/swagger-config#/

## Development
Logic is in the file `lib/dracoon_api`. To experiment with that code, run `bin/console` for an interactive prompt.
After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/dracoon_api.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
