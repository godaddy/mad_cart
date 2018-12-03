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
          attr_accessor(*exposed_attributes)
        end
      end

      def define_attribute_accessors
        klass.class_eval do
          attr_accessor(*exposed_attributes)
        end
      end

      def check_required_attributes(args)
        return unless klass.required_attrs

        keys = args.keys.map{|a| a.to_s }
        klass.required_attrs.each do |attr|
          raise(ArgumentError, "missing argument: #{attr}") if !keys.include?(attr)
        end
      end
      private :check_required_attributes

      def set_attribute(key, value)
        attr_name = klass.map_attribute_name(key)

        if klass.exposed_attributes.include? attr_name.to_s
          define_attribute_accessors unless self.respond_to?(attr_name)
          self.send("#{attr_name}=", value) unless value.nil?
        else
          self.additional_attributes[attr_name.to_s] = value unless value.nil?
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
          ((self.required_attrs || []) + included_attributes + mapped_attributes).uniq.map{|a| a.to_s } - unmapped_attributes.map{|a| a.to_s }
        end

        def included_attributes
          MadCart.config.included_attributes[self.to_s.demodulize.underscore.pluralize.to_sym] || []
        end
      end
    end
  end
end
