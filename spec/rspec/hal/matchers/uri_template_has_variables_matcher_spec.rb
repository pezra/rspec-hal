require_relative "../../../spec_helper"
require "rspec/version"

describe RSpec::Hal::Matchers::UriTemplateHasVariablesMatcher do
  describe "creation" do
    specify { expect{ described_class.new(["foo"]) }.
      not_to raise_error }
  end

  subject(:matcher) { described_class.new(["foo", "bar"]) }

  specify { expect(matcher.matches?("http://example.com{?foo,bar}")).to be_truthy }
  specify { expect(matcher.matches?("http://example.com{?foo}")).to be_falsy }
  specify { expect(matcher.description).to match /foo, bar/ }

  context "names as symbol" do
    subject(:matcher) { described_class.new([:foo, :bar]) }

    specify { expect(matcher.matches?("http://example.com{?foo,bar}")).to be_truthy }
    specify { expect(matcher.matches?("http://example.com{?foo}")).to be_falsy }
  end

  describe "failed matcher" do
    before do matcher.matches?("http://example.com{?foo}") end

    specify { expect(matcher.failure_message).to match /foo, bar/ }
  end

  describe "passed matcher" do
    before do matcher.matches?("http://example.com{?foo,bar}") end

    specify { expect(matcher.failure_message_when_negated).to match /foo, bar/ }
  end

  # Background
  # ---

  let(:template) { "http://example.com" }
  let(:a_templated_relation_matcher) {
    double(:a_templated_relation_matcher, uri_template: template) }
  let(:json_doc_that_is_ignored) { "" }
end
