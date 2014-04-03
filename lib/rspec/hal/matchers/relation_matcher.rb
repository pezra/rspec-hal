module RSpec
  module Hal
    module Matchers

      # Example
      #
      #     expect(doc).to have_relation("search")
      #     expect(doc).to have_relation("search", matching("{?q}"))
      #
      class RelationMatcher
        include HalMatcherHelpers

        # Signature
        #
        #     expect(doc).to have_relation link_rel
        #     expect(doc).to have_relation link_rel, href_matcher
        #     expect(doc).to have_relation link_rel, template_variables
        #     expect(doc).to have_relation link_rel, template_variables, href_matcher
        def initialize(link_rel, *args)
          @link_rel = link_rel

          @tmpl_vars, @expected = *if args.empty?
                                     [{},NullMatcher]
                                   elsif args.size > 1
                                     args
                                   elsif hashish? args.first
                                     [args.first, NullMatcher]
                                   else
                                     [{}, args.first]
                                   end
        end

        def matches?(jsonish)
          repr = parse(jsonish)

          repr.related_hrefs(link_rel, tmpl_vars){[]}
            .select{|it| expected === it }
            .any?
        end

        def failure_message
          sentencize "Expected `#{link_rel}` link or embedded", expected.description, "but found none"
        end
        alias_method :failure_message_for_should, :failure_message

        def failure_message_when_negated
          "Expected `#{link_rel}` link to be absent"
        end
        alias_method :failure_message_for_should_not, :failure_message_when_negated

        def description
          "have #{link_rel} link or embedded"
        end

        def with_href(expected)
          self.class.new(link_rel, tmpl_vars, matcherize(expected))
        end

        protected

        attr_reader :link_rel, :expected, :tmpl_vars

        def hashish?(obj)
          obj.respond_to?(:key?) && obj.respond_to?(:[])
        end
      end
    end
  end
end
