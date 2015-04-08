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

## Contributing

1. Fork it ( https://github.com/[my-github-username]/destination_errors/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Make sure to add tests!
6. Create a new Pull Request

## Contributors

See the [Network View](https://github.com/trumaker/destination_errors/network)

