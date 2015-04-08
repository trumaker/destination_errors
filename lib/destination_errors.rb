require "destination_errors/version"

#
#   There are three steps to implementing this module in a class:
#
#   Setup 1: include DestinationErrors and set error_surfaces
#
#     include DestinationErrors
#     # Usage: set explicitly in each class
#     #        individual error surfaces can be nil, it's safe.
#     has_error_surfaces [nil, :lead, :user]
#
#     # a simple default with only one surface, nil, where the errors
#     # accumulate on the object including this module would be:
#     #   has_error_surfaces [nil]
#
#   Setup 2: (optional)
#
#     def initialize
#       # choose one of the surfaces to aggregate errors onto, with nil indicating self.
#       @surface_errors_on = nil
#     end
#
#   Setup 3: call move_all_errors_to_destination after errors may exist on the error_surfaces
#
#     def finalize
#       move_all_errors_to_destination
#       self # if you want chainability return self
#     end
#

require "active_model"

module DestinationErrors

  def self.included(base)
    base.include(ActiveModel::Validations)
    base.prepend(Initializer)
    base.extend(ClassMethods)
    base.class_eval do
      attr_reader :errors
      attr_reader :errors_finalized
      attr_accessor :surface_errors_on
      class_attribute :error_surfaces
    end
  end

  module Initializer
    def initialize(*args)
      @errors = ActiveModel::Errors.new(self)
      @surface_errors_on = nil
      super
    end
  end

  # Checks to see if any errors have been registered on any of the error surfaces but:
  #   1. does not re-run validations
  #   2. does not add or move errors
  # returns true if any errors are found on any surface or false otherwise
  def error_surfaces_clean?
    return false if self.errors.any?
    self.class.error_surfaces.compact.each do |surface|
      return false if errors_on_surface?(surface)
    end
    return false if custom_error_destination_has_errors?
    return true
  end

  # Required for ActiveModel::Validations
  def read_attribute_for_validation(attr)
    send(attr)
  end

  # dynamically access the surface where errors are being aggregated
  def error_destination
    @error_destination = error_destination_is_self? ?
        self :
        self.send(self.surface_errors_on)
  end

  module ClassMethods
    # Implementation hook
    def has_error_surfaces(value)
      if value.length == 1 && value.first.nil?
        warn "#{self}: error_surfaces might not be configured"
      end
      self.error_surfaces = value
    end

    # Required for ActiveModel::Validations
    def human_attribute_name(attr, options = {})
      attr
    end

    # Required for ActiveModel::Validations
    def lookup_ancestors
      [self]
    end
  end

  protected

  # The error destination is not one of error_surfaces, and is not self, and has errors...
  def custom_error_destination_has_errors?
    !self.class.error_surfaces.include?(surface_errors_on) &&
        !error_destination_is_self? &&
            errors_on_surface?(surface_errors_on)
  end

  def move_all_errors_to_destination
    return false if self.errors_finalized
    self.error_surfaces.each do |surface|
      move_errors_from_surface_to_destination_if_needed(surface)
    end
    self.errors_finalized = true
  end

  def move_errors_from_surface_to_destination_if_needed(surface)
    if move_errors_from_surface?(surface)
      (
        surface.nil? ?
          errors.full_messages :
          self.send(surface).errors.full_messages
      ).each do |message|
        move_error_to_destination(message)
      end
    end
  end

  def move_errors_from_surface?(surface)
    if surface.nil?
      !error_destination_is_self? && errors && errors.any?
    else
      (surface_errors_on.to_s != surface.to_s) && errors_on_surface?(surface)
    end
  end

  def errors_on_surface?(surface)
    self.send(surface) && self.send(surface).errors.any?
  end

  def error_destination
    @error_destination = error_destination_is_self? ?
        self :
        self.send(surface_errors_on)
  end

  def error_destination_is_self?
    surface_errors_on.nil? || !self.send(surface_errors_on)
  end

  def move_error_to_destination(message)
    if error_destination
      error_destination.errors.add(:base, message)
    end
  end

end
