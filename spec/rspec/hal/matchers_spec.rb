require_relative "../../spec_helper"

describe RSpec::Hal::Matchers::Document do
  describe "be_hal" do
    subject(:matcher) { be_hal }

    specify { expect(matcher.matches?(hal_doc)).to be true }
    specify { expect(matcher.matches?("What's HAL?")).to be false }
  end

  describe "be_hal_collection" do
    subject(:matcher) { be_hal_collection }

    specify { expect(matcher.matches?(hal_collection)).to be true }
    specify { expect(matcher.matches?("What's HAL?")).to be false }
    specify { expect(matcher.matches?(hal_doc)).to be false }
  end



  before do extend described_class end

  let(:hal_collection) { <<-HAL }
    { "_embedded": { "item": [
          #{hal_doc}
    ]}}
  HAL
  let(:hal_doc) { <<-HAL }
    { "name": "Alice"
      ,"_links": {
        "tag": [{ "href": "http://tags.example.com/smart" }]
      }
      ,"_embedded": {
        "http://rel.example.com/boss_of": { "href": "http://example.com/users/42" }
      }
    }
  HAL
end
