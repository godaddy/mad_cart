module MadCart
  module AttributeMapper

    # def attributes
    #       Hash[initial_attributes.map {|k, v| [(mapping_hash[k] || mapping_hash[k.to_sym] || k).to_s, v] }]
    #     end
    
    def self.included(base)
      base.extend ClassMethods
    end
    
    def attributes
      Hash[self.class.exposed_attributes.map{|a| [a.to_s, self.send(a)]}]
    end
    
    module ClassMethods
      def map_attribute_name(name)
        mapping_hash[name] || name
      end
      
      def mapping_hash
        MadCart.config.attribute_maps[self.to_s.demodulize.underscore.pluralize] || {}
      end
      
      def mapped_attributes
        mapping_hash.values
      end
      
      def unmapped_attributes
        mapping_hash.keys
      end
    end

  end
end
