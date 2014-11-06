require 'json'
require 'hal-client'

module RSpec
  module Hal
    module Matchers
      autoload :HalMatcherHelpers, "rspec/hal/matchers/hal_matcher_helpers"
      require "rspec/hal/matchers/relation_matcher"
      require "rspec/hal/matchers/templated_relation_matcher"
      require "rspec/hal/matchers/have_property_matcher"
      require "rspec/hal/matchers/uri_template_has_variables_matcher"

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
      #     expect(doc).to have_relation(link_rel)
      #     expect(doc).to have_relation(link_rel, href_matcher)
      #     expect(doc).to have_relation(link_rel, template_variables)
      #     expect(doc).to have_relation(link_rel, template_variables, href_matcher)
      #
      # Examples
      #
      #     expect(authors_doc).to have_relation("search",
      #                                          {q: "Alice"},
      #                                          match(%r|users/42|))
      def have_relation(*args)
        RelationMatcher.new(*args)
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

      # Signature
      #
      #  expect(a_uri_template_str).to have_variables "q", "limit"
      def have_variables(*args)
        UriTemplateHasVariablesMatcher.new(*args)
      end

      # Signature
      #
      #  expect(a_uri_template_str).to has_variable "q"
      def has_variable(*args)
        UriTemplateHasVariablesMatcher.new(*args)
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
                      rescue => err
                        err.message
                      end

            "Expected a HAL document but it wasn't because #{message} in:\n" +
              a_json_doc
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
      end
      include Document
    end
  end
end
