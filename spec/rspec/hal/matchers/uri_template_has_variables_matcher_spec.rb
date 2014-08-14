require_relative "../../../spec_helper"
require "rspec/version"

describe RSpec::Hal::Matchers::UriTemplateHasVariablesMatcher do
  describe "creation" do
    specify { expect{ described_class.new(a_templated_relation_matcher, ["foo"]) }.
      not_to raise_error }
  end

  subject(:matcher) { described_class.new(a_templated_relation_matcher, ["foo", "bar"]) }

  context "template with required variables" do
    let(:template) { "http://example.com{?foo,bar}" }

    specify { expect(matcher.matches?(json_doc_that_is_ignored)).to be_truthy }
  end

  context "template missing one required variabl" do
    let(:template) { "http://example.com{?foo}" }

    specify { expect(matcher.matches?(json_doc_that_is_ignored)).to be_falsy }
  end

  # Background
  # ---

  let(:template) { "http://example.com" }
  let(:a_templated_relation_matcher) {
    double(:a_templated_relation_matcher, uri_template: template) }
  let(:json_doc_that_is_ignored) { "" }
end
