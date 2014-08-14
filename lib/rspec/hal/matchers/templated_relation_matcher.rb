require 'rspec/expectations'
require 'rspec/hal/matchers/uri_template_has_variables_matcher'

module RSpec
  module Hal
    module Matchers

      # Example
      #
      #     expect(doc).to have_templated_relation("search")
      #     expect(doc).to have_templated_relation("search", matching("{?q}"))
      #
      class TemplatedRelationMatcher
        include HalMatcherHelpers

        def initialize(link_rel, expected=NullMatcher)
          @link_rel = link_rel
          @expected = expected
        end

        def matches?(jsonish)
          self.repr = jsonish

          repr.raw_related_hrefs(link_rel){[]}
            .tap{|it| if it.none?
                        @outcome = :no_relations
                        return false
                      end }
            .select{|it| it.respond_to? :expand}
            .tap{|it| if it.none?
                        @outcome = :no_templates
                        return false
                      end }
            .select{|it| expected === it.pattern }
            .tap{|it| if it.none?
                        @outcome = :none_matched
                        return false
                      end }

          true
        end
        alias_method :===, :matches?

        def failure_message
          but_clause = if outcome == :no_templates
                         "found only non-templated links"
                       else
                         "found none"
                       end

          sentencize "Expected templated `#{link_rel}` link", expected.description, "but #{but_clause}"
        end
        alias_method :failure_message_for_should, :failure_message

        def failure_message_when_negated
          "Expected `#{link_rel}` link to be absent or not templated"
        end
        alias_method :failure_message_for_should_not, :failure_message_when_negated

        def description
          "have templated #{link_rel} link"
        end

        def with_variables(*vars)
          self.class.new(link_rel, UriTemplateHasVariablesMatcher.new(vars))
        end
        alias_method :with_variable, :with_variables

        def uri_template
          repr.raw_related_hrefs(link_rel){[]}.first
        end

        protected

        attr_reader :link_rel, :outcome, :expected
      end
    end
  end
end
