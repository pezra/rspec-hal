[![Build Status](https://travis-ci.org/pezra/hal-interpretation.png?branch=master)](https://travis-ci.org/pezra/hal-interpretation)
[![Code Climate](https://codeclimate.com/github/pezra/hal-interpretation.png)](https://codeclimate.com/github/pezra/hal-interpretation)

# Rspec Hal

Provides matchers and convenience methods for verifying HAL documents.

## Usage

Include the matchers by adding this to your spec_helper

```ruby
RSpec.configuration.include RSpec::Hal::Matchers
```

(Don't forget to `require "rspec-hal"` if you are not using bundler.)

If you are using rspec-rails and want only include the matchers for views do this

```ruby
RSpec.configuration.include RSpec::Hal::Matchers, type: 'view'
```

Once you have the matchers included you can use it like this

```ruby
    expect(a_user_doc).to be_hal

    expect(first_page_of_users).to be_hal_collection

    expect(a_user_doc).to have_property "name"
    expect(a_user_doc).to have_property('name').matching(/ice$/)
    expect(a_user_doc).to have_property('name').matching(end_with('ice'))
    expect(a_user_doc).to have_property('hobbies')
      .including(a_hash_including('type' => 'sport'))

    expect(a_user_doc).to have_relation('tag')
```

## Installation

Add this line to your application's Gemfile:

    gem 'rspec-hal'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec-hal

## Contributing

1. Fork it ( http://github.com/pezra/rspec-hal/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Make your changes and `lib/rspec/hal/version.rb` following [semver][] rules
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request

[semver]: http://semver.org