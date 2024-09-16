# Plunk Ruby client

This is a Plunk Ruby client, based on the [Mailtrap Ruby client](https://github.com/railsware/mailtrap-ruby).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'plunk', github: "https://github.com/adiprnm/plunk-ruby"
```

And then execute:

    $ bundle install

## Usage

### Minimal

```ruby
require 'plunk'

# create mail object
mail = Plunk::Mail::Base.new(
  from: { email: 'plunk@example.com', name: 'Plunk Test' },
  to: [
    { email: 'your@email.com' }
  ],
  subject: 'You are awesome!',
  text: "Congrats for sending test email with Plunk!"
)

# create client and send
client = Plunk::Client.new(api_key: 'your-api-key')
client.send(mail)
```

Refer to the [`examples`](examples) folder for other examples.

- [Full](examples/full.rb)
- [Email template](examples/email_template.rb)
- [ActionMailer](examples/action_mailer.rb)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/railsware/mailtrap-ruby). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Mailtrap project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](CODE_OF_CONDUCT.md).
