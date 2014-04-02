require_relative "../../spec_helper"
require "rspec/version"

describe RSpec::Hal::Matchers do
  subject { Class.new do
      include RSpec::Hal::Matchers
    end.new }

  specify { expect(subject.be_hal).to be_a_matcher }
  specify { expect(subject.be_hal_collection).to be_a_matcher }
  specify { expect(subject.have_property("name")).to be_a_matcher }
  specify { expect(subject.have_templated_relation("search")).to be_a_matcher }
  specify { expect(subject.have_relation("search")).to be_a_matcher }

  # Background/Support
  # ---

  matcher :be_a_matcher do
    match do |actual|
      respond_to?(:matches?) && respond_to?(:failure_message)
    end
  end
end

describe RSpec::Hal::Matchers::Document do
  describe "be_hal" do
    subject(:matcher) { be_hal }

    specify { expect(matcher.matches?(hal_doc)).to be_truthy }
    specify { expect(matcher.matches?("What's HAL?")).to be_falsey }
  end

  describe "be_hal_collection" do
    subject(:matcher) { be_hal_collection }

    specify { expect(matcher.matches?(hal_collection)).to be_truthy }
    specify { expect(matcher.matches?("What's HAL?")).to be_falsey }
    specify { expect(matcher.matches?(hal_doc)).to be_falsey }
  end

  describe "have_relation('tag')" do
    subject(:matcher) { have_relation('tag') }

    specify { expect(matcher.matches?(hal_doc)).to be_truthy}
    specify { expect(matcher.matches?("{}")).to be_falsey}
    specify { expect(matcher.matches?(bob)).to be_falsey}
  end


  before do
    extend RSpec::Hal::Matchers::Document
  end

  let(:hal_collection) { <<-HAL }
    { "_embedded": { "item": [
          #{hal_doc}
    ]}}
  HAL
  let(:hal_doc) { <<-HAL }
    { "name": "Alice"
      ,"hobbies": [{"type": "sport", "name": "golf"}]
      ,"_links": {
        "tag": [{ "href": "http://tags.example.com/smart" }]
      }
      ,"_embedded": {
        "http://rel.example.com/boss_of": #{bob}
      }
    }
  HAL
  let(:bob) { <<-HAL }
    { "name": "Bob"
      ,"_links": {
        "self": { "href": "http://example.com/users/42" }
      }
      ,"_embedded": {
      }
    }
  HAL
end
