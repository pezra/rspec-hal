require 'set'
require 'addressable/template'

module RSpec
  module Hal
    module Matchers
      class UriTemplateHasVariablesMatcher
        def initialize(vars)
          @expected_vars = Set.new(vars.map(&:to_s))
        end

        def matches?(actual)
          self.actual_tmpl = actual

          expected_vars.subset? actual_vars
        end
        alias_method :===, :matches?

        def description
          "have variables #{as_human_list(expected_vars)}"
        end

        def failure_message
          "Expected #{actual_tmpl.pattern} to have #{as_human_list(expected_vars)}"
        end

        def failure_message_when_negated
          "Expected #{actual_tmpl.pattern} not to have #{as_human_list(expected_vars)}"
        end

        protected

        attr_reader :tmpl_matcher, :expected_vars, :actual_tmpl

        def actual_tmpl=(a_template)
          @actual_tmpl = if a_template.respond_to? :pattern
                           actual_tmpl
                         else
                           Addressable::Template.new(a_template)
                         end
        end

        def actual_vars
          Set.new(actual_tmpl.variables)
        end

        def as_human_list(enum)
          enum.to_a.join(", ")
        end
      end
    end
  end
end