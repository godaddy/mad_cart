# lib
require 'json'
require 'singleton'

# gems
require 'active_support/core_ext'
require 'faraday'

# core
require 'mad_cart/configuration'
require 'mad_cart/attribute_mapper'
require 'mad_cart/inheritable_attributes'

# models
require 'mad_cart/model/base'
require 'mad_cart/model/customer'
require 'mad_cart/model/product'

# stores
require 'mad_cart/store/base'
require 'mad_cart/store/big_commerce'
require 'mad_cart/store/etsy'


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
end
