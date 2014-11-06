module RSpec
  module Hal
    module Helpers
      # Returns HalClient::Representation for `jsonish` (or
      # HalClient::Collection if `jsonish` is a RFC 6573 collection)
      #
      # jsonish - A HAL document (as a string or pre-parsed hash) or
      #   an object that can be converted into one via its `#to_hal`
      #   or `#to_json` methods.
      def parse_hal(jsonish)
        json = if jsonish.kind_of? String
                 jsonish

               elsif jsonish.respond_to? :to_hal
                 jsonish.to_hal

               else jsonish.respond_to? :to_json
                 jsonish.to_json
               end

        repr = HalClient::Representation.new(parsed_json: MultiJson.load(json))

        if repr.has_related? "item"
          HalClient::Collection.new(repr)
        else
          repr
        end
      end

    end
  end
end