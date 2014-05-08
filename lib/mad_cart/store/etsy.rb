require 'etsy'
require 'money'
require 'monetize'

module MadCart
  module Store
    class Etsy
      include MadCart::Store::Base
      
      create_connection_with :create_connection, :requires => [:store_name, :api_key]
      fetch :products, :with => :get_products
      format :products, :with => :format_products
      
      def valid?
        self.connection ? true : false
      end

      private
      def get_products(options={})
        connection.listings(:active, product_options(options))
      end

      def format_products(listing)
        {
           :external_id => listing.id,
           :name => listing.title,
           :description => listing.description,
           :price => listing.price.to_money(listing.currency).dollars,
           :url => listing.url,
           :currency_code => listing.currency,
           :image_url => listing.result["MainImage"].try(:[], "url_570xN"),
           :square_image_url => listing.result["MainImage"].try(:[], "url_75x75")
        }
      end

      def create_connection(args)
        ::Etsy.api_key = args[:api_key] if !::Etsy.api_key || (::Etsy.api_key != args[:api_key])
        ::Etsy.environment = :production
        store = ::Etsy::Shop.find(args[:store_name])
        if store.is_a? Array
          return store.first
        else 
          raise InvalidStore if store.nil?
          return store
        end
      end
      
      def product_options(options)
        prod_options = options.clone
        prod_options[:page] ||= 1
        
        return prod_options
      end
    end
  end
end

