require_relative "../../spec_helper"
require "rspec/version"

describe RSpec::Hal::Helpers do
  subject { Class.new do
      include RSpec::Hal::Helpers
    end.new }

  specify { expect(subject.parse_hal(hal_doc)).to be_kind_of HalClient::Representation  }
  specify { expect(subject.parse_hal(hal_collection)).to be_kind_of HalClient::Collection  }

  # Background/Support
  # ---

  let(:hal_collection) { <<-HAL }
    { "_embedded": { "item": [
          #{hal_doc}
    ]}}
  HAL

  let(:hal_doc) { <<-HAL }
    { "name": "Alice"
    }
  HAL
end
