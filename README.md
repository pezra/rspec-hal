[![Build Status](https://travis-ci.org/pezra/rspec-hal.png?branch=master)](https://travis-ci.org/pezra/rspec-hal)
[![Code Climate](https://codeclimate.com/github/pezra/rspec-hal.png)](https://codeclimate.com/github/pezra/rspec-hal)

# Rspec Hal

Provides matchers and convenience methods for verifying HAL documents.

## Usage

Given the following string stored in `a_user_doc`.

```json
 {
   "name": "Alice",
   "hobbies": [{"name": "Basketball", "type": "sport"},
               {"name": "Basket weaving", "type": "craft"}]
   "_links": {
     "self": { "href": "http://example.com/alice" },
     "knows": [{ "href": "http://example.com/bob" },
               { "href": "http://example.com/jane" }],
     "checkBusy": { "href": "http://example.com/is_busy{?at}",
                    "templated": true }
   }
 }
```

Rspec Hal allows very expressive validation of documents.

```ruby
    expect(a_user_doc).to be_hal

    expect(a_user_doc).not_to be_hal_collection

    expect(a_user_doc).to have_property "name"
    expect(a_user_doc).to have_property 'name', matching(/ice$/)
    expect(a_user_doc).to have_property :name, end_with('ice')
    expect(a_user_doc).to have_property 'hobbies', including(a_hash_including('type' => 'sport'))

    expect(a_user_doc).to have_relation "knows"
    expect(a_user_doc).to have_templated_relation "checkBusy"
    expect(a_user_doc).to have_templated_relation "checkBusy", has_variable("at")
    expect(a_user_doc).to have_templated_relation("checkBusy").with_variables("at")
```

Any matcher (actually anything that responds to `#===`) can
be passed as the second argument and will be used to verify the
property value or the link href.

`be_hal_collection` checks that the document is both a valid HAL
document and is a page of an RFC 6573 collection

`be_hal` checks that the document is both a valid HAL
document.


## Installation

Add this line to your application's Gemfile:

    gem 'rspec-hal'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec-hal

Then include the matchers by adding this to your spec_helper

```ruby
RSpec.configuration.include RSpec::Hal::Matchers
```

(Don't forget to `require "rspec-hal"` if you are not using bundler.)

If you want to only include the matchers for certain type of specs
(say, view specs for example)

```ruby
RSpec.configuration.include RSpec::Hal::Matchers, type: 'view'
```


## Contributing

1. Fork it ( http://github.com/pezra/rspec-hal/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Make your changes and `lib/rspec/hal/version.rb` following [semver][] rules
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request

[semver]: http://semver.org
