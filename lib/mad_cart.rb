# lib
require 'json'
require 'singleton'

# gems
require 'active_support'
require 'active_support/core_ext'
require 'faraday'
require 'faraday_middleware'

# core
require 'mad_cart/configuration'
require 'mad_cart/attribute_mapper'
require 'mad_cart/inheritable_attributes'

# models
require 'mad_cart/model/base'
require 'mad_cart/model/customer'
require 'mad_cart/model/product'
require 'mad_cart/model/store'

# stores
require 'mad_cart/store/base'
require 'mad_cart/store/big_commerce'
require 'mad_cart/store/o_auth_big_commerce'
require 'mad_cart/store/etsy'
require 'mad_cart/store/spree'
