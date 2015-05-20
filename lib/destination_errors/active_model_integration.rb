require "active_model"

module DestinationErrors
  module ActiveModelIntegration

    # Required for ActiveModel::Validations
    def read_attribute_for_validation(attr)
      send(attr)
    end

    def self.included(base)
      base.include(ActiveModel::Validations)
      base.prepend(Initializer)
      base.extend(ClassMethods)
      base.class_eval do
        attr_reader :errors
      end
    end

    module Initializer
      def initialize(*args)
        @errors = ActiveModel::Errors.new(self)
        super
      end
    end

    module ClassMethods
      # Required for ActiveModel::Validations
      def human_attribute_name(attr, options = {})
        attr
      end

      # Required for ActiveModel::Validations
      def lookup_ancestors
        [self]
      end
    end
  end
end