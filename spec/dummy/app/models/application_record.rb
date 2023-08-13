class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.inherited(subclass)
    super
    subclass.singleton_class.class_eval do
      def ransackable_attributes(*)
        @ransackable_attributes_cache ||= authorizable_ransackable_attributes
      end

      def ransackable_associations(*)
        @ransackable_associations_cache ||= authorizable_ransackable_associations
      end
    end
  end
end