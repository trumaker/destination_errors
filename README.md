# DestinationErrors

Allows you to create a class that has multiple error surfaces registered but stays within the familiar territory of `ActiveRecord::Validations`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'destination_errors'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install destination_errors

## Usage

Here is a contrived example.

You have three models, and a form that interacts with all of them:
```
class User
  has_one :profile
  has_one :account
end

class Profile
  belongs_to :user
end

class Account
  belongs_to :user
end
```

So you create an admin user form presenter class to handle everything, and you want it to be *railsy*.
```
class AdminUserFormPresenter

  include DestinationErrors

  attr_accessor :user, :profile, :account
  has_error_surfaces [nil, :user, :profile, :account]

  def initialize(*args)
    @surface_errors_on = nil # nil means errors will be moved onto this instance.
  end

end
```

For more example usage see the specs.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Maintenance

To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Versioning

This library aims to adhere to [Semantic Versioning 2.0.0](http://semver.org/).
Violations of this scheme should be reported as bugs. Specifically,
if a minor or patch version is released that breaks backward
compatibility, a new version should be immediately released that
restores compatibility. Breaking changes to the public API will
only be introduced with new major versions.

As a result of this policy, you can (and should) specify a
dependency on this gem using the [Pessimistic Version Constraint](http://docs.rubygems.org/read/chapter/16#page74) with two digits of precision.

For example:

    spec.add_dependency 'destination_errors', '~> 0.0'

## Contributing

1. Fork it ( https://github.com/[my-github-username]/destination_errors/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Make sure to add tests!
6. Create a new Pull Request

## Contributors

See the [Network View](https://github.com/trumaker/destination_errors/network)

