module DestinationErrors
  module UniqueErrors

    def self.included(base)
      base.include(ErrorAggregation)
    end

    module ErrorAggregation
      def add_errors_uniquely(key, *message_array)
        message_array.each do |message|
          error_destination.errors.add(key, message) unless error_destination.errors[key].include?(message)
        end
      end
    end
  end
end