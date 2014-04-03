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
      end
    end
  end
end
