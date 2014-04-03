require_relative "../../../spec_helper"

describe RSpec::Hal::Matchers::RelationMatcher do
  describe "creation" do
    specify { expect{ described_class.new(a_link_rel) }.not_to raise_error }
    specify { expect{ described_class.new(a_link_rel, any_href_matcher) }.not_to raise_error }
    specify { expect{ described_class.new(a_link_rel, template_variables, any_href_matcher) }
        .not_to raise_error }
  end

  subject(:matcher) { described_class.new(a_link_rel) }

  specify{ expect(matcher.matches?(json_str_w_link)).to be_truthy }
  specify{ expect(matcher.matches?(json_str_wo_link)).to be_falsey }

  context "curries" do
    let(:a_link_rel) { "http://example.com/rels/foo" }
    specify{ expect(matcher.matches?(json_str_w_curied_link)).to be_truthy }

    context "trying to match unexpanded rel" do
      let(:a_link_rel) { "ex:foo" }
      specify{ expect(matcher.matches? json_str_w_curied_link).to be_falsey }
    end
  end

  context "templated links" do
    subject(:matcher) { described_class.new(a_link_rel, which: "mother") }

    specify{ expect(matcher.matches? json_str_w_templated_link).to be_truthy }
    specify{ expect(matcher.matches? json_str_w_link).to be_truthy }
    specify{ expect(matcher.matches? json_str_wo_link).to be_falsey }
  end

  context "templated links with href matcher" do
    subject(:matcher) { described_class.new(a_link_rel, {which: "mother"}, match(/parent/)) }

    specify{ expect(matcher.matches? json_str_w_templated_link).to be_truthy }
    specify{ expect(matcher.matches? json_str_w_link).to be_truthy }
    specify{ expect(matcher.matches? json_str_wo_link).to be_falsey }
  end

  specify{ expect(matcher.matches?(parsed_json_w_link)).to be_truthy }
  specify{ expect(matcher.matches?(parsed_json_wo_link)).to be_falsey }

  specify{ expect(matcher.matches?(to_halable_w_link)).to be_truthy }
  specify{ expect(matcher.matches?(to_halable_wo_link)).to be_falsey }

  specify { expect(matcher.description).to match "have #{a_link_rel} link" }

  context "exact expected href specified via #with_href" do
    subject(:matcher) { described_class.new(a_link_rel)
        .with_href("http://example.com/parent") }

    specify{ expect(matcher.matches? json_str_w_link).to be_truthy }
    specify{ expect(matcher.matches? json_str_wo_link).to be_falsey }
  end

  context "regexp expected href specified via #with_href" do
    subject(:matcher) { described_class.new(a_link_rel)
        .with_href(%r(/parent)) }

    specify{ expect(matcher.matches? json_str_w_link).to be_truthy }
    specify{ expect(matcher.matches? json_str_wo_link).to be_falsey }
  end

  context "matcher for expected href specified via #with_href" do
    subject(:matcher) { described_class.new(a_link_rel)
        .with_href(end_with("parent")) }

    specify{ expect(matcher.matches? json_str_w_link).to be_truthy }
    specify{ expect(matcher.matches? json_str_wo_link).to be_falsey }
  end

  context "non-matching expected href specified via #with_href" do
    subject(:matcher) { described_class.new(a_link_rel)
        .with_href("Malory") }

    specify{ expect(matcher.matches? json_str_w_link).to be_falsy }
  end


  context "failed due to missing relation matcher" do
    before do
      matcher.matches? json_str_wo_link
    end

    specify { expect(matcher.failure_message)
        .to match "Expected `#{a_link_rel}` link or embedded but found none" }
    specify { expect(matcher.failure_message_for_should)
        .to match matcher.failure_message }
  end

  context "failed due to unexpected existing relation" do
    before do
      matcher.matches? json_str_w_link
    end

    specify { expect(matcher.failure_message_when_negated)
        .to match "Expected `#{a_link_rel}` link to be absent" }
    specify { expect(matcher.failure_message_for_should_not)
        .to match matcher.failure_message_when_negated }
  end

  context "failed due to sub-matcher failure matcher" do
    subject(:matcher) { described_class.new(a_link_rel, match("absent")) }
    before do
      matcher.matches? json_str_wo_link
    end

    specify { expect(matcher.failure_message)
        .to match %r(Expected `#{a_link_rel}` link or embedded match(?:ing)? "absent" but found none) }
  end


  # Background
  # ---

  let(:json_str_w_link) { <<-HAL }
    { "_links": {
      "up": {"href": "http://example.com/parent"}
    }}
  HAL

  let(:json_str_wo_link) { <<-HAL }
    { "_links": {
    }}
  HAL

  let(:json_str_w_curied_link) { <<-HAL }
    { "_links": {
      "ex:foo": {"href": "http://example.com/parent"},
      "curies": [
        {"name": "ex", "href": "http://example.com/rels/{rel}", "templated": true }
      ]
    }}
  HAL

  let(:json_str_w_templated_link) { <<-HAL }
    { "_links": {
      "up": {"href": "http://example.com/parent{?which}", "templated": true}
    }}
  HAL


  # let(:json_str_w_nontemplate_link) { <<-HAL }
  #   { "_links": {
  #     "up": {"href": "http://example.com/parent"}
  #   }}
  # HAL


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

  let(:a_link_rel) { "up" }
  let(:any_href_matcher) { matching_href_matcher }
  let(:matching_href_matcher) { match /example.com/ }
  let(:nonmatching_href_matcher) { match "hello" }
  let(:template_variables) { {q: "search terms"} }
end
