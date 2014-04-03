require_relative "../../../spec_helper"
require "rspec/version"

describe RSpec::Hal::Matchers::HavePropertyMatcher do
  describe "creation" do
    specify { expect{ described_class.new(a_prop_name) }.not_to raise_error }
    specify { expect{ described_class.new(a_prop_name, any_matcher) }.not_to raise_error }
  end

  subject(:matcher) { described_class.new(a_prop_name) }

  specify { expect(matcher.matches?(json_str_w_property)).to be_truthy}
  specify { expect(matcher.matches?(json_str_wo_property)).to be_falsey}

  specify { expect(matcher.matches?(parsed_json_w_property)).to be_truthy}
  specify { expect(matcher.matches?(parsed_json_wo_property)).to be_falsey}

  specify { expect(matcher.matches?(to_halable_w_property)).to be_truthy}
  specify { expect(matcher.matches?(to_halable_wo_property)).to be_falsey}


  describe "value expectation set via #matching(regexp)" do
    subject(:matcher) {  described_class.new(a_prop_name).matching(/ice$/) }

    specify { expect(matcher.description).to match /have property `name`/ }
    specify { expect(matcher.description).to match /match.*ice/ }

    specify { expect(matcher.matches?(json_str_w_property)).to be_truthy}
    specify { expect(matcher.matches?(json_str_wo_property)).to be_falsey}
    specify { expect(matcher.matches?(json_str_w_nonmatching_property)).to be_falsey}
  end

  describe "value expectation set via #matching(another_matcher)" do
    subject(:matcher) { described_class.new(a_prop_name)
        .matching(RSpec::Matchers::BuiltIn::EndWith.new("ice")) }

    specify { expect(matcher.description).to match /have property `name`/ }
    specify { expect(matcher.description).to match /end with.*/ }

    specify { expect(matcher.matches?(json_str_w_property)).to be_truthy}
    specify { expect(matcher.matches?(json_str_wo_property)).to be_falsey}
    specify { expect(matcher.matches?(json_str_w_nonmatching_property)).to be_falsey}
  end

  describe "value expectation set via #including(another_matcher)" do
    subject(:matcher) {  described_class.new('hobbies')
        .including(RSpec::Matchers::BuiltIn::Include.new('type' => 'sport')) }

    specify { expect(matcher.description).to match /have property `hobbies`/ }
    specify { expect(matcher.description).to match /include.*sport/ }

    specify { expect(matcher.matches?(json_str_w_property)).to be_truthy}
    specify { expect(matcher.matches?(json_str_wo_property)).to be_falsey}
    specify { expect(matcher.matches?(json_str_w_nonmatching_property)).to be_falsey}
  end

  describe "value expectation set via #that_is(another_matcher)" do
    subject(:matcher) { described_class.new(a_prop_name)
        .that_is(RSpec::Matchers::BuiltIn::EndWith.new("ice")) }

    specify { expect(matcher.description).to match /have property `name`/ }
    specify { expect(matcher.description).to match /end with.*/ }

    specify { expect(matcher.matches?(json_str_w_property)).to be_truthy}
    specify { expect(matcher.matches?(json_str_wo_property)).to be_falsey}
    specify { expect(matcher.matches?(json_str_w_nonmatching_property)).to be_falsey}
  end

  describe "value expectation set via #that_is(exact_value)" do
    subject(:matcher) { described_class.new(a_prop_name)
        .that_is("Alice") }

    specify { expect(matcher.description).to match /have property `name`/ }
    specify { expect(matcher.description).to match /Alice/ }

    specify { expect(matcher.matches?(json_str_w_property)).to be_truthy}
    specify { expect(matcher.matches?(json_str_wo_property)).to be_falsey}
    specify { expect(matcher.matches?(json_str_w_nonmatching_property)).to be_falsey}
  end

  specify { expect(matcher.description).to match "have property `#{a_prop_name}`" }

  context "failed matcher" do
    subject(:matcher) { described_class.new a_prop_name, eq("hector") }
    before do matcher.matches?(json_str_w_nonmatching_property) end

    specify { expect(matcher.failure_message).to match(/property `#{a_prop_name}`/)
      .and match(/eq "hector"/) }
  end


  # Background
  # ---

  let(:json_str_w_property) { <<-HAL }
    { "name": "Alice"
      ,"hobbies": [{"name": "soccer", "type": "sport"}]
    }
  HAL

  let(:json_str_wo_property) { <<-HAL }
    { }
  HAL

  let(:json_str_w_nonmatching_property) { <<-HAL }
    { "name": "Bob"
      ,"hobbies": [{"name": "trumpet", "type": "music"}] }
  HAL


  let(:parsed_json_w_property) { MultiJson.load json_str_w_property }
  let(:parsed_json_wo_property) { MultiJson.load json_str_wo_property }

  let(:to_halable_w_property) { halable.new json_str_w_property}
  let(:to_halable_wo_property) { halable.new json_str_wo_property }

  let(:halable) { Class.new do
      def initialize(json)
        @json = json
      end

      def to_hal
        return @json
      end
    end }

  let(:a_prop_name) { "name" }

  let(:any_matcher) { matching_prop_value_matcher }
  let(:matching_prop_value_matcher) { match "Alice" }
end
