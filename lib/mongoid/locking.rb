# encoding: utf-8
module Mongoid #:nodoc:
  # Include this module to get automatic versioning of root level documents.
  # This will add a version field to the +Document+ and a has_many association
  # with all the versions contained in it.
  module Locking
    extend ActiveSupport::Concern

    included do
      field :lock_version

      before_save :set_lock_version
    end

    module InstanceMethods
      def _selector
        s = super
        s['lock_version'] = (lock_version_change && lock_version_change.first) || lock_version
        s
      end

      protected

      def set_lock_version
        unless lock_version_changed?
          self.lock_version = Time.now.to_f.to_s
        end
      end
    end
  end
end
