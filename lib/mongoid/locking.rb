# encoding: utf-8
module Mongoid #:nodoc:
  # Include this module to get automatic optimistic locking of root level documents.
  # This will add a lock_version field to the +Document+.
  module Locking
    extend ActiveSupport::Concern

    included do
      field :lock_version

      set_callback :save, :around, :update_lock_version
    end

    module InstanceMethods
      def _selector
        s = super
        s['lock_version'] = @working_lock_version
        s
      end

      protected

      def update_lock_version(options = {}, &block)
        #if no lock version given, use the original
        #if lock version set, use that
        @working_lock_version = lock_version

        self.lock_version = Time.now.to_f.to_s

        begin
          unless block && block.call
            self.lock_version = @working_lock_version
          else
            true
          end
        rescue
          self.lock_version = @working_lock_version
          raise
        end
      end
    end
  end
end
