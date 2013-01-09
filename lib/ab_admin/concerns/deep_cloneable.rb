# -*- encoding : utf-8 -*-
module AbAdmin
  module Concerns
    module DeepCloneable

      def deep_duplicate(*args)
        deep_dup(false, *args)
      end

      def deep_dup(target, *args)
        dupl = target || self.dup

        args.reject! { |a| a.blank? }
        return dupl if args.empty?

        args.each do |arg|
          case arg
            when Hash
              arg.each do |k, v|
                dup_simple(dupl, k, v)
              end
            else
              Array(arg).each do |k|
                if k.kind_of?(Hash) || k.kind_of?(Array)
                  self.deep_dup(dupl, k)
                else
                  dup_simple(dupl, k)
                end
              end
          end
        end

        dupl
      end

      def dup_simple(dupl, k, v=nil)
        if check_assoc(k).collection?
          self.send(k).each do |rec|
            dupl.send(k) << (v ? rec.deep_dup(false, v) : rec.dup)
          end
        else
          dupl.send("#{k}=", (v ? self.send(k).deep_dup(false, v) : self.send(k).dup))
        end

        dupl
      end

      def check_assoc(assoc_method)
        raise "Target has no association #{assoc_method}" unless assoc = self.class.reflect_on_association(assoc_method)
        assoc
      end

    end
  end
end
