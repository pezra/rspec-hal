module RSpec
  module Hal
    module Matchers
      module HalMatcherHelpers
        NullMatcher = Class.new do
          def matches(*args)
            true
          end
          def ===(*args)
            true
          end
          def description
            ""
          end
        end.new

        def repr=(jsonish)
          @repr = parse jsonish
        end
        attr_reader :repr

        # Returns string composed of the specified clauses with proper
        # spacing between them. Empty and nil clauses are ignored.
        def sentencize(*clauses)
          clauses
            .flatten
            .compact
            .reject(&:empty?)
            .map(&:strip)
            .join(" ")
        end

        # Returns HalClient::Representation of the provided jsonish
        # thing.
        #
        # jsonish - A HAL document (as a string or pre-parsed hash) or
        #   an object that can be converted into one via its `#to_hal`
        #   or `#to_json` methods.
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

        def matcherize(expected)
          if matcher? expected
            expected
          elsif expected.kind_of? Regexp
            RSpec::Matchers::BuiltIn::Match.new(expected)
          else
            RSpec::Matchers::BuiltIn::Eq.new(expected)
          end
        end

        def matcher?(obj)
          obj.respond_to?(:matches?) and (obj.respond_to?(:failure_message) or
                                          obj.respond_to?(:failure_message_for_should))
        end
      end
    end
  end
end
