module RSpec
  module Hal
    module Matchers

      # Example
      #
      #     expect(doc).to have_property("name")
      #     expect(doc).to have_property("search", matching("Alice"))
      #
      class HavePropertyMatcher
        include HalMatcherHelpers

        def initialize(property_name, expected=NullMatcher)
          @prop_name = property_name
          @expected = matcherize expected
        end

        def matches?(jsonish)
          self.repr = jsonish

          repr.property?(prop_name) &&
            expected === repr.property(prop_name){ nil }
        end

        def failure_message
          sentencize "Expected property `#{prop_name}`", expected.description
        end
        alias_method :failure_message_for_should, :failure_message

        def failure_message_when_negated
          sentencize "Expected property `#{prop_name}`", expected.description, "to be absent"
        end
        alias_method :failure_message_for_should_not, :failure_message_when_negated

        def description
          "have property `#{prop_name}` #{@expected.description}"
        end


        def matching(expected)
          self.class.new(prop_name, matcherize(expected))
        end
        alias_method :that_is, :matching

        def including(expected)
          self.class.new(prop_name, RSpec::Matchers::BuiltIn::Include.new(expected))
        end

        protected

        attr_reader :prop_name, :outcome, :expected

      end
    end
  end
end
