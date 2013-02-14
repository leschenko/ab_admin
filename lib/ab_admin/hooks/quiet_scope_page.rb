#module ActiveRecord
#  module Scoping
#    module Named
#      module ClassMethods
#        def valid_scope_name?(name)
#          silence_names = [:page, :visible, :un_visible, :admin, :base]
#          if respond_to?(name, true) && !silence_names.include?(name.to_sym)
#            logger.warn "Creating scope :#{name}. " \
#                      "Overwriting existing method #{self.name}.#{name}."
#          end
#        end
#      end
#    end
#  end
#end
#
