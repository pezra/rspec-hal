require 'json'
require 'hal-client'

module RSpec
  module Hal
    module Matchers
      module Document
        extend RSpec::Matchers::DSL

        # Check that the document provided is a valid HAL document.
        #
        # Signature
        #
        #     expect(a_user_doc).to be_hal
        matcher :be_hal do
          match do |a_json_doc|
             !!(JSON.load(a_json_doc) rescue false)
          end

          failure_message do |a_json_doc|
            message = begin
                        JSON.load(a_json_doc)
                      rescue err
                        err.message
                      end
            message + " while parsing:\n" + a_json_doc
          end
        end

        # Check that the document is both a valid HAL document and is
        # a page of an RFC 6573 collection
        #
        # Signature
        #
        #     expect(first_users_page).to be_hal_collection
        matcher :be_hal_collection do
          match do |a_doc|
            a_doc = JSON.load(a_doc) rescue a_doc

            a_doc.fetch("_embedded").has_key?("item") rescue false
          end

          failure_message do |a_doc|
            "Expected `$._embedded.item` to exist in:\n" + a_doc
          end
        end

        # Check that the document has the specified property.
        #
        # Signature
        #
        #     expect(a_user_doc).to have_property "name"
        #     expect(a_user_doc).to have_property("name").matching(/bob/i)
        #     expect(a_user_doc).to have_property("hobbies").including(matching("golf"))
        matcher :have_property do |prop_name|
          match do |a_doc|
            a_doc = JSON.load(a_doc) rescue a_doc


            next false unless a_doc.key? prop_name

            __value_matcher === a_doc.fetch(prop_name)
          end

          chain :matching do |val_pat|
            @value_matcher = val_pat
          end

          chain :including do |val_pat|
            @value_matcher = RSpec::Matchers::BuiltIn::Include.new val_pat
          end

          define_method(:__value_matcher) do
            @value_matcher ||=  ->(*_){ true }
          end
        end

        # Check that the document has the specified relation (in
        # either the _links or _embedded sections.
        #
        # Signature
        #
        #     expect(a_user_doc).to have_relation "tag"
        matcher :have_relation do |link_rel|
          match do |a_doc|
            a_doc = JSON.load(a_doc) rescue a_doc
            repr = HalClient::Representation.new(parsed_json: a_doc)

            begin
              repr.related_hrefs(link_rel).any?
            rescue KeyError
              false
            end
          end
        end
      end
    end
  end
end
