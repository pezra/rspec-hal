require 'json'
require 'hal-client'

module RSpec
  module Hal
    module Matchers
      autoload :HalMatcherHelpers, "rspec/hal/matchers/hal_matcher_helpers"
      require "rspec/hal/matchers/templated_relation_matcher"
      require "rspec/hal/matchers/have_property_matcher"

      # Examples
      #
      #     expect(doc).to have_templated_relation("search")
      #     expect(doc).to have_templated_relation("search", matching("{?q}"))
      #
      def have_templated_relation(*args)
        TemplatedRelationMatcher.new(*args)
      end

      # Signature
      #
      #     expect(a_doc).to have_property "name"
      #     expect(a_doc).to have_property "name, matching(/alice/i)
      #
      #     expect(a_doc).to have_property("name").matching(/alice/i)
      #     expect(a_doc).to have_property("hobbies").including(matching("golf"))
      #     expect(a_doc).to have_property("name").that_is("Bob")
      #     expect(a_doc).to have_property("age").that_is kind_of Numeric
      def have_property(*args)
        HavePropertyMatcher.new(*args)
      end

      module Document
        extend RSpec::Matchers::DSL

        # Provide a 3.0 compatible DSL methods for 2.x RSpec.
        module ForwardCompat
          def failure_message(&blk)
            failure_message_for_should(&blk)
          end
        end

        # Install 3.0 compatibility layer if needed.
        class << self
          def matcher(name, &blk)
            super name do |*args|
              extend ForwardCompat unless respond_to? :failure_message

              self.instance_exec *args, &blk
            end
          end
        end


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
              repr.related_hrefs(link_rel) .any?{|an_href|
                next true if !defined? @href_matcher
                @href_matcher === an_href
              }
            rescue KeyError
              false
            end
          end

          chain :with_href do |expected_href|
            (fail ArgumentError, "#{expected_href.inspect} must be a matcher") unless expected_href.respond_to? :matches?

            @href_matcher = expected_href
          end

          failure_message do
            msg = super()
            if @href_matcher
              msg + " with href " + @href_matcher.description.gsub(/^match /, "matching ")
            end
          end

        end
      end

      include Document
    end
  end
end
