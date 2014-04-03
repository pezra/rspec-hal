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
          repr = parse(jsonish)

          repr.raw_related_hrefs(link_rel){[]}
            .select{|it| it.respond_to? :expand}
            .select{|it| expected === it }
            .any?
            .tap do |outcome|
              @outcome = if outcome
                           :pass
                         elsif repr.raw_related_hrefs(link_rel){[]}.any?
                           :no_templates
                         else
                           :no_relations
                         end
            end
        end

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

        protected

        attr_reader :link_rel, :outcome, :expected
      end
    end
  end
end
