require 'set'
require 'addressable/template'

module RSpec
  module Hal
    module Matchers
      class UriTemplateHasVariablesMatcher
        def initialize(a_tmpl_relation_matcher, vars)
          @tmpl_matcher = a_tmpl_relation_matcher
          @expected_vars = Set.new(vars)
        end

        def matches?(actual)
          expected_vars.subset? actual_vars
        end

        def description
          "have variables #{expected_vars.join(", ")}"
        end

        def failure_message
          "Expected #{actual_tmpl.to_s} to have #{expected_vars.join(", ")}"
        end

        def failure_message_when_negated
          "Expected #{actual_tmpl.to_s} not to have #{expected_vars.join(", ")}"
        end

        protected

        attr_reader :tmpl_matcher, :expected_vars

        def actual_tmpl
          Addressable::Template.new(tmpl_matcher.uri_template)
        end

        def actual_vars
          Set.new(actual_tmpl.variables)
        end

      end
    end
  end
end