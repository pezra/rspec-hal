module RSpec
  module Hal
    module Matchers

      # Example
      #
      #     expect(doc).to have_templated_relation("search")
      #     expect(doc).to have_templated_relation("search", matching("{?q}"))
      #
      class TemplatedRelationMatcher
        def initialize(link_rel, expected=nil)
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
          expected_clause = if expected != NullMatcher && expected.respond_to?(:description)
                              expected.description
                            elsif expected != NullMatcher
                              "matching #{expected}"
                            else
                              "to exist"
                            end

          "Expected templated `#{link_rel}` link #{expected_clause} but #{but_clause}"
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

        attr_reader :link_rel, :outcome

        NullMatcher = ->(_url_template){ true }

        def expected
          @expected ||= NullMatcher
        end

        def parse(jsonish)
          json = if jsonish.kind_of? String
                   jsonish

                 elsif jsonish.respond_to? :to_hal
                   jsonish.to_hal

                 else jsonish.respond_to? :to_json
                   jsonish.to_json
                 end

          HalClient::Representation.new(parsed_json: MultiJson.load(json))
        end
      end
    end
  end
end
