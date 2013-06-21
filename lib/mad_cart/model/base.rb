module MadCart
  module Model
    module Base
      def initialize(args={})
        self.additional_attributes = {}
        check_required_attributes(args)
        args.each { |k,v| set_attribute(k, v) }
      end

      def self.included(base)
        base.extend ClassMethods
        base.class_eval do
          include AttributeMapper
          include InheritableAttributes
          attr_accessor :additional_attributes
          inheritable_attributes :required_attrs
        end
      end

      def define_included_attribute_accessors
        klass.class_eval do
          attr_accessor(*included_attributes)
        end
      end

      def check_required_attributes(args)
        keys = args.keys.map{|a| a.to_s }
        klass.required_attrs.each do |attr|
          raise(ArgumentError, "missing argument: #{attr}") if !keys.include?(attr)
        end
      end
      private :check_required_attributes

      def set_attribute(key, value)
        if klass.exposed_attributes.include? key.to_s
          define_included_attribute_accessors unless self.respond_to?(key)
          self.send("#{key}=", value) unless value.nil?
        else
          self.additional_attributes[key.to_s] = value unless value.nil?
        end
      end
      private :set_attribute

      def klass
        self.class
      end
      private :klass

      module ClassMethods
        def required_attributes(*args)
          @required_attrs = args.map{|a| a.to_s }
          attr_accessor(*args)
        end

        def exposed_attributes
          (self.required_attrs || []) + (included_attributes || []).map{|a| a.to_s }
        end

        def included_attributes
          MadCart.config.included_attributes[self.to_s.demodulize.underscore.pluralize.to_sym]
        end
      end
    end
  end
end
