# enable to pass few roles to `attr_accessible` method which is very useful in defining `default` and `admin` attributes
module ActiveModel
  module MassAssignmentSecurity
    module ClassMethods
      def attr_accessible(*args)
        options = args.extract_options!
        role = options[:as] || [:admin, :default]

        self._accessible_attributes = accessible_attributes_configs.dup

        Array.wrap(role).each do |name|
          self._accessible_attributes[name] = self.accessible_attributes(name) + args
        end

        self._active_authorizer = self._accessible_attributes
      end
    end
  end
end

module ActiveModel
  module MassAssignmentSecurity
    class Sanitizer

      def sanitize(klass, attributes, authorizers)
        rejected = []
        sanitized_attributes = attributes.reject do |key, value|
          rejected << key if authorizers.all? { |authorizer| authorizer.deny?(key) }
        end
        process_removed_attributes(klass, rejected) unless rejected.empty?
        sanitized_attributes
      end

    end
  end
end

module ActiveModel
  module MassAssignmentSecurity

    def sanitize_for_mass_assignment(attributes, roles = nil)
      _mass_assignment_sanitizer.sanitize(self.class, attributes, mass_assignment_authorizer(roles))
    end

    def mass_assignment_authorizer(roles)
      Array(roles).map { |role| self.class.active_authorizer[role || :default] }
    end

  end
end
