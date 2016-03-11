require 'ostruct'

module MadCart
  class << self
    def configure
      raise(ArgumentError, "MadCart.configure requires a block argument.") unless block_given?
      yield(MadCart::Configuration.instance)
    end

    def config
      raise(ArgumentError, "MadCart.config does not support blocks. Use MadCart.configure to set config values.") if block_given?
      return MadCart::Configuration.instance.data
    end
  end

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

    Data = Class.new(OpenStruct)
  end
end