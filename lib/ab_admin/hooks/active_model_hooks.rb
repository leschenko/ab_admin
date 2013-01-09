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
      def sanitize(attributes, authorizers)
        sanitized_attributes = attributes.reject { |key, value| authorizers.all? { |auth| auth.deny?(key) } }
        debug_protected_attribute_removal(attributes, sanitized_attributes)
        sanitized_attributes
      end
    end
  end
end

module ActiveModel
  module MassAssignmentSecurity
    def sanitize_for_mass_assignment(attributes, roles = nil)
      _mass_assignment_sanitizer.sanitize(attributes, mass_assignment_authorizer(roles))
    end

    def mass_assignment_authorizer(roles)
      Array(roles).map { |role| self.class.active_authorizer[role || :default] }
    end
  end
end
