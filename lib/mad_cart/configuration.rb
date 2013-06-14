require 'ostruct'

module MadCart
  class Configuration
    include Singleton

    def add_store(store_name, args={})
      setup_data

      @data[:stores] << store_name
      @data[store_name.to_s] = args
    end

    def attribute_map(data_model, attributes)
      setup_data

      @data[:attribute_maps][data_model.to_s] = attributes
    end

    def include_attributes(args={})
      setup_data

      @data[:included_attributes].merge!(args)
    end

    def data
      setup_data
      Data.new(@data)
    end

    private
    def setup_data
      @data ||= {:stores => []}
      @data[:attribute_maps] ||= {}
      @data[:included_attributes] ||= {}
    end

    class Data < OpenStruct
      class ConfigurationError < NoMethodError; end

      def method_missing(meth, *args)
        return nil
      end

    end
  end
end
