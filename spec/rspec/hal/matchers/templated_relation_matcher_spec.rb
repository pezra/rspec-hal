require_relative "../../../spec_helper"
require 'rspec/version'

describe RSpec::Hal::Matchers::TemplatedRelationMatcher do
  describe "creation" do
    specify { expect{ described_class.new(a_link_rel) }.not_to raise_error }
    specify { expect{ described_class.new(a_link_rel, any_template_str_matcher) }.not_to raise_error }
    specify { expect{ described_class.new(a_link_rel, /hello/) }.not_to raise_error }
  end

  subject(:matcher) { described_class.new(a_link_rel) }

  specify{ expect(matcher.matches?(json_str_w_link)).to be }
  specify{ expect(matcher.matches?(json_str_wo_link)).not_to be }

  specify{ expect(matcher.matches?(parsed_json_w_link)).to be }
  specify{ expect(matcher.matches?(parsed_json_wo_link)).not_to be }

  specify{ expect(matcher.matches?(to_halable_w_link)).to be }
  specify{ expect(matcher.matches?(to_halable_wo_link)).not_to be }

  specify{ expect(matcher.matches?(json_str_w_nontemplate_link)).not_to be }

  specify { expect(matcher.description).to match "have templated #{a_link_rel} link" }

  specify { expect(matcher.with_variables("since", "before")).to be_a_matcher }
  specify { expect(matcher.with_variable("since")).to be_a_matcher }

  context "symbol rel name" do
    subject(:matcher) { described_class.new(a_link_rel.to_sym) }

    specify{ expect(matcher.matches?(json_str_w_link)).to be }
    specify{ expect(matcher.matches?(json_str_wo_link)).not_to be }
  end

  context "failed due to missing relation matcher" do
    before do
      matcher.matches? json_str_wo_link
    end

    specify { expect(matcher.failure_message)
        .to match "Expected templated `#{a_link_rel}` link but found none" }
    specify { expect(matcher.failure_message_for_should)
        .to match matcher.failure_message }
  end

  context "failed due to unexpected existing relation" do
    before do
      matcher.matches? json_str_w_link
    end

    specify { expect(matcher.failure_message_when_negated)
        .to match "Expected `#{a_link_rel}` link to be absent or not templated" }
    specify { expect(matcher.failure_message_for_should_not)
        .to match matcher.failure_message_when_negated }
  end

  context "failed due existing non-templated relation" do
    before do
      matcher.matches? json_str_w_nontemplate_link
    end

    specify { expect(matcher.failure_message)
        .to match "Expected templated `#{a_link_rel}` link but found only non-templated links" }
  end

  context "failed due to sub-matcher failure matcher" do
    subject(:matcher) { described_class.new(a_link_rel, match(/absent/)) }
    before do
      matcher.matches? json_str_w_link
    end

    specify { expect(matcher.failure_message)
        .to match %r(Expected templated `#{a_link_rel}` link match(?:ing)? /absent/ but found none) }
  end


  # Background
  # ---

  let(:json_str_w_link) { <<-HAL }
    { "_links": {
      "search": {"href": "http://example.com/s{?q}", "templated": true}
    }}
  HAL

  let(:json_str_wo_link) { <<-HAL }
    { "_links": {
    }}
  HAL

  let(:json_str_w_nontemplate_link) { <<-HAL }
    { "_links": {
      "search": {"href": "http://example.com/s{?q}", "templated": false}
    }}
  HAL


  let(:parsed_json_w_link) { MultiJson.load json_str_w_link }
  let(:parsed_json_wo_link) { MultiJson.load json_str_wo_link }

  let(:to_halable_w_link) { halable.new json_str_w_link}
  let(:to_halable_wo_link) { halable.new json_str_wo_link }

  let(:halable) { Class.new do
      def initialize(json)
        @json = json
      end

      def to_hal
        return @json
      end
    end }

  let(:a_link_rel) { "search" }
  let(:any_template_str_matcher) { matching_template_str_matcher }
  let(:matching_template_str_matcher) { match "example.com" }
  let(:nonmatching_template_str_matcher) { match "hello" }

  matcher :be_a_matcher do
    match do |actual|
      %w"matches?
         description
         failure_message
         failure_message_when_negated".all? { |meth_name|
        actual.respond_to? meth_name
      }
    end
  end
end
